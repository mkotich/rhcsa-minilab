RHCSA MiniLab
INSTALLATION GUIDE

========================================================================
OVERVIEW
========================================================================

RHCSA MiniLab supports three installation methods:

    1. Standalone Installation
    2. Dual-System Lab (Recommended)
    3. Developer Installation


========================================================================
1. STANDALONE INSTALLATION
========================================================================

A standalone installation runs the complete RHCSA MiniLab on a single
RHEL system.

Recommended for:

    * Individual practice
    * Quick testing
    * Development


------------------------------------------------------------------------
REQUIREMENTS
------------------------------------------------------------------------

    * RHEL 10
    * Active Red Hat subscription
    * Internet connectivity
    * Root access


------------------------------------------------------------------------
RHEL INSTALLATION
------------------------------------------------------------------------

Software Selection

    Server

Disk Configuration

    Automatic partitioning

Networking

    DHCP (default)

Create User

    Username : student
    Password : redhat

Root Account

    Enabled

    Password:

        redhat

    Permit SSH login.

No additional customization is required during installation.


------------------------------------------------------------------------
PREPARATION
------------------------------------------------------------------------

Register the system:

    subscription-manager register

Clone the repository:

    cd /opt
    git clone https://github.com/mkotich/rhcsa-minilab.git

Run the preparation script:

    cd /opt/rhcsa-minilab
    ./system-prep.sh

NOTE

system-prep.sh configures the system for RHCSA MiniLab.

If your IP address changes, reconnect using the new address and rerun
system-prep.sh if requested.

Launch your first exam:

    ./launch-exam.sh small


========================================================================
2. DUAL-SYSTEM LAB (RECOMMENDED)
========================================================================

The recommended deployment consists of two virtual machines.

SERVER

    Purpose

        * Repository
        * NFS Server
        * Shared Services

    Software Selection

        Server

    Disk Configuration

        Automatic partitioning

    Networking

        DHCP

    User

        Username : student
        Password : redhat

    Root

        Enabled

        Password:

            redhat

        Permit SSH login.


CLIENT

    Purpose

        * Student workstation
        * Exam system

    Software Selection

        Server

    Disk Configuration

        Automatic partitioning

    IMPORTANT

        Attach an additional virtual disk before installing RHEL.

        The additional disk is used for storage and LVM objectives.

    Networking

        DHCP

    User

        Username : student
        Password : redhat

    Root

        Enabled

        Password:

            redhat

        Permit SSH login.


Preparation

    Register both systems:

        subscription-manager register

    Clone the repository on both systems:

        cd /opt
        git clone https://github.com/mkotich/rhcsa-minilab.git

    Run on BOTH systems:

        cd /opt/rhcsa-minilab
        ./system-prep.sh

    Launch exams from the CLIENT.


========================================================================
3. DEVELOPER INSTALLATION
========================================================================

Developer installations follow the Dual-System installation.

Recommended tools

    git
    vim
    bash-completion

Typical workflow

    git pull

    ./reset-lab.sh

    ./launch-exam.sh nightmare

    ./grade-exam.sh

After making changes, validate the project:

    ./validate-project.sh


========================================================================
VERIFYING THE INSTALLATION
========================================================================

Launch a small exam:

    ./launch-exam.sh small

Expected results

    * Exam launches successfully.
    * Required resources are prepared.
    * Scenarios are applied.
    * /home/student/EXAM.txt is created.

Immediately grading a newly-created exam should result in all assigned
objectives reporting FAIL, indicating that the student has work to do.


========================================================================
TROUBLESHOOTING
========================================================================

If system-prep.sh changes the system IP address:

    * Reconnect using the new address.
    * Rerun system-prep.sh if requested.

If an exam fails to launch:

    ./validate-project.sh

    ./reset-lab.sh

    ./launch-exam.sh small


========================================================================
ADDITIONAL DOCUMENTATION
========================================================================

README.md

    Project overview and feature documentation.

STATUS.txt

    Current development status.

CHANGELOG.md

    Project history and release notes.

LICENSE

    GNU General Public License v3.
