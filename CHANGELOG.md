# Changelog

All notable changes to this project will be documented in this file.

## Unreleased - Controlled Lab Testing Preparation

### Added

- Added privilege-management playbooks 08-11 and student auto-login playbooks
  12-13 with menu integration.

### Changed

- Hardened menu confirmations, explicit-target handling, and unsafe command
  option filtering.
- Hardened the logging helper's inventory filtering and secret-safe rejection.
- Updated central settings for privilege, auto-login, update-cache, and cleanup
  behavior.
- Code audit fixes now use `apt_cache_valid_time_seconds` and
  `clean_temp_files_older_than`, validate SSH public keys, and fail safely on
  ambiguous display-manager detection.

### Pending validation

- Ubuntu PC0 Ansible syntax checks and controlled pc1 real-lab testing remain
  pending. This changelog does not claim a completed full-lab rollout.

## Student privilege management extension

- Added playbooks 08-11 to create/check `labadmin`, safely revoke student sudo, and grant it back when required.
- Added student-aware shared-material delivery, configuration variables, menu integration, and documentation.
- Added student auto-login management playbooks and menu integration.

## [0.1.0] - Initial Toolkit Foundation

### Added

- Initial Ansible project structure.
- Safe example inventory file.
- Local private inventory support through .gitignore.
- Ansible configuration file.
- Core playbooks for connection testing, status collection, package updates, software installation, shared material distribution, cleanup, and conditional reboot.
- Documentation folder with setup guide, professor user manual, maintenance checklist, and troubleshooting guide.
- Project status tracking document.
- Lab test plan for safe validation in the real computer lab.
- Shared materials folder for controlled file distribution.
- Reports folder for future lab outputs.

### Security

- Added inventory.ini to .gitignore.
- Excluded SSH private keys and sensitive files from Git.
- Kept real lab inventory separate from safe example inventory.

### Notes

- Version 0.1.0 is a starter toolkit.
- Playbooks must be tested first on one student PC before applying them to the full lab.


## [0.2.0] - Preflight Safety Check

### Added

- Added a new read-only preflight playbook to validate inventory, SSH connectivity, Python 3, sudo access, OS compatibility, disk space, memory, and basic host identity before risky actions.
- Documented the preflight workflow in the README, quick start guide, playbook reference, professor manual, test plan, and project status files.

### Notes

- The new preflight playbook should be run before updates, installs, cleanup tasks, shared material copy, or reboot actions.

## [0.3.0] - Final Practical Handover Polish

### Added

- Added root `labmanage` launcher so the professor can open the menu with `./labmanage`.
- Added `scripts/manage_lab.sh`, a simple menu for running the existing lab playbooks.
- Added `scripts/run_with_logging.sh` for saving Ansible output into `reports/`.
- Added `FINAL_TEST_REPORT.md` as a real-lab validation template.

### Changed

- Updated documentation to use the final workflow: preflight, connection check, status collection, one-PC testing, small-group testing, then full lab.
- Updated documentation to make `./labmanage` the primary professor-facing command.
- Improved generated-output protection in `.gitignore`.
- Cleaned selected playbook safety notes and class-time warnings.

## [0.4.0] - Central Lab Settings

### Added

- Added `config/lab_settings.yml` as a safe central settings file for professor-editable lab defaults.
- Added `docs/customization_guide.md` explaining how to change packages, shared-materials destination, update behavior, cleanup behavior, thresholds, and reboot timeout.

### Changed

- Updated relevant playbooks to load settings from `config/lab_settings.yml`.
- Updated README, quick start, professor manual, playbook reference, project architecture, lab test plan, and project status documentation.
- Added a short professor-facing reminder in `scripts/manage_lab.sh`.

### Security

- Kept private inventory, passwords, SSH keys, hostnames, and IP addresses out of `config/lab_settings.yml`.

## [0.5.0] - Handover Documentation

### Added

- Added `docs/professor_handover.md` as the main professor-facing handover guide.
- Added `docs/adding_new_pc.md` with a safe step-by-step process for adding a new student lab computer.
- Added `docs/project_overview.md` as a short high-level architecture overview for future maintainers.

### Changed

- Updated README and selected documentation navigation to reference the new handover, new-PC, and overview guides.

## [0.6.0] - Interaction Safety Polish

### Changed

- Improved the professor menu prompt to clearly ask for a number from 1 to 9.
- Added support for blank menu input, leading/trailing spaces, `01` style choices, and `q`/`quit`/`exit`.
- Moved changing-action confirmation after the final action summary so the selected target is visible before approval.
- Added safer target validation and clearer cancellation behavior.
- Improved advanced option handling so menu target and inventory choices cannot be accidentally overridden.
- Improved logging helper error handling for interrupted runs and unwritable `reports/` directories.
- Updated professor-facing documentation to describe the menu exit behavior and final confirmation step.

## [0.7.0] - Historical Documentation Draft (Superseded)

### Changed

- Polished `FINAL_TEST_REPORT.md` into a clean final validation report template.
- Updated shared-materials settings to use the Ansible login user dynamically for the destination, owner, and group.
- Improved advanced-options handling so blank, `n`, `no`, and `none` are treated as no advanced options.
- Clarified the case-sensitive capital `YES` reboot confirmation.
- Improved unreachable-host result messaging while preserving the real Ansible exit code.
- Updated project status documentation at that time.

### Notes

- Do not treat this historical section as evidence that the current privilege
  management, auto-login workflow, Ubuntu syntax checks, or full-lab rollout
  have been completed.
