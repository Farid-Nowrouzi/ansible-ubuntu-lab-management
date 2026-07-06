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
| 1 | `00_preflight_check.yml` | Verify lab readiness before risky actions | Safe and read-only |
| 2 | `01_check_connection.yml` | Check Ansible connection | Safe |
| 3 | `02_collect_lab_status.yml` | Collect system information | Safe |
| 4 | `04_install_required_software.yml` | Install required packages | Test one PC first |
| 5 | `05_copy_shared_materials.yml` | Copy teaching materials | Test one PC first |
| 6 | `03_update_system.yml` | Update Ubuntu packages | Approval recommended |
| 7 | `06_clean_lab_computers.yml` | Clean package cache | Approval recommended |
| 8 | `07_reboot_if_required.yml` | Reboot only if needed | Run only when safe |

---

## Recommended Workflow

1. Run the preflight check.
2. Run the connection check.
3. Collect lab status.
4. Test update, install, copy, clean, or reboot on one PC first using `--limit`.
5. Expand to a small group.
6. Run on all reachable student PCs only after the checks are successful.

Normal settings for packages, shared-materials destination, updates, cleanup, preflight thresholds, and reboot timeout are stored in `config/lab_settings.yml`.

---

## One-PC-First Rule

Before running a system-changing playbook on all student PCs, test one PC first.

Example:

```bash
ansible-playbook -i inventory.ini playbooks/04_install_required_software.yml --limit pc1
```

After confirming success, run without `--limit`.

---

## Playbook Summary Table

| Playbook | Changes System? | Requires become? | Main Use |
|---|---:|---:|---|
| `00_preflight_check.yml` | No | Yes, only for a harmless check | Verify lab readiness before risky tasks |
| `01_check_connection.yml` | No | No | Verify Ansible communication |
| `02_collect_lab_status.yml` | No | No | Collect status/facts |
| `03_update_system.yml` | Yes | Yes | Update packages |
| `04_install_required_software.yml` | Yes | Yes | Install required software |
| `05_copy_shared_materials.yml` | Yes | Yes | Copy approved files |
| `06_clean_lab_computers.yml` | Yes | Yes | Clean apt cache/packages |
| `07_reboot_if_required.yml` | Yes | Yes | Conditional reboot |

---

## 1. `00_preflight_check.yml`

### Purpose

Runs a read-only safety check before updates, installs, cleanup, shared material copy, or reboot actions.

It verifies:

- the inventory contains a non-empty `students` group;
- SSH/Ansible connectivity;
- Python 3 availability;
- sudo/become access using a harmless `whoami` command;
- Ubuntu or Debian-family Linux compatibility;
- free disk space on `/`;
- total memory;
- host identity details.

Uses `config/lab_settings.yml` for `minimum_free_disk_gb` and `minimum_memory_mb_warning`.

### Commands

```bash
ansible-playbook playbooks/00_preflight_check.yml
ansible-playbook playbooks/00_preflight_check.yml --limit pc1
ansible-playbook playbooks/00_preflight_check.yml --ask-pass --ask-become-pass
```

### Changes the System?

No.

### Requires Sudo?

Yes, only to confirm that become access works. It does not make changes.

### Safety Notes

This playbook is intentionally read-only. Run it before maintenance playbooks so problems are found before a task changes the lab computers.

---

## 2. `01_check_connection.yml`

### Purpose

Checks whether the teacher/main computer can communicate with the student PCs through Ansible.

### When to Use

Use this before every maintenance session, after the preflight check.

### Command

```bash
ansible-playbook -i inventory.ini playbooks/01_check_connection.yml
ansible-playbook -i inventory.ini playbooks/01_check_connection.yml --limit pc1
```

### Changes the System?

No.

### Requires Sudo?

No.

### Safety Notes

This is a safe diagnostic playbook. It does not install, update, copy, delete, or reboot anything.

---

## 3. `02_collect_lab_status.yml`

### Purpose

Collects useful system information from the student computers, such as hostname, Ubuntu version, kernel, IP addresses, memory, disk information, and system facts.

### Command

```bash
ansible-playbook -i inventory.ini playbooks/02_collect_lab_status.yml
ansible-playbook -i inventory.ini playbooks/02_collect_lab_status.yml --limit pc1
```

### Changes the System?

No.

### Requires Sudo?

No.

### Safety Notes

This is read-only and safe.

---

## 4. `03_update_system.yml`

### Purpose

Updates Ubuntu package lists and upgrades installed packages on student PCs.

### Command

```bash
ansible-playbook -i inventory.ini playbooks/03_update_system.yml --limit pc1
ansible-playbook -i inventory.ini playbooks/03_update_system.yml
```

### Changes the System?

Yes.

### Requires Sudo?

Yes.

### Safety Notes

- Test on one PC first.
- Run only with professor/lab approval.
- Do not run during class.
- Reboot is handled separately by `07_reboot_if_required.yml`.
- Uses `config/lab_settings.yml` for package cache refresh, package upgrade, and autoremove behavior.

---

## 5. `04_install_required_software.yml`

### Purpose

Installs required software packages for the laboratory.

### Command

```bash
ansible-playbook -i inventory.ini playbooks/04_install_required_software.yml --limit pc1
ansible-playbook -i inventory.ini playbooks/04_install_required_software.yml
```

### Changes the System?

Yes.

### Requires Sudo?

Yes.

### Safety Notes

To add more software, edit the `required_packages` list in `config/lab_settings.yml`.

---

## 6. `05_copy_shared_materials.yml`

### Purpose

Copies approved teaching files from `shared_materials/` to the configured destination on student PCs.

### Command

```bash
ansible-playbook -i inventory.ini playbooks/05_copy_shared_materials.yml --limit pc1
ansible-playbook -i inventory.ini playbooks/05_copy_shared_materials.yml
```

### Changes the System?

Yes.

### Requires Sudo?

Yes.

### Safety Notes

Only files placed inside `shared_materials/` are copied. This does not share the whole teacher/main computer.

The source, destination, owner, group, and permissions are controlled by `config/lab_settings.yml`.

---

## 7. `06_clean_lab_computers.yml`

### Purpose

Performs safe package cleanup, such as `apt autoremove` and `apt autoclean`.

### Command

```bash
ansible-playbook -i inventory.ini playbooks/06_clean_lab_computers.yml --limit pc1
ansible-playbook -i inventory.ini playbooks/06_clean_lab_computers.yml
```

### Changes the System?

Yes.

### Requires Sudo?

Yes.

### Safety Notes

This should not delete student files. Do not add destructive delete commands without approval.

Cleanup switches are controlled by `config/lab_settings.yml`.

---

## 8. `07_reboot_if_required.yml`

### Purpose

Reboots only machines where Ubuntu reports that a reboot is required.

### Command

```bash
ansible-playbook -i inventory.ini playbooks/07_reboot_if_required.yml --limit pc1
ansible-playbook -i inventory.ini playbooks/07_reboot_if_required.yml
```

### Changes the System?

Yes. It may reboot machines.

### Requires Sudo?

Yes.

### Safety Notes

Do not run during active class time. This playbook should reboot only when `/var/run/reboot-required` exists.

The reboot timeout is controlled by `config/lab_settings.yml`.

---

## Common Ansible Output

| Output | Meaning |
|---|---|
| `ok` | Task succeeded and no change was needed |
| `changed` | Task succeeded and changed something |
| `failed` | Task reached the machine but failed |
| `unreachable` | Ansible could not connect to the machine |
| `skipped` | Task was intentionally skipped |

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

### Run the preflight check

```bash
ansible-playbook playbooks/00_preflight_check.yml
```

### Run the preflight check on one PC

```bash
ansible-playbook playbooks/00_preflight_check.yml --limit pc1
```

### Run the preflight check with password prompts

```bash
ansible-playbook playbooks/00_preflight_check.yml --ask-pass --ask-become-pass
```

### Run safe connection check

```bash
ansible-playbook -i inventory.ini playbooks/01_check_connection.yml
```

### Run status collection

```bash
ansible-playbook -i inventory.ini playbooks/02_collect_lab_status.yml
```

### Run with output logging

```bash
bash scripts/run_with_logging.sh playbooks/00_preflight_check.yml
bash scripts/run_with_logging.sh playbooks/01_check_connection.yml --limit pc1
```

### Run the menu helper

```bash
./labmanage
```

### Syntax check a playbook

```bash
ansible-playbook playbooks/00_preflight_check.yml --syntax-check
```

---

## Final Safety Rule

For all playbooks that change the system:

```text
Run preflight first -> test one PC -> confirm result -> run on all reachable PCs
```
