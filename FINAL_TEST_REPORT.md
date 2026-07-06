# Final Test Report Template

## Project Name

Linux Lab Management Toolkit

## Date

YYYY-MM-DD

## Control Node Used

- Hostname:
- Operating system:
- Ansible version:
- Operator:

## Lab Scope

- Number of PCs tested:
- Inventory group used:
- Test location:

## Playbooks Tested

- [ ] `playbooks/00_preflight_check.yml`
- [ ] `playbooks/01_check_connection.yml`
- [ ] `playbooks/02_collect_lab_status.yml`
- [ ] `playbooks/03_update_system.yml`
- [ ] `playbooks/04_install_required_software.yml`
- [ ] `playbooks/05_copy_shared_materials.yml`
- [ ] `playbooks/06_clean_lab_computers.yml`
- [ ] `playbooks/07_reboot_if_required.yml`

## Results Table

| Playbook | Limit used | Result | Notes |
|---|---|---|---|
| `00_preflight_check.yml` | `pc1` | Pass/Fail | |
| `01_check_connection.yml` | `pc1` | Pass/Fail | |
| `02_collect_lab_status.yml` | `pc1` | Pass/Fail | |
| `03_update_system.yml` | `pc1` | Pass/Fail | |
| `04_install_required_software.yml` | `pc1` | Pass/Fail | |
| `05_copy_shared_materials.yml` | `pc1` | Pass/Fail | |
| `06_clean_lab_computers.yml` | `pc1` | Pass/Fail | |
| `07_reboot_if_required.yml` | `pc1` | Pass/Fail | |

## Reachable PCs

- pc1:
- pc2:
- pc3:

## Unreachable PCs

- pcX:

## Problems Found

- Problem:
- Affected host:
- Error message:
- Cause:

## Fixes Applied

- Fix:
- Host:
- Result:

## Screenshots / Evidence

- Terminal output saved in `reports/`:
- Photos/screenshots:
- Manual verification notes:

## Final Conclusion

State whether the toolkit is ready for professor handover, needs small fixes, or needs more lab testing.

## Remaining Limitations

- Machines not tested:
- Features not tested:
- Known lab/network limitations:

## Future Improvements

- Improve documentation based on professor feedback.
- Add more tested examples to `reports/`.
- Adjust package list for real course needs.
