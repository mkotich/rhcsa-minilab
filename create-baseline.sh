#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

source "${SCRIPT_DIR}/variables.conf"
source "${SCRIPT_DIR}/lib/objectives.sh"

verify_root()
{
    if [ "$EUID" -ne 0 ]
    then
        echo "ERROR: Must be run as root."
        exit 1
    fi
}

show_help()
{
    cat << HELP
Usage:
    $0 [OPTION]

Options:

    --help
        Display this help message.

    --validate-all-objectives
        Validate objective JSON files and schema.

    --audit-all-objectives
        Create a temporary exam containing every objective,
        run the grading engine against the current baseline,
        and report objectives that are already satisfied.

        Use --verbose to display every grading result.

    --verbose
        Display the grading results for every objective
        while running the baseline audit.
No option:

    Create a new baseline from the current system.
HELP
}

validate_all_objectives()
{
    echo
    echo "================================================="
    echo "RHCSA MiniLab Objective Validation"
    echo "================================================="
    echo

    echo "Checking objective files..."
    echo

    for FILE in objectives/*.json
    do
        jq empty "$FILE" >/dev/null 2>&1 || {
            echo "[FAIL] Invalid JSON:"
            echo "    $FILE"
            echo
            return 1
        }
    done

    echo "[PASS] JSON syntax"

    for FILE in objectives/*.json
    do
        jq -e '
            .[] |
            has("id") and
            has("category") and
            has("domain") and
            has("difficulty") and
            has("importance") and
            has("points") and
            has("resource_group") and
            has("text") and
            has("hint") and
            has("answer")
        ' "$FILE" >/dev/null || {
            echo "[FAIL] Missing required field(s):"
            echo "    $FILE"
            echo
            return 1
        }
    done

    echo "[PASS] Required fields"

    DUPLICATES=$(
        jq -r '.[].id' objectives/*.json |
        sort |
        uniq -d
    )

    if [ -n "$DUPLICATES" ]
    then
        echo "[FAIL] Duplicate objective ID(s):"
        echo
        echo "$DUPLICATES"
        echo
        return 1
    fi

    echo "[PASS] Duplicate IDs"

    FILE_COUNT=$(find objectives -name '*.json' | wc -l)
    OBJECTIVE_COUNT=$(jq -s 'add | length' objectives/*.json)

    echo
    echo "Validation successful."
    echo
    printf "Files Checked      %s\n" "$FILE_COUNT"
    printf "Objectives         %s\n" "$OBJECTIVE_COUNT"
    echo
}

audit_all_objectives()
{
    validate_all_objectives || return 1

    echo
    echo "Running baseline audit..."

    TMPDIR=$(mktemp -d)
    trap 'rm -rf "$TMPDIR"' EXIT

    expand_objectives "${SCRIPT_DIR}"/objectives/*.json \
        > "$TMPDIR/exam-state.json"

    #
    # Ensure all template variables have been expanded.
    #
    UNEXPANDED=$(
        jq -r '
            .. |
            strings |
            select(test("\\$\\{"))
        ' "$TMPDIR/exam-state.json" |
        sort -u
    )

    if [ -n "$UNEXPANDED" ]
    then
        echo
        echo "ERROR: Unexpanded template variables found."
        echo

        echo "$UNEXPANDED" |
        while read VARIABLE
        do
            printf "  %s\n" "$VARIABLE"
        done

        echo
        echo "The audit must operate on fully expanded objectives."
        echo
        return 1
    fi

        OUTPUT=$(
        STATE="$TMPDIR/exam-state.json" \
            GRADE_MODE=audit \
            ./grade-exam.sh
    )

    if [ "$VERBOSE" -eq 1 ]
then
    echo
    printf '%s\n' "$OUTPUT"
    echo
fi

    PASSING=$(printf '%s\n' "$OUTPUT" | grep '^PASS|')

    PASS_COUNT=$(printf '%s\n' "$OUTPUT" | grep -c '^PASS|')

    FAIL_ONLY_COUNT=$(printf '%s\n' "$OUTPUT" | grep -c '^FAIL|')

    NOT_IMPLEMENTED_COUNT=$(printf '%s\n' "$OUTPUT" | grep -c '^NOT IMPLEMENTED|')

    TOTAL=$((PASS_COUNT + FAIL_ONLY_COUNT + NOT_IMPLEMENTED_COUNT))

    FAIL_COUNT=$((FAIL_ONLY_COUNT + NOT_IMPLEMENTED_COUNT))

    EXPECTED=$(jq 'length' "$TMPDIR/exam-state.json")

    if [ "$TOTAL" -ne "$EXPECTED" ]
    then
        echo
        echo "ERROR: Grading terminated before all objectives were evaluated."
        echo
        printf "Expected: %s\n" "$EXPECTED"
        printf "Graded:   %s\n" "$TOTAL"
        echo
        return 1
    fi

    echo "================================================="
    echo "RHCSA MiniLab Baseline Audit"
    echo "================================================="
    echo

    printf "%-24s %s\n" "Objectives Evaluated" "$TOTAL"
    printf "%-24s %s\n" "Objectives Passing" "$PASS_COUNT"
    printf "%-24s %s\n" "Require Student Work" "$FAIL_COUNT"

    echo

    if [ "$PASS_COUNT" -gt 0 ]
    then
        echo "Objectives already satisfied"
        echo "----------------------------"
        echo

        echo "$PASSING" |
        cut -d'|' -f2 |
        while read LINE
        do
            printf "  - %s\n" "$LINE"
        done
    fi

    echo
    echo "-------------------------------------------------"
    echo

    if [ "$PASS_COUNT" -eq 0 ]
    then
        echo "Baseline validation successful."
        echo
        echo "Every objective requires student intervention."
    else
        echo "Recommendation"
        echo
        echo "Modify or replace the objectives above before"
        echo "creating the next release baseline."
    fi

    echo
}

create_baseline()
{
    BASELINE=/baseline

    if [ -d "$BASELINE" ]
    then
        echo
        echo "ERROR: A baseline already exists."
        echo

        if [ -f /baseline.version ]
        then
            echo "Existing baseline commit:"
            printf "    %.12s\n\n" "$(cat /baseline.version)"
            echo
        fi

        echo "To intentionally replace the baseline, remove:"
        echo
        echo "    /baseline"
        echo "    /baseline.version"
        echo
        echo "Then run create-baseline.sh again."
        echo

        echo "If you were looking for other functionality, try:"
        echo
        echo "    ./create-baseline.sh --help"
        echo
        echo "or run:"
        echo
        echo "    ./create-baseline.sh --validate-all-objectives"
        echo "    ./create-baseline.sh --audit-all-objectives"
        echo
        exit 1
    fi

    echo
    echo "Creating baseline..."
    echo

    mkdir -p "$BASELINE"

    rsync -aAXH --delete \
        --exclude="$BASELINE" \
        --exclude=/home/student \
        --exclude=/opt/rhcsa-minilab \
        --exclude=/dev \
        --exclude=/proc \
        --exclude=/sys \
        --exclude=/run \
        --exclude=/tmp \
        --exclude=/var/lib/nfs/rpc_pipefs \
        --exclude=/var/tmp \
        --exclude=/mnt \
        --exclude=/media \
        --exclude=/lost+found \
        / "$BASELINE"

    git rev-parse HEAD > /baseline.version

    echo
    echo "Baseline created successfully."
    echo "Commit: $(cat /baseline.version)"
    echo
}

########################################

# Main

########################################

########################################
# Main
########################################

verify_root

while [ $# -gt 0 ]
do
    case "$1" in
        --help)
            MODE="help"
            ;;

        --validate-all-objectives)
            MODE="validate"
            ;;

        --audit-all-objectives)
            MODE="audit"
            ;;

        --verbose)
            VERBOSE=1
            ;;

        "")
            ;;

        *)
            echo "Unknown option: $1"
            echo
            show_help
            exit 1
            ;;
    esac

    shift
done

case "$MODE" in
    help)
        show_help
        ;;

    validate)
        validate_all_objectives
        ;;

    audit)
        audit_all_objectives
        ;;

    "")
        create_baseline
        ;;

    *)
        echo "Internal error: unknown mode."
        exit 1
        ;;
esac
