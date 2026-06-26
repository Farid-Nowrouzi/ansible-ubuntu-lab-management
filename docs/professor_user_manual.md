# Professor User Manual

---

# Linux Laboratory Management Toolkit

**Version:** 1.0

**Purpose**

This manual explains how to use the Linux Laboratory Management Toolkit to manage Ubuntu laboratory computers using Ansible.

The toolkit is designed for instructors and laboratory administrators who want to perform common management tasks on multiple computers from a single control computer without manually configuring every workstation.

The playbooks included in this project are intended to simplify routine maintenance while remaining safe, repeatable, and easy to understand.

---

# Intended Audience

This toolkit is intended for:

* Professors
* Laboratory Administrators
* Teaching Assistants
* Future Internship Students
* IT Staff responsible for the Linux laboratory

Only basic Linux knowledge is required.

---

# System Overview

The toolkit follows a simple architecture.

```
Professor Computer
(Control Node)

        │
        │ SSH + Ansible
        ▼

Student PCs
(Managed Nodes)

        │

Playbooks

        │

Automatic execution
```

The professor's computer acts as the **Control Node**.

Every student computer acts as a **Managed Node**.

No software changes are made manually on each workstation once Ansible has been configured.

---

# Daily Workflow

A typical maintenance session follows these steps.

## Step 1 — Open the project

Navigate to the project directory.

```
cd linux-lab-management
```

---

## Step 2 — Verify connectivity

Before running any maintenance tasks, verify that all computers are reachable.

Run:

```
ansible-playbook -i inventory.ini playbooks/01_check_connection.yml
```

If every computer responds successfully, continue.

If one or more computers are unreachable, consult the Troubleshooting Guide.

---

## Step 3 — Collect current laboratory status

Gather information about each computer.

```
ansible-playbook -i inventory.ini playbooks/02_collect_lab_status.yml
```

This playbook collects information such as:

* hostname
* operating system
* disk usage
* memory
* CPU
* uptime
* network information

No system changes are made.

---

## Step 4 — Update Ubuntu systems

To update installed packages:

```
ansible-playbook -i inventory.ini playbooks/03_update_system.yml
```

This updates:

* package lists
* installed software
* security updates

Rebooting is intentionally handled separately.

---

## Step 5 — Install required software

To install software required for laboratory activities:

```
ansible-playbook -i inventory.ini playbooks/04_install_required_software.yml
```

Examples include:

* Python
* Python Pip
* Git
* Additional educational software

The list of packages can easily be modified inside the playbook.

---

## Step 6 — Distribute laboratory materials

To copy teaching material to every student computer:

```
ansible-playbook -i inventory.ini playbooks/05_copy_shared_materials.yml
```

Typical files include:

* laboratory exercises
* PDF notes
* datasets
* programming assignments

All files should first be placed inside:

```
shared_materials/
```

before running the playbook.

---

## Step 7 — Clean laboratory computers

Routine maintenance can be performed using:

```
ansible-playbook -i inventory.ini playbooks/06_clean_lab_computers.yml
```

Current tasks include:

* apt autoremove
* apt autoclean

No user files are deleted.

---

## Step 8 — Reboot only when necessary

Some updates require a restart.

Instead of rebooting every machine unnecessarily, run:

```
ansible-playbook -i inventory.ini playbooks/07_reboot_if_required.yml
```

Only computers that actually require a reboot will restart.

---

# Inventory Management

The laboratory computers are defined inside:

```
inventory.ini
```

Each computer contains:

* logical name
* IP address
* SSH user

Example:

```
pc1 ansible_host=172.xxx.xxx.xxx ansible_user=student
```

When adding a new laboratory computer:

1. Configure SSH.
2. Verify network connectivity.
3. Add the computer to `inventory.ini`.
4. Test connectivity using the connection playbook.

---

# Recommended Order of Operations

For routine laboratory maintenance, use the following order:

1. Check connections
2. Collect system information
3. Install required software (if needed)
4. Update Ubuntu packages
5. Copy teaching materials
6. Clean unused packages
7. Reboot only if required

This sequence minimizes unnecessary interruptions.

---

# Before Running Any Playbook

Always verify:

* all student computers are powered on
* network connectivity is available
* SSH authentication works
* inventory.ini is up to date
* SSH keys are correctly configured

Never assume every workstation is online.

---

# Safety Recommendations

Always follow these guidelines.

* Test new playbooks on a single computer first.
* Use `--check` whenever possible before making changes.
* Never upload `inventory.ini` to a public repository.
* Never store passwords inside Git.
* Keep SSH private keys secure.
* Avoid modifying multiple playbooks simultaneously without testing.

---

# Customization

This project has been designed to be easily extended.

New playbooks can be added inside:

```
playbooks/
```

Additional software packages may be added by modifying:

```
04_install_required_software.yml
```

Teaching materials can be updated simply by replacing files inside:

```
shared_materials/
```

No changes to the rest of the project are required.

---

# Logs and Reports

Whenever maintenance is performed, it is recommended to record:

* date
* operator
* executed playbooks
* affected computers
* observations
* errors encountered

Reports may be stored inside:

```
reports/
```

Maintaining records helps future administrators understand previous maintenance activities.

---

# Troubleshooting

If a playbook fails:

1. Read the Ansible error message carefully.
2. Verify SSH connectivity.
3. Confirm the computer exists in `inventory.ini`.
4. Verify network connectivity.
5. Confirm sudo privileges.
6. Consult:

```
docs/troubleshooting.md
```

---

# Additional Documentation

This project includes several supporting documents.

| Document                 | Purpose                                           |
| ------------------------ | ------------------------------------------------- |
| setup_guide.md           | Initial installation and first-time configuration |
| maintenance_checklist.md | Routine maintenance checklist                     |
| troubleshooting.md       | Common problems and solutions                     |
| PROJECT_STATUS.md        | Current project progress                          |
| CHANGELOG.md             | History of project changes                        |

---

# Final Notes

This toolkit was developed to simplify the management of Ubuntu laboratory computers while promoting reproducible, safe, and well-documented administrative practices.

The modular structure allows future instructors and students to extend the project with additional playbooks as laboratory requirements evolve.

Always validate new playbooks on a single workstation before deploying them across the entire laboratory.
