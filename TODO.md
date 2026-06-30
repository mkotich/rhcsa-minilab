# RHCSA MiniLab TODO
# ==================

Guiding Principles
------------------

- The MiniLab emphasizes system administration over fault hunting.
- Objectives teach administrative skills.
- Scenarios (Intentional Breakages) exist only when required to make an
  objective meaningful.
- Random breakage is intentionally avoided.
- Preparation creates realistic environments; scenarios introduce only the
  minimum breakage necessary to support an objective.

======================================================================

HIGH PRIORITY

[ ] Resource Groups
    [ ] Discover required resource groups from selected objectives.
    [ ] De-duplicate resource groups.
    [ ] Display required resource groups during exam generation.
    [ ] Implement prepare/ framework.
    [ ] Add preparation modules:
            web
            storage
            flatpak
            time
            nfs

[ ] Category Practice Mode
    Examples:
        ./launch-exam category selinux
        ./launch-exam category storage
        ./launch-exam category scripts
        ./launch-exam category firewall

    Goal:
        Practice a single category instead of a mixed exam.

[ ] Archive
    Grader enhancements:
        [ ] Grade extraction to alternate directories
        [ ] Grade archive listings
        [ ] Grade exclusions
        [ ] Grade partial extraction

======================================================================

MEDIUM PRIORITY

[ ] Scenarios (Intentional Breakages)

    Implement ONLY when they directly support an objective.

    Initial scenarios:

        [ ] Restore SELinux contexts
        [ ] Broken /etc/fstab
        [ ] Broken local repository
        [ ] Wrong firewall zone
        [ ] Wrong Chrony configuration
        [ ] Flatpak installed in wrong scope

    Rules:

        - A scenario must exist to support an objective.
        - Avoid random failures.
        - Keep scenarios few in number.
        - Reuse scenarios whenever possible.

[ ] Storage
    [ ] Broken UUID in /etc/fstab
    [ ] Missing filesystem
    [ ] Incorrect mount options
    [ ] Persistent UUID mounting
    [ ] LVM repair exercises

[ ] SELinux
    [ ] AVC investigation
    [ ] restorecon practice
    [ ] Context troubleshooting
    [ ] Port labeling
    [ ] Boolean management

[ ] SSH
    [ ] Login banner
    [ ] Idle timeout
    [ ] User restrictions
    [ ] Alternate SSH port

[ ] Chrony
    [ ] Verification
    [ ] Multiple time sources
    [ ] Server configuration
    [ ] Synchronization troubleshooting

======================================================================

DEVELOPER TOOLS

[ ] Expand --validate-all-objectives

    [ ] Validate resource groups
    [ ] Validate domains
    [ ] Validate category names
    [ ] Detect duplicate objective text (warning)
    [ ] Verify grader exists for every category
    [ ] Objective statistics

======================================================================

FUTURE ENHANCEMENTS

[ ] Domain Practice Mode

    Examples:

        ./launch-exam domain selinux contexts
        ./launch-exam domain firewall services
        ./launch-exam domain storage lvm

[ ] Statistics

    [ ] Objectives by category
    [ ] Objectives by domain
    [ ] Objectives by resource group
    [ ] Difficulty distribution

[ ] Release Workflow

    validate
        ↓
    audit
        ↓
    create baseline

======================================================================

PARKING LOT

- Podman / container objectives
- Ansible objectives
- Complex networking
- Bootloader recovery
- Root password recovery
- Multi-host SSH key management
- Dynamic scenario chaining
