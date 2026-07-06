# Maintenance Checklist

## Ansible-Based Linux/Ubuntu Lab Management System

This checklist is for the professor, lab assistant, or future student responsible for keeping the Ubuntu computer lab stable, updated, and ready for teaching.

Use this checklist before classes, weekly, monthly, and before/after major maintenance.

---

## 1. Golden Safety Rules

Before running any playbook:

* [ ] Confirm you are on the teacher/main computer.
* [ ] Confirm you are inside the project folder:

```bash
cd ~/linux-lab-management
```

* [ ] Confirm the real inventory file exists:

```bash
ls inventory.ini
```

* [ ] Never run update, install, cleanup, or reboot playbooks during active class time.
* [ ] Run the preflight check before maintenance.
* [ ] Test on one PC first using `--limit`.
* [ ] Do not upload `inventory.ini`, passwords, or SSH keys to GitHub.
* [ ] Ask for approval before rebooting machines.

---

## 2. Quick Health Check

Run this before doing bigger actions.

* [ ] List student PCs from inventory:

```bash
ansible -i inventory.ini students --list-hosts
```

* [ ] Run preflight check:

```bash
ansible-playbook -i inventory.ini playbooks/00_preflight_check.yml
```

* [ ] Check Ansible connectivity:

```bash
ansible -i inventory.ini students -m ping
```

* [ ] Run connection playbook:

```bash
ansible-playbook -i inventory.ini playbooks/01_check_connection.yml
```

* [ ] Record any unreachable machines in `reports/`.

---

## 3. Before Class Checklist

Use this before a teaching session.

* [ ] Confirm required student PCs are powered on.
* [ ] Confirm network/Ethernet cables are connected.
* [ ] Run connection check:

```bash
ansible-playbook -i inventory.ini playbooks/01_check_connection.yml
```

* [ ] Confirm required teaching files are inside:

```text
shared_materials/
```

* [ ] Copy approved teaching materials:

```bash
ansible-playbook -i inventory.ini playbooks/05_copy_shared_materials.yml
```

* [ ] Check one student PC manually to confirm files arrived:

```bash
ssh <username>@<student-ip>
ls ~/Lab_Materials
```

* [ ] Do not run update or reboot playbooks immediately before class unless required and approved.

---

## 4. Weekly Maintenance Checklist

Recommended once per week.

* [ ] Run preflight check:

```bash
ansible-playbook -i inventory.ini playbooks/00_preflight_check.yml
```

* [ ] Run Ansible ping:

```bash
ansible -i inventory.ini students -m ping
```

* [ ] Collect lab status:

```bash
ansible-playbook -i inventory.ini playbooks/02_collect_lab_status.yml
```

* [ ] Check for offline or unreachable machines.
* [ ] Check disk, memory, Ubuntu version, and host information from status output.
* [ ] Save notes in:

```text
reports/
```

* [ ] Update `PROJECT_STATUS.md` if there is an important change.
* [ ] Check whether new student PCs need to be added to `inventory.ini`.

---

## 5. Monthly Maintenance Checklist

Recommended once per month or when approved by the professor.

First test one PC:

```bash
ansible-playbook -i inventory.ini playbooks/03_update_system.yml --limit pc1
```

If successful and approved:

* [ ] Update all reachable student PCs:

```bash
ansible-playbook -i inventory.ini playbooks/03_update_system.yml
```

* [ ] Install or verify required software:

```bash
ansible-playbook -i inventory.ini playbooks/04_install_required_software.yml
```

* [ ] Clean package cache safely:

```bash
ansible-playbook -i inventory.ini playbooks/06_clean_lab_computers.yml
```

* [ ] Check whether reboot is required:

```bash
ansible-playbook -i inventory.ini playbooks/07_reboot_if_required.yml --limit pc1
```

* [ ] Reboot all required machines only when safe and approved:

```bash
ansible-playbook -i inventory.ini playbooks/07_reboot_if_required.yml
```

---

## 6. Semester Start Checklist

Use before a new semester or new course.

* [ ] Confirm all student PCs are physically present and working.
* [ ] Confirm all PCs have Ethernet/network access.
* [ ] Check usernames on all student PCs.
* [ ] Check current IP addresses:

```bash
hostname -I
```

* [ ] Update `inventory.ini` if IPs or usernames changed.
* [ ] Confirm SSH server is installed and running on each PC:

```bash
systemctl status ssh
```

* [ ] Confirm SSH key-based access from teacher PC:

```bash
ssh <username>@<student-ip>
```

* [ ] Run Ansible ping:

```bash
ansible -i inventory.ini students -m ping
```

* [ ] Install required teaching/admin software:

```bash
ansible-playbook -i inventory.ini playbooks/04_install_required_software.yml
```

* [ ] Place new course materials in:

```text
shared_materials/
```

* [ ] Copy materials to student PCs:

```bash
ansible-playbook -i inventory.ini playbooks/05_copy_shared_materials.yml
```

* [ ] Save a semester preparation note in `reports/`.

---

## 7. After Maintenance Checklist

After running updates, installs, copy tasks, cleanup, or reboot:

* [ ] Confirm Ansible finished without critical failures.
* [ ] Review failed/unreachable hosts.
* [ ] Test one affected student PC manually.
* [ ] Confirm important applications open correctly.
* [ ] Confirm copied files are in the expected folder.
* [ ] Save errors or observations in `reports/`.
* [ ] Update `PROJECT_STATUS.md` if progress changed.
* [ ] Update `CHANGELOG.md` if playbooks or documentation changed.

---

## 8. Inventory Maintenance Checklist

Use whenever computers are added, removed, repaired, or reinstalled.

* [ ] Check the student PC hostname:

```bash
hostname
```

* [ ] Check the username:

```bash
whoami
```

* [ ] Check IP address:

```bash
hostname -I
```

* [ ] Test ping from teacher PC:

```bash
ping <student-ip>
```

* [ ] Test SSH:

```bash
ssh <username>@<student-ip>
```

* [ ] Add or update the machine in `inventory.ini`:

```ini
pcX ansible_host=<ip-address> ansible_user=<username>
```

* [ ] Test only that host:

```bash
ansible -i inventory.ini pcX -m ping
```

* [ ] Never commit the real `inventory.ini` to GitHub.

---

## 9. Shared Materials Checklist

Before copying teaching materials:

* [ ] Confirm files are approved for students.
* [ ] Place only approved files in:

```text
shared_materials/
```

* [ ] Check folder contents:

```bash
ls shared_materials/
```

* [ ] Test copy on one PC:

```bash
ansible-playbook -i inventory.ini playbooks/05_copy_shared_materials.yml --limit pc1
```

* [ ] Confirm the file arrived on the student PC.
* [ ] Then copy to all reachable PCs if correct.

Important:
This system does not share the whole teacher computer. It only copies files placed inside `shared_materials/`.

---

## 10. Emergency Checklist

Stop maintenance immediately if:

* [ ] Many PCs fail at once.
* [ ] SSH fails on multiple machines.
* [ ] A playbook affects the wrong folder.
* [ ] A package update breaks software.
* [ ] A reboot starts unexpectedly.
* [ ] You are unsure what the command will do.
* [ ] The professor asks to pause.

Then:

```text
1. Stop running new commands.
2. Record the exact error.
3. Test one PC only.
4. Check docs/troubleshooting.md.
5. Ask for help before continuing.
```

---

## 11. Recommended Routine

### Before each class

```text
Connection check + shared materials check
```

### Weekly

```text
Connectivity + status collection + report notes
```

### Monthly

```text
Updates + software verification + cleanup
```

### Semester start

```text
Inventory verification + software preparation + course materials distribution
```

---

## 12. Maintenance Log Template

Copy this into a new file inside `reports/` after each maintenance session.

````markdown
# Maintenance Report

Date:
Performed by:
Location:
Teacher/Main PC:

## Commands Run

```bash
command here
```

## Successful Machines

- pc1
- pc2

## Failed or Unreachable Machines

- pc3:

## Changes Made

- Updated packages
- Installed software
- Copied materials

## Issues Found

-

## Follow-Up Actions

-
````

For final lab validation, fill:

```text
FINAL_TEST_REPORT.md
```

---

## 13. Final Reminder

A good lab management workflow is not only about running commands.

It is about:

```text
checking first,
testing safely,
recording results,
avoiding unnecessary risk,
and leaving clear notes for the next person.
```

Always follow:

```text
Preflight first -> one PC first -> small group -> full lab
```