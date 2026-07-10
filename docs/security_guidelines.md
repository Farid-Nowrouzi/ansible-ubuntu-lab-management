# Security Guidelines

## Linux/Ubuntu Lab Management Toolkit

---

# Purpose

This document defines the recommended security practices for operating the Linux/Ubuntu Lab Management Toolkit.

The objective is to ensure that laboratory computers can be managed efficiently while minimizing the risk of accidental system damage, unauthorized access, data loss, or exposure of confidential information.

These guidelines should be followed by professors, laboratory assistants, IT administrators, and future developers who maintain or extend this project.

---

# Security Principles

The project follows several fundamental security principles.

## 1. Least Privilege

Student classroom accounts should not have sudo by default. Separate roles:
`labadmin` is the administrator used by Ansible; `student123` (or the configured
classroom user) is a normal learning account. Grant sudo only for a specific,
controlled task and revoke it afterward.

## Auto-login security considerations

Configure graphical auto-login only for the limited classroom student account,
never for `labadmin`. Auto-login is not an empty password: do not use empty
passwords and do not share the labadmin password with students. Revoke student
sudo before enabling auto-login, then physically verify the account selected at
the desktop after reboot or logout.

## Current Account and SSH Safeguards

`labadmin` is the professor/Ansible administrator. The classroom account
(`student123` by default) should normally not have sudo and is the only valid
auto-login target. Never share the labadmin password with students.

Keep `lab_admin_password_hash` empty in committed configuration. If a hash is
intentionally used, keep it private; never store plaintext passwords. Never
commit SSH private keys, and keep `inventory.ini` private.

The current `ansible.cfg` sets `host_key_checking = False` as a lab
convenience. This is a security trade-off because normal SSH host authenticity
checking is reduced. The professor or maintainer should review it before a
wider rollout.

Logs can contain IP addresses, usernames, hostnames, package details, and
system output. Review them before sharing outside the lab team.

Always perform operations using the lowest level of privilege required.

Only use:

```yaml
become: true
```

when administrator permissions are actually necessary.

Read-only operations such as connection testing or system information collection should not require elevated privileges whenever possible.

---

## 2. Test Before Deploying

Never execute a new playbook on every computer immediately.

Always follow this order:

```text
One PC
      ↓
Small Group
      ↓
Entire Laboratory
```

Example:

```bash
ansible-playbook -i inventory.ini playbooks/03_update_system.yml --limit pc1
```

Only after confirming successful execution should the playbook be applied to additional systems.

---

## 3. Repeatability

Playbooks should be:

* predictable
* repeatable
* idempotent

Running the same playbook multiple times should never damage the operating system or create duplicate configuration.

Always prefer official Ansible modules instead of shell commands whenever possible.

Preferred:

```yaml
ansible.builtin.apt
ansible.builtin.copy
ansible.builtin.file
ansible.builtin.user
```

Avoid:

```yaml
shell:
command:
```

unless absolutely necessary.

---

# Inventory Security

The inventory file contains information about laboratory computers.

Example:

```text
inventory.ini
```

This file should remain private.

Never upload it to a public repository.

The repository should only contain:

```text
inventory.example.ini
```

The real inventory should remain only on the laboratory control computer.

---

# Protect SSH Access

SSH is the foundation of the entire management system.

Recommendations:

* Prefer SSH key authentication.
* Protect private keys using proper file permissions.
* Never share SSH private keys.
* Never store private keys in Git.
* Never send private keys by email or messaging applications.

Check permissions:

```bash
ls -l ~/.ssh
```

Typical permissions:

```text
~/.ssh          700
id_ed25519      600
authorized_keys 600
```

---

# Password Management

Passwords should never appear inside:

* playbooks
* documentation
* Git commits
* screenshots
* configuration files

Do not hardcode passwords.

Avoid commands that expose passwords on the command line.

Whenever possible use SSH keys instead of passwords.

---

# Git Security

The repository intentionally ignores sensitive files.

Never commit:

```text
inventory.ini
```

Never commit:

```text
*.pem
*.key
id_rsa
id_ed25519
authorized_keys
known_hosts
```

Verify before pushing:

```bash
git status
```

If sensitive files appear, remove them before committing.

---

# Protect Student Data

This toolkit is intended for laboratory administration.

It should never be used to:

* inspect personal student files
* collect personal information
* copy private documents
* modify student work without authorization

Only administrative tasks should be automated.

---

# Safe Software Installation

Only install software that has been approved by the instructor or laboratory administrator.

Review package lists before execution.

Example:

```yaml
required_packages:
  - git
  - curl
  - vim
  - htop
```

Avoid installing unnecessary software on shared laboratory systems.

---

# Updating Systems Safely

Updating packages affects every managed machine.

Before updating:

- Verify preflight results.
- Verify connectivity.
- Verify disk space.
- Ensure no important class or laboratory session is running.

Always test updates on one machine first.

---

# Reboot Safety

Unexpected reboots can interrupt classes and ongoing research.

Recommendations:

* reboot only when required
* reboot outside teaching hours
* notify users beforehand if possible

Use the dedicated reboot playbook rather than rebooting manually.

---

# Shared Materials

Only place approved teaching materials inside:

```text
shared_materials/
```

Do not copy:

* confidential documents
* personal files
* passwords
* private datasets

Verify destination paths before copying files.

---

# Reports Directory

Generated reports may contain:

* hostnames
* IP addresses
* hardware information
* operating system versions

Review reports before sharing them externally.

If publishing examples publicly, anonymize sensitive information.

---

# Logging and Auditing

Maintain basic records of administrative actions.

Recommended information includes:

* date
* administrator
* playbook executed
* affected hosts
* result

Example:

```text
2026-06-27
Update System
Hosts: pc1, pc2
Result: Successful
```

This improves accountability and troubleshooting.

---

# Physical Security

Administrative access is only secure if the laboratory itself is secure.

Recommendations:

* lock the teacher workstation when unattended
* prevent unauthorized USB devices when possible
* restrict administrator accounts
* physically secure the control computer

---

# Extending the Project

When creating new playbooks:

- Prefer Ansible modules.
- Avoid destructive shell commands.
- Write descriptive task names.
- Test on one computer first.
- Document new functionality.
- Keep playbooks idempotent.
- Include comments for future maintainers.

---

# Before Every Execution

Verify the following:

* inventory.ini is correct.
* Student PCs are powered on.
* SSH connectivity works.
* Required permissions exist.
* The correct playbook is selected.
* The correct hosts are targeted.
* A backup exists if needed.
* The playbook has been tested previously.

---

# Before Every Git Push

Review:

```bash
git status
```

Confirm that:

* no passwords are present
* no SSH keys are present
* inventory.ini is not staged
* only intended files are committed

---

# Security Checklist

Before running administrative tasks:

* [ ] Inventory verified
* [ ] SSH connectivity confirmed
* [ ] One-PC testing completed
* [ ] No sensitive files in Git
* [ ] Packages reviewed
* [ ] Reports directory checked
* [ ] Instructor approval obtained for system-wide changes
* [ ] Backups available if required

---

# Summary

The security of this toolkit depends on disciplined operational practices rather than complex software.

Following the principles in this document helps ensure that the laboratory remains secure, stable, reproducible, and easy to maintain while reducing the risk of accidental disruption to teaching and research activities.
