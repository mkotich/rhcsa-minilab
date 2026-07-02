#!/bin/bash

#
# Storage framework
#
# Responsibilities:
#
#   - Create repeatable LVM resources.
#   - Remove previous storage state.
#   - Provide validation helpers.
#   - Provide grading entry points.
#
# This library intentionally creates a deterministic
# storage layout used by multiple storage objectives.
#

#
# Storage helper library
#
# Used by:
#
#   prepare/storage.sh
#   scenarios/storage/*
#
# Provides reusable storage creation routines for the MiniLab.
#

STORAGE_INITIAL_SIZE_BYTES=$((512 * 1024 * 1024))

cleanup_storage()
{
    local VG="$1"
    local LV="$2"
    local MOUNT="$3"
    local DISK="$4"

    #
    # Unmount if mounted.
    #
    mountpoint -q "$MOUNT" &&
        umount "$MOUNT"

    #
    # Remove fstab entry.
    #
    sed -i "\|[[:space:]]${MOUNT}[[:space:]]|d" /etc/fstab

    #
    # Remove LV if it exists.
    #
    if lvs "${VG}/${LV}" >/dev/null 2>&1
    then
        lvremove -fy "/dev/${VG}/${LV}" >/dev/null
    fi

    #
    # Remove VG if it exists.
    #
    if vgs "$VG" >/dev/null 2>&1
    then
        vgremove -fy "$VG" >/dev/null
    fi

    #
    # Remove PV if it exists.
    #
    if pvs "$DISK" >/dev/null 2>&1
    then
        pvremove -fy "$DISK" >/dev/null
    fi

    #
    # Remove any signatures.
    #
    wipefs -af "$DISK" >/dev/null 2>&1 || true

    #
    # Remove mount point.
    #
    rmdir "$MOUNT" >/dev/null 2>&1 || true
}

create_lvm()
{
    local DISK="$1"
    local VG="$2"
    local LV="$3"
    local SIZE="$4"
    local FSTYPE="$5"
    local MOUNT="$6"

    cleanup_storage \
        "$VG" \
        "$LV" \
        "$MOUNT" \
        "$DISK"

        wipefs -af "$DISK" >/dev/null 2>&1 || true

    pvcreate "$DISK" >/dev/null
    vgcreate "$VG" "$DISK" >/dev/null
    lvcreate \
        -W y \
        -y \
        -L "$SIZE" \
        -n "$LV" \
        "$VG" >/dev/null

    mkfs -t "$FSTYPE" "/dev/${VG}/${LV}" >/dev/null 2>&1

    mkdir -p "$MOUNT"

    local UUID
    UUID=$(blkid -s UUID -o value "/dev/${VG}/${LV}")

    echo "UUID=${UUID} ${MOUNT} ${FSTYPE} defaults 0 0" >> /etc/fstab

    systemctl daemon-reload >/dev/null 2>&1 || true

    mount "$MOUNT"
}

########################################
# Storage Validation
########################################

storage_lv_exists()
{
    lvs vgapps/lvapps >/dev/null 2>&1
}

storage_filesystem_exists()
{
    blkid /dev/vgapps/lvapps >/dev/null 2>&1
}

storage_is_mounted()
{
    findmnt /apps >/dev/null 2>&1
}

storage_fstab_exists()
{
    grep -q '[[:space:]]/apps[[:space:]]' /etc/fstab
}

storage_uuid_correct()
{
    local FS_UUID

    FS_UUID=$(blkid -s UUID -o value /dev/vgapps/lvapps)

    grep -q "^UUID=${FS_UUID}[[:space:]]" /etc/fstab
}

storage_is_gpt()
{
    parted -sm /dev/sdb print | grep -q ':gpt:'
}

storage_pv_is_partition()
{
    pvs --noheadings -o pv_name |
        xargs |
        grep -qx '/dev/sdb1'
}

storage_current_size_bytes()
{
    if ! lvs vgapps/lvapps >/dev/null 2>&1
    then
        return 1
    fi

    lvs \
        --noheadings \
        --units b \
        --nosuffix \
        -o lv_size \
        vgapps/lvapps \
        2>/dev/null |
        xargs
}

storage_size_to_bytes()
{
    local VALUE="$1"

    case "$VALUE" in
        *MiB)
            echo $(( ${VALUE%MiB} * 1024 * 1024 ))
            ;;
        *GiB)
            echo $(( ${VALUE%GiB} * 1024 * 1024 * 1024 ))
            ;;
        *MB)
            echo $(( ${VALUE%MB} * 1000 * 1000 ))
            ;;
        *GB)
            echo $(( ${VALUE%GB} * 1000 * 1000 * 1000 ))
            ;;
        *)
            return 1
            ;;
    esac
}

########################################
# Storage Grading
########################################

grade_storage()
{
    local OBJECT_ID

    OBJECT_ID=$(echo "$OBJECT" | jq -r '.id')

    case "$OBJECT_ID" in
        storage-001)
            grade_storage_filesystem
            ;;

        storage-002)
            grade_storage_uuid
            ;;

        storage-003)
            grade_storage_fstab
            ;;

        storage-004)
            grade_storage_growth
            ;;

        *)
            RESULT="NOT IMPLEMENTED"
            ;;
    esac
}

grade_storage_filesystem()
{
    if ! storage_lv_exists
    then
        RESULT="FAIL"
        return
    fi

    if ! storage_filesystem_exists
    then
        RESULT="FAIL"
        return
    fi

    if ! storage_fstab_exists
    then
        RESULT="FAIL"
        return
    fi

    if ! storage_uuid_correct
    then
        RESULT="FAIL"
        return
    fi

    if ! storage_is_mounted
    then
        RESULT="FAIL"
        return
    fi
}

grade_storage_uuid()
{
    #
    # For v1.0 this objective is satisfied by the same
    # validation as a correct filesystem.
    #
    grade_storage_filesystem
}

grade_storage_fstab()
{
    #
    # For v1.0 this objective is satisfied by the same
    # validation as a correct persistent mount.
    #
    grade_storage_filesystem
}

grade_storage_growth()
{
    local GROW_BY
    local EXPECTED_BYTES
    local CURRENT_BYTES

    GROW_BY=$(
        jq -r '.answer.grow_by' <<<"$OBJECT"
    )

    CURRENT_BYTES=$(
        storage_current_size_bytes
    )

    storage_lv_exists || {
        RESULT="FAIL"
        return
    }

    storage_filesystem_exists || {
        RESULT="FAIL"
        return
    }

    EXPECTED_BYTES=$(( \
        STORAGE_INITIAL_SIZE_BYTES + \
        $(storage_size_to_bytes "$GROW_BY") \
    ))

    if [ "$CURRENT_BYTES" -lt "$EXPECTED_BYTES" ]
    then
        RESULT="FAIL"
        return
    fi

    storage_is_mounted || {
        RESULT="FAIL"
        return
    }

    RESULT="PASS"
}
