# RHCSA MiniLab Roadmap

## v0.9.0 - Quality Improvements

### Intelligent objective selection
- [ ] Eliminate all objectives that pass the baseline audit.
- [ ] Document baseline audit workflow for developers in README.
- [ ] Balance categories across exams
- [ ] Prevent repetitive objective combinations
- [ ] Split resource families into finer groups
- [ ] Fill remaining slots intelligently

### Objective wording improvements
- [ ] Eliminate hidden assumptions
- [ ] Improve permissions objectives
- [ ] State initial permissions when testing sticky/setgid bits
- [ ] Clarify archive wording
- [ ] Clarify service wording
- [ ] Review all objectives for ambiguity

### Grading polish
- [ ] Fix discovered grading bugs
- [ ] Keep grading strict
- [ ] Continue real-world exam testing

---

## v1.0.0 - Single Node Mode (Default)

### Single node support
- [ ] Make single-node mode the default
- [ ] Do not modify redhat.repo
- [ ] Use CDN repositories normally
- [ ] No server VM required

### Capability-aware objective filtering
- [ ] Exclude NFS objectives in single-node mode
- [ ] Add capability flags
- [ ] Filter objective pool automatically

### Configuration flags
- [ ] ENABLE_SERVER
- [ ] ENABLE_NFS
- [ ] ENABLE_PODMAN
- [ ] ENABLE_ANSIBLE
- [ ] ENABLE_RECOVERY

---

## v1.1.0 - Multi-Node Support

##Practice Modes
- [ ] Add category-specific practice exams.
- [ ] Support commands such as:
      ./launch-exam storage
      ./launch-exam networking
      ./launch-exam selinux
      ./launch-exam users
      ./launch-exam systemd
      ./launch-exam firewall
      ./launch-exam containers

- [ ] Restrict objective selection to the requested category while
      preserving existing importance and resource-group rules.

- [ ] Update README with recommended study workflows.

### Server VM objectives
- [ ] NFS objectives
- [ ] Additional NFS variants
- [ ] HTTP objectives
- [ ] Database objectives
- [ ] Future rsync objectives

### Multi-machine capabilities
- [ ] Internal repositories
- [ ] Shared services
- [ ] Capability detection

---

## v1.2.0 - Optional Categories

### Podman
- [ ] Podman objectives
- [ ] Optional category
- [ ] Disable by default

### Ansible
- [ ] Ansible objectives
- [ ] Optional category
- [ ] Disable by default

---

## v2.0.0 - Recovery Mode

### Boot recovery
- [ ] Root password recovery
- [ ] GRUB recovery
- [ ] SELinux relabeling
- [ ] Broken bootloader scenarios
- [ ] Separate recovery exam mode

---

## Future Ideas

### Statistics
- [ ] Track exams completed
- [ ] Track scores
- [ ] Category statistics
- [ ] Progress reports

### Reporting
- [ ] Historical scores
- [ ] Objective frequency analysis
- [ ] Weak area reporting

### CI
- [ ] Automated tests
- [ ] Objective validation
- [ ] Grading validation

### Objective Expansion
- [ ] More variants
- [ ] More SELinux objectives
- [ ] More storage objectives
- [ ] More networking objectives

### Continue Practicing
- [ ] Let real usage drive development
