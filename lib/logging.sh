grade_logging() {
    RESULT="PASS"

    [ -d /var/log/journal ] || RESULT="FAIL"
}
