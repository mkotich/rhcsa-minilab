# RHCSA MiniLab

RHCSA MiniLab is a lightweight RHCSA v10 practice environment designed for rapid repetition and objective-focused learning.

## Features

- Randomized exam generation
- Human-readable grading
- Fast reset capability
- Dynamic grading libraries
- Persistence verification
- Category limits and resource groups
- Broad RHCSA v10 coverage

Installation Modes

Standalone (default)
--------------------
• One RHEL VM
• Uses existing repositories
• No server required
• NFS objectives automatically omitted

Full Lab
--------
• Client + Server
• Internal HTTP repository
• NFS server
• Full objective pool

## Exam Modes

| Mode | Objectives | Time |
|--------|------------|------|
| mini | 5 | 15 minutes |
| small | 15 | 90 minutes |
| full | 25 | 180 minutes |
| nightmare | 40 | Unlimited |

## Categories

- Users
- Storage
- Services
- Firewall
- SELinux
- Networking
- Cron
- Archives
- ACLs
- Scripts
- Flatpak
- Permissions
- SSH
- Systemd
- Timers
- Time
- Software
- Logging
- Kernel
- NFS

## Usage

Generate an exam:

    ./launch-exam.sh mini
    ./launch-exam.sh small
    ./launch-exam.sh full
    ./launch-exam.sh nightmare

View the exam:

    cat /home/student/EXAM.txt

Grade the exam:

    ./grade-exam.sh

Reset the lab:

    ./reset-lab.sh

Inspect the current exam:

    ./peek-exam.sh

## Design Goals

- Fast repetition
- Objective-oriented grading
- Broad RHCSA coverage
- Minimal infrastructure requirements
- Extensible architecture
- Recovery scenarios kept separate from normal practice

## Current Release

v0.8.0
