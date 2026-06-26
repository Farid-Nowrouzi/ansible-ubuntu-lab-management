# Changelog

All notable changes to this project will be documented in this file.

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


## Planned Improvements

- Add tested lab status report examples.
- Add package list customization.
- Add clearer role-based structure if project grows.
- Add optional reporting output files.
- Add semester preparation checklist.
- Add future support for Docker or shared folder synchronization if needed.
