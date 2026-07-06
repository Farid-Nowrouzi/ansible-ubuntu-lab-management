# Professor Handover Guide

## Linux Lab Management Toolkit

This document is the main handover guide for the professor.

It explains what the project does, how to start it, which files to edit, and how to operate it safely in a real Ubuntu/Linux computer laboratory.

---

## 1. What This Project Does

This project lets a teacher or professor manage Ubuntu student lab computers from one teacher/main computer.

The teacher/main computer uses:

```text
Ansible + SSH
```

to run safe, repeatable tasks on multiple student PCs.

Typical tasks include:

- checking whether student PCs are reachable;
- collecting basic lab status information;
- installing required software packages;
- copying teaching materials to student computers;
- updating Ubuntu packages;
- cleaning package cache safely;
- rebooting only when Ubuntu says a reboot is required.

The professor normally starts the system with:

```bash
./labmanage
```

In the menu, enter a number from `1` to `9`. Type `q`, `quit`, or `exit` to leave the menu.

---

## 2. What Problem It Solves

Without this toolkit, the professor or lab assistant may need to log into each student PC manually.

That is slow and easy to do inconsistently.

This toolkit solves that by allowing the professor to:

- manage many student PCs from one place;
- run the same checked command on selected computers;
- test on one PC before applying changes to the full lab;
- keep logs and evidence in `reports/`;
- change normal lab settings without editing Ansible playbooks.

---

## 3. Quick Start

From the teacher/main computer:

```bash
cd ~/linux-lab-management
./labmanage
```

If the launcher is not executable yet:

```bash
chmod +x labmanage scripts/manage_lab.sh scripts/run_with_logging.sh
./labmanage
```

First safe checks:

```bash
ansible-playbook -i inventory.ini playbooks/00_preflight_check.yml
ansible-playbook -i inventory.ini playbooks/01_check_connection.yml
ansible-playbook -i inventory.ini playbooks/02_collect_lab_status.yml
```

For a changing task, test one PC first:

```bash
ansible-playbook -i inventory.ini playbooks/04_install_required_software.yml --limit pc1
```

---

## 4. Daily Workflow

Use this workflow for normal lab maintenance:

1. Open Terminal on the teacher/main computer.
2. Go to the project folder.
3. Start the professor menu with `./labmanage`.
4. Run the preflight check.
5. Run the connection check.
6. Collect lab status.
7. If a changing task is needed, choose the target carefully.
8. Review the final action summary before confirming.
9. Test on one PC first.
10. Expand to a small group.
11. Run on the full lab only after smaller tests succeed.
12. Save and review logs in `reports/`.

Recommended command-line version:

```bash
cd ~/linux-lab-management

ansible-playbook -i inventory.ini playbooks/00_preflight_check.yml
ansible-playbook -i inventory.ini playbooks/01_check_connection.yml
ansible-playbook -i inventory.ini playbooks/02_collect_lab_status.yml
```

---

## 5. Files The Professor Edits

### `inventory.ini`

This private file controls which student PCs are managed.

Edit it when:

- adding a new student PC;
- removing a student PC;
- correcting an IP address;
- correcting an SSH username.

Example:

```ini
[students]
pc1 ansible_host=192.168.1.101 ansible_user=student
pc2 ansible_host=192.168.1.102 ansible_user=student
```

Do not commit `inventory.ini`.

---

### `config/lab_settings.yml`

This safe settings file controls normal lab behavior.

Edit it when changing:

- packages to install;
- shared-materials destination;
- shared-materials owner and permissions;
- update behavior;
- cleanup behavior;
- disk and memory thresholds;
- reboot timeout.

For details, read:

```text
docs/customization_guide.md
```

---

### `shared_materials/`

Put teaching files here before copying them to student PCs.

Examples:

```text
shared_materials/
|-- lecture_notes.pdf
|-- exercise_01.py
|-- dataset.csv
`-- instructions.txt
```

Do not put passwords, SSH keys, private professor files, or sensitive student data in this folder.

---

## 6. Files The Professor Should Normally Not Edit

Do not edit these during normal operation:

- `playbooks/`
- `scripts/manage_lab.sh`
- `scripts/run_with_logging.sh`
- `labmanage`
- `ansible.cfg`

These files contain the toolkit logic.

Normal settings should be changed in:

```text
config/lab_settings.yml
```

Student PC connection details should be changed in:

```text
inventory.ini
```

---

## 7. Common Operations

### Start the menu

```bash
./labmanage
```

### Run preflight check

```bash
ansible-playbook -i inventory.ini playbooks/00_preflight_check.yml
```

### Check connections

```bash
ansible-playbook -i inventory.ini playbooks/01_check_connection.yml
```

### Collect status

```bash
ansible-playbook -i inventory.ini playbooks/02_collect_lab_status.yml
```

### Install required software

```bash
ansible-playbook -i inventory.ini playbooks/04_install_required_software.yml --limit pc1
```

After one-PC testing:

```bash
ansible-playbook -i inventory.ini playbooks/04_install_required_software.yml
```

### Copy teaching materials

```bash
ansible-playbook -i inventory.ini playbooks/05_copy_shared_materials.yml --limit pc1
```

### Update Ubuntu packages

```bash
ansible-playbook -i inventory.ini playbooks/03_update_system.yml --limit pc1
```

### Clean package cache

```bash
ansible-playbook -i inventory.ini playbooks/06_clean_lab_computers.yml --limit pc1
```

### Reboot only if required

```bash
ansible-playbook -i inventory.ini playbooks/07_reboot_if_required.yml --limit pc1
```

---

## 8. Safety Checklist

Before using the toolkit, confirm:

- the teacher/main computer is on the lab network;
- Ansible is installed on the teacher/main computer;
- `inventory.ini` exists;
- student PCs are powered on;
- student PCs are connected to the network;
- SSH access works;
- the professor approves any changing action;
- no active class work will be interrupted.

---

## 9. Before Running Any Changing Playbook

Changing playbooks include:

- `03_update_system.yml`
- `04_install_required_software.yml`
- `05_copy_shared_materials.yml`
- `06_clean_lab_computers.yml`
- `07_reboot_if_required.yml`

Before running them:

1. Run the preflight check.
2. Run the connection check.
3. Confirm the target PCs are correct.
4. Review the menu summary before typing the final confirmation.
5. Test on one PC with `--limit pc1`.
6. Verify the result manually if needed.
7. Expand to a small group.
8. Run on all reachable PCs only after successful testing.

Never start with the full lab for a changing action.

---

## 10. Best Practices

- Use `./labmanage` for normal operation.
- Keep `inventory.ini` private.
- Keep `config/lab_settings.yml` free of secrets.
- Put only approved teaching files in `shared_materials/`.
- Save useful outputs in `reports/`.
- Test one PC first.
- Do not run updates or reboots during active class time.
- Read error messages before retrying.
- Record final lab validation in `FINAL_TEST_REPORT.md`.

---

## 11. What Not To Do

Do not:

- commit `inventory.ini`;
- commit passwords or SSH private keys;
- put private files in `shared_materials/`;
- edit playbooks for normal package or destination changes;
- run reboot during class;
- run changing playbooks on all PCs before testing one PC;
- delete generated reports before reviewing them;
- add complex external systems unless the lab explicitly needs them.

---

## 12. Logs And Reports

Logs and evidence are stored in:

```text
reports/
```

The menu uses the logging helper when available.

Manual logged run:

```bash
bash scripts/run_with_logging.sh playbooks/00_preflight_check.yml
```

Reports may contain hostnames, usernames, IP addresses, and task output. Review them before sharing.

---

## 13. Where To Find Help

| Need | Read |
| --- | --- |
| Fast operating commands | `docs/quick_start.md` |
| Full professor manual | `docs/professor_user_manual.md` |
| Change packages/settings | `docs/customization_guide.md` |
| Add a new student PC | `docs/adding_new_pc.md` |
| Understand the project quickly | `docs/project_overview.md` |
| Detailed architecture | `docs/project_architecture.md` |
| Playbook details | `docs/playbook_reference.md` |
| Troubleshooting | `docs/troubleshooting.md` |
| Maintenance checklist | `docs/maintenance_checklist.md` |
| Security rules | `docs/security_guidelines.md` |

---

## 14. Final Handover Summary

The professor only needs to remember:

```text
./labmanage runs the system
inventory.ini controls which PCs are managed
config/lab_settings.yml controls packages/settings
shared_materials/ contains files to copy
reports/ contains logs/evidence
```

Run preflight first, test one PC first, and expand only after confirming the result.
