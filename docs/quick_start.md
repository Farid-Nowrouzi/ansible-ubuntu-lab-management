# Quick Start Guide

## Ansible-Based Linux/Ubuntu Lab Management System

This guide is the fast operating guide for using the Ansible lab management toolkit.

It is intended for someone who already has the laboratory mostly configured and wants to quickly run the most common commands.

For complete first-time setup from zero, read:

```text
docs/setup_guide.md
```

For troubleshooting, read:

```text
docs/troubleshooting.md
```

For routine maintenance, read:

```text
docs/maintenance_checklist.md
```

For changing packages, shared-materials destination, or safe maintenance settings, read:

```text
docs/customization_guide.md
```

For the main professor handover guide, read:

```text
docs/professor_handover.md
```

---

## 1. Who This Guide Is For

This guide is for:

* the professor;
* a lab assistant;
* a future internship student;
* an IT staff member;
* anyone who needs to quickly manage the Ubuntu student PCs from the teacher/main computer.

This guide assumes that:

* the teacher/main computer has Ansible installed;
* student computers have SSH enabled;
* SSH keys or SSH access are already configured;
* `inventory.ini` exists on the teacher/main computer;
* the project folder exists on the teacher/main computer.

If those are not ready yet, use:

```text
docs/setup_guide.md
```

---

## 2. System in One Sentence

The teacher/main computer uses Ansible over SSH to run safe, repeatable administrative tasks on multiple Ubuntu student computers.

```text
Teacher/Main PC
     |
     | Ansible + SSH
     |
Student PCs
```

---

## 3. Open the Project

On the teacher/main computer, open Terminal.

Go to the project directory:

```bash
cd ~/linux-lab-management
```

Check that the main files exist:

```bash
ls
```

You should see something similar to:

```text
README.md
ansible.cfg
config/
inventory.ini
inventory.example.ini
playbooks/
docs/
shared_materials/
reports/
```

If `inventory.ini` is missing, Ansible will not know which student computers to manage.

Normal lab settings such as package lists and shared-materials destination are in:

```text
config/lab_settings.yml
```

---

## 4. Check the Inventory

List the student PCs known to Ansible:

```bash
ansible -i inventory.ini students --list-hosts
```

Expected result:

```text
hosts (N):
  pc1
  pc2
  pc3
  ...
```

This confirms that:

* `inventory.ini` exists;
* the `[students]` group exists;
* Ansible can read the list of managed computers.

If this fails, check:

```text
docs/troubleshooting.md
```

---

## 5. Check Basic Ansible Connectivity

Run:

```bash
ansible -i inventory.ini students -m ping
```

Expected successful result:

```text
SUCCESS
ping: pong
```

This command is safe.

It does not install, update, delete, or reboot anything.

It only checks whether Ansible can communicate with the student PCs.

---

## 6. Run the Preflight Check First

Run:

```bash
ansible-playbook -i inventory.ini playbooks/00_preflight_check.yml
```

Purpose:

```text
Checks inventory availability, SSH connectivity, Python 3, sudo access, OS compatibility, disk space, memory, and basic host identity.
```

This is the recommended first step before any update, install, cleanup, or reboot activity.

For one PC only:

```bash
ansible-playbook -i inventory.ini playbooks/00_preflight_check.yml --limit pc1
```

If password-based SSH and sudo authentication are required, use:

```bash
ansible-playbook -i inventory.ini playbooks/00_preflight_check.yml --ask-pass --ask-become-pass
```

---

## 7. Run the Connection Playbook

Run:

```bash
ansible-playbook -i inventory.ini playbooks/01_check_connection.yml
```

Purpose:

```text
Confirms that all reachable student PCs can be contacted through Ansible.
```

Run this before any maintenance task.

If a computer is unreachable, do not continue with update/install/reboot tasks until the issue is understood.

---

## 8. Collect Lab Status

Run:

```bash
ansible-playbook -i inventory.ini playbooks/02_collect_lab_status.yml
```

Purpose:

```text
Collects basic system information from the student computers.
```

Typical information may include:

* hostname;
* Ubuntu version;
* IP address;
* kernel;
* memory information;
* disk information;
* uptime or system facts.

This playbook is read-only and safe.

It should normally be run before maintenance.

---

## 9. Golden Rule: Test One PC First

For any playbook that changes the system, test one computer first.

Example:

```bash
ansible-playbook -i inventory.ini playbooks/04_install_required_software.yml --limit pc1
```

The `--limit pc1` option means:

```text
Run only on pc1.
```

Recommended workflow:

```text
One PC first
     |
Small group
     |
All reachable PCs
```

Do not immediately run update, install, cleanup, or reboot tasks on all machines without testing.

---

## 10. Install Required Software

Test on one PC first:

```bash
ansible-playbook -i inventory.ini playbooks/04_install_required_software.yml --limit pc1
```

Then, after confirming it works:

```bash
ansible-playbook -i inventory.ini playbooks/04_install_required_software.yml
```

Purpose:

```text
Installs required laboratory packages.
```

Typical starter packages include:

* vim;
* htop;
* curl;
* git;
* tree;
* python3;
* python3-pip.

To change the package list, edit:

```text
config/lab_settings.yml
```

---

## 11. Copy Teaching Materials

Place approved teaching files inside:

```text
shared_materials/
```

Example:

```text
shared_materials/
|-- lecture_notes.pdf
|-- exercise_01.py
|-- dataset.csv
`-- instructions.txt
```

Test on one PC first:

```bash
ansible-playbook -i inventory.ini playbooks/05_copy_shared_materials.yml --limit pc1
```

Then run on all reachable student PCs:

```bash
ansible-playbook -i inventory.ini playbooks/05_copy_shared_materials.yml
```

Important:

```text
Only files inside shared_materials/ are copied.
Private files from the teacher/main computer are not copied.
The destination is controlled by config/lab_settings.yml.
```

---

## 12. Update Ubuntu Packages

Run this only when approved and not during class time.

Test on one PC first:

```bash
ansible-playbook -i inventory.ini playbooks/03_update_system.yml --limit pc1
```

Then, after confirming it works:

```bash
ansible-playbook -i inventory.ini playbooks/03_update_system.yml
```

Purpose:

```text
Updates Ubuntu package lists and upgrades installed packages.
```

The update behavior is controlled by `config/lab_settings.yml`.

This playbook should not reboot machines automatically.

Rebooting is handled separately by:

```text
playbooks/07_reboot_if_required.yml
```

---

## 13. Clean Package Cache

Test on one PC first if desired:

```bash
ansible-playbook -i inventory.ini playbooks/06_clean_lab_computers.yml --limit pc1
```

Then run:

```bash
ansible-playbook -i inventory.ini playbooks/06_clean_lab_computers.yml
```

Purpose:

```text
Runs safe apt cleanup tasks such as autoremove and autoclean.
```

This should not delete student files.

Do not add destructive delete commands without approval.

Cleanup options are controlled by `config/lab_settings.yml`.

---

## 14. Reboot Only If Required

Run only when safe and approved.

Test on one PC first:

```bash
ansible-playbook -i inventory.ini playbooks/07_reboot_if_required.yml --limit pc1
```

Then run on all reachable PCs:

```bash
ansible-playbook -i inventory.ini playbooks/07_reboot_if_required.yml
```

Purpose:

```text
Reboots only machines where Ubuntu reports that a reboot is required.
```

Avoid running this during active teaching sessions.

---

## 15. Recommended Quick Maintenance Sequence

For a normal maintenance session, use this order:

```bash
cd ~/linux-lab-management

ansible -i inventory.ini students --list-hosts

ansible-playbook -i inventory.ini playbooks/00_preflight_check.yml

ansible-playbook -i inventory.ini playbooks/01_check_connection.yml

ansible-playbook -i inventory.ini playbooks/02_collect_lab_status.yml
```

Then, only if needed and approved:

```bash
ansible-playbook -i inventory.ini playbooks/04_install_required_software.yml --limit pc1

ansible-playbook -i inventory.ini playbooks/05_copy_shared_materials.yml --limit pc1

ansible-playbook -i inventory.ini playbooks/03_update_system.yml --limit pc1
```

After successful one-PC testing, remove `--limit pc1`.

---

## 16. Professor Menu and Logging

Run the lab management menu:

```bash
./labmanage
```

In the menu, enter a number from `1` to `9`. Type `q`, `quit`, or `exit` to leave the menu.

If needed, make the launcher executable first:

```bash
chmod +x labmanage scripts/manage_lab.sh scripts/run_with_logging.sh
./labmanage
```

Save playbook output to `reports/`:

```bash
bash scripts/run_with_logging.sh playbooks/00_preflight_check.yml
bash scripts/run_with_logging.sh playbooks/01_check_connection.yml --limit pc1
```

After real lab testing, fill:

```text
FINAL_TEST_REPORT.md
```

---

## 17. Useful Command Reference

### Go to project folder

```bash
cd ~/linux-lab-management
```

### List known student PCs

```bash
ansible -i inventory.ini students --list-hosts
```

### Ping all student PCs

```bash
ansible -i inventory.ini students -m ping
```

### Ping one student PC

```bash
ansible -i inventory.ini pc1 -m ping
```

### Run a playbook on all PCs

```bash
ansible-playbook -i inventory.ini playbooks/01_check_connection.yml
```

### Run a playbook on one PC

```bash
ansible-playbook -i inventory.ini playbooks/01_check_connection.yml --limit pc1
```

### Check playbook syntax

```bash
ansible-playbook --syntax-check playbooks/01_check_connection.yml
```

### Run with more detailed output

```bash
ansible-playbook -i inventory.ini playbooks/01_check_connection.yml -vv
```

---

## 18. Understanding Common Ansible Output

Ansible may show words such as:

```text
ok
changed
failed
unreachable
```

Meaning:

```text
ok          = the task completed successfully and no change was needed
changed     = the task completed successfully and changed something
failed      = the task reached the machine but failed
unreachable = Ansible could not connect to the machine
```

If you see `failed` or `unreachable`, stop and check the issue before continuing.

---

## 19. Safety Warnings

Do not run these on all computers without approval:

```text
04_install_required_software.yml
05_copy_shared_materials.yml
03_update_system.yml
06_clean_lab_computers.yml
07_reboot_if_required.yml
```

Always follow:

```text
Run preflight first -> test one PC -> confirm result -> then full lab
```

Never commit these to GitHub:

```text
inventory.ini
SSH private keys
passwords
personal files
```

---

## 20. If Something Fails

Use this troubleshooting order:

```text
1. Check if the PC is powered on.
2. Check network cable.
3. Ping the student PC.
4. Try manual SSH.
5. Check inventory.ini.
6. Run Ansible ping.
7. Run the playbook with --limit pc1.
8. Read docs/troubleshooting.md.
```

Useful commands:

```bash
ping <student-ip>
ssh <username>@<student-ip>
ansible -i inventory.ini pc1 -m ping
ansible-playbook -i inventory.ini playbooks/01_check_connection.yml --limit pc1 -vv
```

---

## 21. Where to Go Next

| Need                                     | Read                            |
| ---------------------------------------- | ------------------------------- |
| Full installation from zero              | `docs/setup_guide.md`           |
| Main professor handover                  | `docs/professor_handover.md`    |
| How the professor should use the toolkit | `docs/professor_user_manual.md` |
| How to add a new student PC              | `docs/adding_new_pc.md`         |
| How to change packages/settings safely   | `docs/customization_guide.md`   |
| Common errors and fixes                  | `docs/troubleshooting.md`       |
| Weekly/monthly maintenance               | `docs/maintenance_checklist.md` |
| Playbook details                         | `docs/playbook_reference.md`    |
| Security rules                           | `docs/security_guidelines.md`   |
| Short architecture overview              | `docs/project_overview.md`      |
| System architecture                      | `docs/project_architecture.md`  |
| Current project progress                 | `PROJECT_STATUS.md`             |
| Project changes                          | `CHANGELOG.md`                  |
| Final test report template               | `FINAL_TEST_REPORT.md`          |

---

## 22. Final Reminder

This quick start guide is for fast operation.

For first-time setup, complete explanation, and troubleshooting, use the full documentation.

The safest operating rule is:

```text
Run the preflight check first.
Check connection second.
Collect status third.
Test changes on one PC.
Apply to all only after confirmation.
```
