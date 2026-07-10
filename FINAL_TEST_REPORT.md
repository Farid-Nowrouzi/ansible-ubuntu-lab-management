# Final Test Report

## Project Name

**Linux/Ubuntu Lab Management Toolkit**

## Project Type

Erasmus Internship Technical Project

## Repository

`ansible-ubuntu-lab-management`

## Operator / Tester

**Farid Nowrouzi**

## Test Date

**2026-07-06**

---

## Current Scope Note

This report records earlier validation of the core lab-management workflow. It
does **not** prove that playbooks 08-13, the labadmin/student hardening model,
or graphical student auto-login have completed Ubuntu syntax checks or real-lab
testing. Those checks remain pending in `LAB_TEST_PLAN.md`.

---

# 1. Test Report Purpose

This document records the final validation of the **Linux/Ubuntu Lab Management Toolkit**, an Ansible-based system created to help a professor or laboratory maintainer manage multiple Ubuntu student computers from a central control computer.

The purpose of this final test report is to confirm that the toolkit was not only implemented, but also tested in a real laboratory environment.

The validation focused on the following goals:

- Confirm that the inventory works correctly.
- Confirm that Ansible can connect to the student PCs.
- Confirm that the professor-friendly `labmanage` launcher works.
- Confirm that the safe/read-only playbooks work on one PC, multiple PCs, and the full available lab group.
- Confirm that maintenance playbooks work safely when tested on one PC.
- Confirm that shared materials can be copied to student PCs.
- Confirm that copied files can be verified on the remote PCs.
- Confirm that logging works and saves execution evidence.
- Confirm that reboot logic works safely on one unused PC.
- Identify and fix final usability problems discovered during real lab testing.

---

# 2. Control Node Used

## Control Computer

- **Role:** Ansible control node / professor-side control computer
- **User used during testing:** `student`
- **Project directory:** `/home/student/ansible-ubuntu-lab-management`
- **Operating system:** Ubuntu/Linux laboratory control machine
- **Launcher used:** `./labmanage`
- **Inventory file used:** `inventory.ini`
- **Configuration file used:** `config/lab_settings.yml`

## Validation Methods Used

The toolkit was tested using both:

1. Direct Ansible commands.
2. The professor-friendly `./labmanage` interactive menu.

This confirmed both the internal Ansible playbook functionality and the external user-facing workflow.

---

# 3. Lab Scope

## Inventory Group

The main inventory group tested was:

```ini
[students]
```

This group represents the configured Ubuntu student lab computers.

## Configured Lab Hosts

The inventory contained **7 configured student PCs**.

During full-group testing, most configured PCs were reachable and one configured PC was unreachable/offline.

## Reachable / Validated PCs

The following PCs were reachable and successfully validated during testing:

- `pc1`
- `pc2`
- `pc4`
- `pc7`
- `pc9`
- `pc11`

## Unreachable PC During Testing

The following PC was configured in the inventory but unreachable during testing:

- `pc3`

The unreachable host was most likely powered off, unavailable, or not reachable on the network at the time of testing.

This was not treated as a toolkit failure. The toolkit correctly reported the host as unreachable while continuing to run successfully on the reachable hosts.

---

# 4. Playbooks Tested

The following playbooks were included in the validation process:

- [x] `playbooks/00_preflight_check.yml`
- [x] `playbooks/01_check_connection.yml`
- [x] `playbooks/02_collect_lab_status.yml`
- [x] `playbooks/03_update_system.yml`
- [x] `playbooks/04_install_required_software.yml`
- [x] `playbooks/05_copy_shared_materials.yml`
- [x] `playbooks/06_clean_lab_computers.yml`
- [x] `playbooks/07_reboot_if_required.yml`

---

# 5. Syntax Validation

Before functional testing, the scripts and playbooks were checked for syntax correctness.

## Bash Script Syntax Checks

The following Bash syntax checks were performed:

```bash
bash -n labmanage
bash -n scripts/manage_lab.sh
bash -n scripts/run_with_logging.sh
```

## Result

- `labmanage`: Passed
- `scripts/manage_lab.sh`: Passed
- `scripts/run_with_logging.sh`: Passed

## Ansible Playbook Syntax Checks

The following Ansible syntax checks were performed:

```bash
ansible-playbook playbooks/00_preflight_check.yml --syntax-check
ansible-playbook playbooks/01_check_connection.yml --syntax-check
ansible-playbook playbooks/02_collect_lab_status.yml --syntax-check
ansible-playbook playbooks/03_update_system.yml --syntax-check
ansible-playbook playbooks/04_install_required_software.yml --syntax-check
ansible-playbook playbooks/05_copy_shared_materials.yml --syntax-check
ansible-playbook playbooks/06_clean_lab_computers.yml --syntax-check
ansible-playbook playbooks/07_reboot_if_required.yml --syntax-check
```

## Result

All playbooks passed syntax validation.

---

# 6. Testing Strategy

The toolkit was validated using a progressive testing strategy.

The testing order was:

1. Test on one PC first.
2. Test on three selected PCs.
3. Test safe workflows against the full `students` group.
4. Run changing/maintenance workflows carefully.
5. Verify results manually and through Ansible commands.
6. Fix usability issues found during real testing.
7. Re-test the corrected workflow.

This approach was used to avoid accidentally affecting all student computers before confirming that each workflow behaved correctly.

---

# 7. One-PC Validation

The first complete validation was performed on:

```text
pc1
```

The purpose of one-PC validation was to confirm that each workflow worked safely before expanding to multiple PCs.

## Tests Performed on `pc1`

| Component | Result | Notes |
|---|---|---|
| Preflight check | Passed | Confirmed SSH, Python, sudo/become, OS, disk, and memory checks |
| Connection check | Passed | Confirmed Ansible could connect using SSH keys |
| Lab status collection | Passed | Host/system information was collected |
| System update workflow | Passed | Tested safely on one PC |
| Required software installation | Passed | Packages were installed or confirmed present |
| Shared materials copy | Passed | Test files were copied successfully |
| Cleanup workflow | Passed | Conservative cleanup settings were used |
| Reboot-if-required workflow | Passed | Reboot logic was validated on one unused PC |
| Logging wrapper | Passed | Logs were generated in `reports/` |
| `labmanage` menu | Passed | Menu successfully executed workflows |

---

# 8. Three-PC Validation

After successful one-PC validation, safe workflows were tested on three selected PCs.

## Target Used

```text
pc1,pc2,pc3
```

The purpose of this step was to confirm that the toolkit works with multiple selected hosts, not only with a single machine.

## Workflows Tested on Three PCs

The following workflows were tested on a small group of PCs:

- Preflight check
- Connection check
- Lab status collection
- Shared materials copy where appropriate
- Menu-based execution through `./labmanage`

## Result

The reachable PCs completed the tested workflows successfully.

If a selected host was unavailable, Ansible reported it as unreachable, which is expected behavior for a powered-off or unavailable lab machine.

---

# 9. Full Students-Group Validation

After one-PC and three-PC testing, the safe workflows were tested against the full inventory group:

```text
students
```

## Purpose

The purpose of this test was to confirm that the toolkit can operate at lab scale using the configured Ansible inventory group.

## Workflows Tested Against `students`

The following safe workflows were tested against the full group of configured student PCs:

- Preflight check
- Connection check
- Lab status collection
- Shared materials distribution where appropriate

## Result Summary

The reachable hosts completed the workflows successfully.

One configured host, `pc3`, was unreachable during testing.

This produced a non-zero Ansible exit code because Ansible treats unreachable hosts as incomplete execution. However, the reachable hosts completed their tasks correctly.

## Interpretation

The correct interpretation of the result is:

```text
The toolkit worked on all reachable lab PCs.
One configured PC was unreachable/offline during testing.
```

This is a valid and useful result because the toolkit correctly identifies which lab computers are available and which ones require attention.

---

# 10. Playbook-by-Playbook Results

## 10.1 `00_preflight_check.yml`

### Purpose

The preflight check validates whether the selected lab machines are ready for Ansible-based management.

It checks:

- Inventory/group availability
- SSH reachability
- Python availability
- Sudo/become access
- Operating system compatibility
- Disk space
- Memory information
- Host identity summary

### Limits Tested

- `pc1`
- `pc1,pc2,pc3`
- `students`

### Result

Passed on reachable hosts.

### Notes

The preflight check correctly reported unreachable hosts when a configured PC was offline or unavailable.

---

## 10.2 `01_check_connection.yml`

### Purpose

The connection check verifies that Ansible can reach the selected student PCs.

### Limits Tested

- `pc1`
- `pc1,pc2,pc3`
- `students`

### Result

Passed on reachable hosts.

### Notes

SSH key-based access was confirmed. The SSH password prompt was not needed because key-based authentication was already configured.

---

## 10.3 `02_collect_lab_status.yml`

### Purpose

This playbook collects useful system information from the lab PCs.

It validates that the control node can collect status information from the managed computers.

### Limits Tested

- `pc1`
- `pc1,pc2,pc3`
- `students`

### Result

Passed on reachable hosts.

### Validated Information

The playbook collected or displayed information such as:

- Hostname
- Operating system information
- Disk information
- Memory information
- General system status

---

## 10.4 `03_update_system.yml`

### Purpose

This playbook updates the system package information and, depending on configuration, can upgrade packages.

### Limit Tested

- `pc1`

### Result

Passed on `pc1`.

### Notes

This workflow was intentionally tested first on one PC because it is a changing maintenance action.

The update configuration was reviewed before execution in:

```bash
config/lab_settings.yml
```

The safer validation approach was used before considering broader execution.

---

## 10.5 `04_install_required_software.yml`

### Purpose

This playbook installs or confirms the presence of required software packages defined in:

```bash
config/lab_settings.yml
```

### Limit Tested

- `pc1`

### Result

Passed on `pc1`.

### Verification

Installed packages were verified using remote commands such as:

```bash
ansible -i inventory.ini pc1 -m command -a "which htop"
ansible -i inventory.ini pc1 -m command -a "which tree"
ansible -i inventory.ini pc1 -m command -a "which git"
```

### Notes

The playbook completed successfully. Packages were either installed or already present.

---

## 10.6 `05_copy_shared_materials.yml`

### Purpose

This playbook copies teaching files from the control PC to the student PCs.

Files placed in:

```bash
shared_materials/
```

are copied to each selected student PC.

### Limits Tested

- `pc1`
- Selected multiple PCs
- Reachable hosts in the `students` group where appropriate

### Result

Passed after configuration was corrected to match real lab usernames.

### Issue Found

During testing, the playbook initially failed because the configured destination used:

```bash
/home/student/Lab_Materials
```

However, the actual user on `pc1` was:

```bash
student123
```

The real user was confirmed with:

```bash
ansible -i inventory.ini pc1 -m command -a "whoami"
ansible -i inventory.ini pc1 -m command -a "id"
```

### Fix Applied

The shared materials configuration was updated to use the Ansible login user dynamically:

```yaml
shared_materials_destination: "/home/{{ ansible_user }}/Lab_Materials"
shared_materials_owner: "{{ ansible_user }}"
shared_materials_group: "{{ ansible_user }}"
```

This allows each PC to receive files inside its own correct user home directory.

### Test Files Used

The following test files were used during validation:

```text
test_ansible_materials.txt
shared_materials_validation_02.txt
```

### Verification Commands

The copied files were verified using commands such as:

```bash
ansible -i inventory.ini pc1 -m shell -a 'ls -la "$HOME/Lab_Materials"'
ansible -i inventory.ini pc1 -m shell -a 'cat "$HOME/Lab_Materials/shared_materials_validation_02.txt"'
```

### Manual Location on Student PC

On `pc1`, the copied files appear in:

```bash
/home/student123/Lab_Materials
```

From the student desktop/file manager, this corresponds to:

```text
Home → Lab_Materials
```

---

## 10.7 `06_clean_lab_computers.yml`

### Purpose

This playbook performs conservative cleanup operations on lab computers.

### Limit Tested

- `pc1`

### Result

Passed on `pc1`.

### Configuration Reviewed

Cleanup settings were reviewed in:

```bash
config/lab_settings.yml
```

The conservative cleanup approach was used during testing.

### Notes

The cleanup test completed successfully and did not remove student files.

---

## 10.8 `07_reboot_if_required.yml`

### Purpose

This playbook reboots a lab PC only when reboot is required.

The playbook checks for the Ubuntu reboot marker:

```bash
/var/run/reboot-required
```

### Limit Tested

- `pc1`

### Result

Passed on `pc1`.

### Validation Performed

The reboot workflow was tested on one unused PC.

The reboot marker was checked using:

```bash
ansible -i inventory.ini pc1 -m stat -a "path=/var/run/reboot-required" -b --ask-become-pass
```

The reboot workflow was executed through `./labmanage`.

After reboot, connectivity was verified again using:

```bash
ansible -i inventory.ini pc1 -m ping
```

### Result

`pc1` rebooted successfully and came back online.

### Safety Note

The reboot workflow was intentionally tested only on one unused PC. It was not run across all lab PCs because rebooting all machines is a maintenance action and should only be performed when appropriate.

---

# 11. `labmanage` Menu Validation

The professor-friendly launcher was tested using:

```bash
./labmanage
```

## Menu Options Tested

The following menu options were tested:

- Option 1: Run preflight check
- Option 2: Check connections
- Option 3: Collect lab status
- Option 4: Update systems
- Option 5: Install required software
- Option 6: Copy shared materials
- Option 7: Clean lab computers
- Option 8: Reboot if required
- Option 9: Exit

## Result

The menu successfully launched the correct workflows.

## Authentication Behavior

The following prompt behavior was validated.

### SSH Password Prompt

For this lab, SSH key-based authentication was already configured.

Therefore, the answer was normally:

```text
Need SSH password prompt? [y/N]: n
```

### Sudo/Admin Password Prompt

For administrative actions such as update, install, cleanup, and reboot, sudo/become may be needed.

Typical answer:

```text
Need sudo/admin password prompt? [y/N]: y
```

For some safe checks, sudo was not required.

### Advanced Ansible Options

Normally, the answer should be:

```text
Add advanced Ansible options? [y/N]: n
```

A usability issue was found and fixed so that if the user accidentally types `n`, `no`, `none`, or leaves the advanced-options field blank, the value is not passed incorrectly to Ansible.

---

# 12. Logging Validation

The logging wrapper was validated through the menu system.

The script:

```bash
scripts/run_with_logging.sh
```

saves command output into:

```bash
reports/
```

## Validation

During testing, execution logs were generated for playbook runs.

The logs included:

- Playbook command output
- Task results
- Host results
- Ansible recap
- Success/failure/unreachable information

## Evidence Location

Execution evidence was saved locally in:

```bash
reports/
```

## GitHub Note

Generated logs were not committed to GitHub because they may contain local environment information such as:

- Hostnames
- IP addresses
- Usernames
- Lab-specific paths
- Ansible output from the real lab environment

This is intentional and follows good privacy/security practice.

---

# 13. Issues Found During Real Lab Testing

## Issue 1: `sshpass` Error When Using `--ask-pass`

### Problem

When `--ask-pass` was used, Ansible reported that `sshpass` was required.

### Cause

The lab was already configured for SSH key-based login, so SSH password mode was not needed.

### Resolution

The SSH password prompt was answered with:

```text
n
```

The toolkit worked correctly using SSH keys.

---

## Issue 2: Shared Materials Username Mismatch

### Problem

The shared materials playbook initially failed when the destination was configured as:

```bash
/home/student/Lab_Materials
```

but the actual remote user was:

```bash
student123
```

### Cause

The destination path and owner/group in the configuration did not match the real lab username.

### Resolution

The configuration was changed to use the Ansible user dynamically:

```yaml
shared_materials_destination: "/home/{{ ansible_user }}/Lab_Materials"
shared_materials_owner: "{{ ansible_user }}"
shared_materials_group: "{{ ansible_user }}"
```

### Result

The shared materials workflow then passed and files were successfully copied and verified.

---

## Issue 3: Advanced Options Input

### Problem

If the user selected advanced options and typed:

```text
n
```

inside the advanced-options field, the script passed `n` to `ansible-playbook`.

This caused an error such as:

```text
ansible-playbook: error: unrecognized arguments: n
```

### Cause

The menu did not treat `n`, `no`, or `none` as empty advanced-options input.

### Resolution

The script was updated so that the following values are treated as no advanced options:

- blank input
- `n`
- `N`
- `no`
- `NO`
- `none`
- `NONE`

### Result

The advanced options prompt is now safer and more beginner-friendly.

---

## Issue 4: Reboot Confirmation Clarity

### Problem

The reboot workflow required capital:

```text
YES
```

but the prompt needed to make this clearer.

### Cause

Lowercase `yes` was not accepted, which is correct for safety, but the professor-facing message needed to explain the rule clearly.

### Resolution

The reboot confirmation prompt was improved to explicitly say that the confirmation is case-sensitive and requires capital `YES`.

### Result

The reboot workflow remains safe while becoming clearer for beginner/professor use.

---

## Issue 5: Full-Group Run Showing Generic Failure Because One PC Was Offline

### Problem

When running against the full `students` group, one PC was unreachable. Ansible returned a non-zero exit code and the wrapper originally displayed a generic failed result.

### Cause

Ansible treats unreachable hosts as incomplete execution, even if all reachable hosts completed successfully.

### Resolution

The logging wrapper was improved to show a friendlier result when hosts are unreachable but reachable hosts complete successfully.

The result message now distinguishes between:

- Complete success
- Completed with unreachable hosts
- Real task failure

### Result

Professor-facing output is now clearer and less misleading.

---

# 14. Final Results Table

| Playbook / Component | Limits Tested | Result | Notes |
|---|---|---|---|
| `00_preflight_check.yml` | `pc1`, `pc1,pc2,pc3`, `students` | Passed on reachable hosts | One host unreachable during full-group test |
| `01_check_connection.yml` | `pc1`, `pc1,pc2,pc3`, `students` | Passed on reachable hosts | SSH key-based access confirmed |
| `02_collect_lab_status.yml` | `pc1`, `pc1,pc2,pc3`, `students` | Passed on reachable hosts | Status information collected |
| `03_update_system.yml` | `pc1` | Passed | Tested safely on one PC |
| `04_install_required_software.yml` | `pc1` | Passed | Required packages installed or confirmed |
| `05_copy_shared_materials.yml` | `pc1`, selected reachable hosts | Passed | Files copied and verified |
| `06_clean_lab_computers.yml` | `pc1` | Passed | Conservative cleanup tested |
| `07_reboot_if_required.yml` | `pc1` | Passed | Reboot tested on one unused PC |
| `labmanage` | Multiple workflows | Passed | Professor-friendly menu validated |
| `run_with_logging.sh` | Multiple workflows | Passed | Logs generated in `reports/` |
| `config/lab_settings.yml` | Real lab settings | Passed after adjustment | Shared materials path made dynamic |

---

# 15. Validation Summary

## Confirmed Working

The following project components were validated successfully:

- GitHub project structure
- Inventory-based host management
- SSH key-based Ansible access
- Professor-friendly launcher
- Interactive menu workflow
- Safe playbook execution
- Preflight validation
- Connection checking
- Lab status collection
- System update workflow
- Software installation workflow
- Shared materials copy workflow
- Cleanup workflow
- Conditional reboot workflow
- Logging/report generation
- Dynamic shared-materials destination
- Handling of unreachable/offline hosts
- Improved beginner-friendly prompts

---

# 16. Remaining Limitations

The toolkit is ready for handover, with the following practical limitations:

## Offline PCs

If a configured PC is powered off or unavailable, Ansible reports it as unreachable.

This is expected behavior.

## Reboot Scope

The reboot workflow was validated on one unused PC. It should only be run on multiple PCs during an appropriate maintenance window.

## Lab-Specific Inventory

The private `inventory.ini` file must be maintained for the real lab environment and should not be committed publicly.

## Logs

Generated logs are stored locally in `reports/` and may contain lab-specific information. They should be reviewed before sharing externally.

## Advanced Infrastructure

This project intentionally remains a lightweight Ansible-based lab-management toolkit. It is not intended to be a full enterprise monitoring, imaging, or cluster-management platform.

---

# 17. Handover Readiness

The toolkit is considered ready for professor review and handover.

The project includes:

- Working Ansible playbooks
- Professor-friendly launcher
- Central configuration file
- Shared materials workflow
- Logging/reporting workflow
- Safety prompts
- Documentation
- Final test validation
- Post-testing usability fixes

The project has been validated in the real Ubuntu laboratory environment on reachable student PCs.

---

# 18. Final Conclusion

The **Linux/Ubuntu Lab Management Toolkit** was successfully implemented and validated during the Erasmus internship.

The toolkit allows a professor or lab maintainer to manage Ubuntu student computers from a central control node using Ansible. It supports connection checks, preflight validation, status collection, system updates, required software installation, shared material distribution, cleanup, conditional reboot handling, and logging.

The validation process confirmed that the toolkit works on individual PCs, selected groups of PCs, and the available reachable hosts in the full `students` inventory group. One configured PC was unreachable during testing, and the toolkit correctly reported it without preventing successful validation of the reachable machines.

Several usability improvements were identified during real testing and applied before final handover, including safer advanced-options handling, clearer reboot confirmation, and improved messaging for unreachable hosts.

Final status:

```text
READY FOR PROFESSOR REVIEW AND HANDOVER
```
