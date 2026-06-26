Replace `docs/playbook_reference.md` with this:

````markdown
# Playbook Reference

## Ansible-Based Linux/Ubuntu Lab Management System

This document explains every playbook included in the project.

Use this file when you want to understand:

- what each playbook does;
- when to use it;
- whether it changes the student PCs;
- whether it requires administrator privileges;
- which command to run;
- what safety rules to follow.

---

## Recommended Execution Order

| Order | Playbook | Purpose | Safety Level |
|---|---|---|---|
| 1 | `01_check_connection.yml` | Check Ansible connection | Safe |
| 2 | `02_collect_lab_status.yml` | Collect system information | Safe |
| 3 | `04_install_required_software.yml` | Install required packages | Test one PC first |
| 4 | `05_copy_shared_materials.yml` | Copy teaching materials | Test one PC first |
| 5 | `03_update_system.yml` | Update Ubuntu packages | Approval recommended |
| 6 | `06_clean_lab_computers.yml` | Clean package cache | Approval recommended |
| 7 | `07_reboot_if_required.yml` | Reboot only if needed | Run only when safe |

---

## One-PC-First Rule

Before running a system-changing playbook on all student PCs, test one PC first.

Example:

```bash
ansible-playbook -i inventory.ini playbooks/04_install_required_software.yml --limit pc1
````

After confirming success, run without `--limit`.

---

## Playbook Summary Table

| Playbook                           | Changes System? | Requires `become`? | Main Use                     |
| ---------------------------------- | --------------: | -----------------: | ---------------------------- |
| `01_check_connection.yml`          |              No |                 No | Verify Ansible communication |
| `02_collect_lab_status.yml`        |              No |                 No | Collect status/facts         |
| `03_update_system.yml`             |             Yes |                Yes | Update packages              |
| `04_install_required_software.yml` |             Yes |                Yes | Install required software    |
| `05_copy_shared_materials.yml`     |             Yes |                Yes | Copy approved files          |
| `06_clean_lab_computers.yml`       |             Yes |                Yes | Clean apt cache/packages     |
| `07_reboot_if_required.yml`        |             Yes |                Yes | Conditional reboot           |

---

## 1. `01_check_connection.yml`

### Purpose

Checks whether the teacher/main computer can communicate with the student PCs through Ansible.

### When to Use

Use this before every maintenance session.

### Command

```bash
ansible-playbook -i inventory.ini playbooks/01_check_connection.yml
```

### Test One PC

```bash
ansible-playbook -i inventory.ini playbooks/01_check_connection.yml --limit pc1
```

### Changes the System?

No.

### Requires Sudo?

No.

### Safety Notes

This is a safe diagnostic playbook. It does not install, update, copy, delete, or reboot anything.

---

## 2. `02_collect_lab_status.yml`

### Purpose

Collects useful system information from the student computers.

Information may include:

* hostname;
* Ubuntu version;
* kernel;
* IP addresses;
* memory;
* disk information;
* system facts.

### When to Use

Use this before updates, software installation, or general maintenance.

### Command

```bash
ansible-playbook -i inventory.ini playbooks/02_collect_lab_status.yml
```

### Test One PC

```bash
ansible-playbook -i inventory.ini playbooks/02_collect_lab_status.yml --limit pc1
```

### Changes the System?

No.

### Requires Sudo?

No.

### Safety Notes

This is read-only and safe.

---

## 3. `03_update_system.yml`

### Purpose

Updates Ubuntu package lists and upgrades installed packages on student PCs.

### When to Use

Use during scheduled maintenance, not during active class time.

### Command

```bash
ansible-playbook -i inventory.ini playbooks/03_update_system.yml
```

### Test One PC

```bash
ansible-playbook -i inventory.ini playbooks/03_update_system.yml --limit pc1
```

### Changes the System?

Yes.

### Requires Sudo?

Yes.

### Safety Notes

* Test on one PC first.
* Run only with professor/lab approval.
* Do not run during class.
* Reboot is handled separately by `07_reboot_if_required.yml`.

---

## 4. `04_install_required_software.yml`

### Purpose

Installs required software packages for the laboratory.

Current starter packages may include:

* `vim`
* `htop`
* `curl`
* `git`
* `tree`
* `net-tools`
* `python3`
* `python3-pip`

### When to Use

Use when preparing computers for teaching, exercises, or administration.

### Command

```bash
ansible-playbook -i inventory.ini playbooks/04_install_required_software.yml
```

### Test One PC

```bash
ansible-playbook -i inventory.ini playbooks/04_install_required_software.yml --limit pc1
```

### Changes the System?

Yes.

### Requires Sudo?

Yes.

### Safety Notes

To add more software, edit the `required_packages` list inside the playbook.

---

## 5. `05_copy_shared_materials.yml`

### Purpose

Copies approved teaching files from:

```text
shared_materials/
```

to the configured destination on student PCs.

### When to Use

Use before a class or lab session when files need to be distributed.

### Command

```bash
ansible-playbook -i inventory.ini playbooks/05_copy_shared_materials.yml
```

### Test One PC

```bash
ansible-playbook -i inventory.ini playbooks/05_copy_shared_materials.yml --limit pc1
```

### Changes the System?

Yes.

### Requires Sudo?

Yes.

### Safety Notes

Only files placed inside `shared_materials/` are copied. This does not share the whole teacher/main computer.

---

## 6. `06_clean_lab_computers.yml`

### Purpose

Performs safe package cleanup.

Typical actions:

* `apt autoremove`
* `apt autoclean`

### When to Use

Use during scheduled maintenance to free package cache space.

### Command

```bash
ansible-playbook -i inventory.ini playbooks/06_clean_lab_computers.yml
```

### Test One PC

```bash
ansible-playbook -i inventory.ini playbooks/06_clean_lab_computers.yml --limit pc1
```

### Changes the System?

Yes.

### Requires Sudo?

Yes.

### Safety Notes

This should not delete student files. Do not add destructive delete commands without approval.

---

## 7. `07_reboot_if_required.yml`

### Purpose

Reboots only machines where Ubuntu reports that a reboot is required.

### When to Use

Use after system updates, when safe and approved.

### Command

```bash
ansible-playbook -i inventory.ini playbooks/07_reboot_if_required.yml
```

### Test One PC

```bash
ansible-playbook -i inventory.ini playbooks/07_reboot_if_required.yml --limit pc1
```

### Changes the System?

Yes. It may reboot machines.

### Requires Sudo?

Yes.

### Safety Notes

Do not run during active class time. This playbook should reboot only when `/var/run/reboot-required` exists.

---

## Common Ansible Output

| Output        | Meaning                                  |
| ------------- | ---------------------------------------- |
| `ok`          | Task succeeded and no change was needed  |
| `changed`     | Task succeeded and changed something     |
| `failed`      | Task reached the machine but failed      |
| `unreachable` | Ansible could not connect to the machine |
| `skipped`     | Task was intentionally skipped           |

---

## Quick Command Reference

### List student PCs

```bash
ansible -i inventory.ini students --list-hosts
```

### Ping all student PCs

```bash
ansible -i inventory.ini students -m ping
```

### Ping one PC

```bash
ansible -i inventory.ini pc1 -m ping
```

### Run safe connection check

```bash
ansible-playbook -i inventory.ini playbooks/01_check_connection.yml
```

### Run status collection

```bash
ansible-playbook -i inventory.ini playbooks/02_collect_lab_status.yml
```

### Syntax check a playbook

```bash
ansible-playbook --syntax-check playbooks/01_check_connection.yml
```

---

## Final Safety Rule

For all playbooks that change the system:

```text
Test one PC first → confirm result → run on all reachable PCs
```

```
```
