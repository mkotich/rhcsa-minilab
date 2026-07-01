===============================================================================
RHCSA MiniLab TODO
===============================================================================

HIGH PRIORITY
-------------------------------------------------------------------------------

[ ] Eliminate all baseline-passing objectives
    Current:
        Objectives Passing: 11
    Goal:
        Objectives Passing: 0

[ ] Complete remaining NOT IMPLEMENTED graders

[ ] Verify every parameterized objective
    - storage (${SIZE})
    - users
    - networking
    - any remaining templated objectives

[ ] Audit every objective after changes
    ./create-baseline.sh --validate-all-objectives
    ./create-baseline.sh --audit-all-objectives

-------------------------------------------------------------------------------

MEDIUM PRIORITY
-------------------------------------------------------------------------------

[ ] Finish archive grading
[ ] Finish users grading
[ ] Finish remaining scenario coverage
[ ] Review prepare modules for consistency
[ ] Review scenario modules for consistency

-------------------------------------------------------------------------------

LOW PRIORITY
-------------------------------------------------------------------------------

[ ] Improve launch-exam.sh wording
[ ] Improve grade-exam.sh wording
[ ] Add regression test suite
[ ] Add objective expansion unit tests
[ ] Audit code style across libraries
[ ] Cleanup shellcheck warnings

-------------------------------------------------------------------------------

FUTURE
-------------------------------------------------------------------------------

[ ] 125+ objective pool
[ ] Additional scenarios
[ ] Additional repair objectives
[ ] Additional randomized objectives
[ ] Practice exam balancing
[ ] Release packaging
[ ] Documentation review

===============================================================================
