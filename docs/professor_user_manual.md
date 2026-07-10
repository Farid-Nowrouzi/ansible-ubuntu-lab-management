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

## Step 2 — Run the preflight check

Before running any maintenance tasks, verify that the lab is ready and safe.

Run:

```
ansible-playbook -i inventory.ini playbooks/00_preflight_check.yml
```

This playbook is read-only and checks:

* inventory group presence
* SSH connectivity
* Python 3 availability
* sudo/become access
* Ubuntu compatibility
* available disk space
* memory level
* basic host identity information

If any host fails the preflight check, do not continue with updates, installs, cleanup, or reboot tasks until the issue is understood.

The easiest way to operate the toolkit is the professor menu:

```
./labmanage
```

The menu asks for confirmation before update, install, copy, cleanup, or reboot actions.

In the menu, enter a number from `1` to `9`. Type `q`, `quit`, or `exit` to leave the menu.

Normal lab settings such as packages, shared-materials destination, cleanup options, update behavior, preflight thresholds, and reboot timeout are controlled in:

```
config/lab_settings.yml
```

---

## Step 3 — Verify connectivity

After the preflight check passes, verify that all computers are reachable.

Run:

```
ansible-playbook -i inventory.ini playbooks/01_check_connection.yml
```

If every computer responds successfully, continue.

If one or more computers are unreachable, consult the Troubleshooting Guide.

---

## Step 4 — Collect current laboratory status

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

## Step 5 — Update Ubuntu systems

To update installed packages:

```
ansible-playbook -i inventory.ini playbooks/03_update_system.yml
```

This updates:

* package lists
* installed software
* security updates

Rebooting is intentionally handled separately.

Do not run this during active class time. Test one PC first with `--limit pc1`.

---

## Step 6 — Install required software

To install software required for laboratory activities:

```
ansible-playbook -i inventory.ini playbooks/04_install_required_software.yml
```

Examples include:

* Python
* Python Pip
* Git
* Additional educational software

The list of packages can easily be modified in `config/lab_settings.yml`.

Do not run this during active class time unless the professor approves it. Test one PC first with `--limit pc1`.

---

## Step 7 — Distribute laboratory materials

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

The destination path and file ownership are controlled in `config/lab_settings.yml`.

Test one PC first before copying materials to the full lab.

---

## Step 8 — Clean laboratory computers

Routine maintenance can be performed using:

```
ansible-playbook -i inventory.ini playbooks/06_clean_lab_computers.yml
```

Current tasks include:

* apt autoremove
* apt autoclean

No user files are deleted.

Cleanup options are controlled in `config/lab_settings.yml`.

Do not run this during active class time. Test one PC first with `--limit pc1`.

---

## Step 9 — Reboot only when necessary

Some updates require a restart.

Instead of rebooting every machine unnecessarily, run:

```
ansible-playbook -i inventory.ini playbooks/07_reboot_if_required.yml
```

Only computers that actually require a reboot will restart.

Confirm the timing before rebooting. Never reboot during active teaching unless explicitly approved.

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
pc1 ansible_host=172.xxx.xxx.xxx ansible_user=labadmin lab_student_user=student123
```

When adding a new laboratory computer:

1. Configure SSH.
2. Verify network connectivity.
3. Add the computer to `inventory.ini`.
4. Test connectivity using the connection playbook.

---

# Recommended Order of Operations

For routine laboratory maintenance, use the following order:

1. Run the preflight check
2. Check connections
3. Collect system information
4. Install required software (if needed)
5. Update Ubuntu packages
6. Copy teaching materials
7. Clean unused packages
8. Reboot only if required

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

Common lab settings may be changed by modifying:

```
config/lab_settings.yml
```

Teaching materials can be updated simply by replacing files inside:

```
shared_materials/
```

No changes to the rest of the project are required.

Use `inventory.ini` only for the student PC list and connection details. Use `config/lab_settings.yml` for packages and maintenance settings.

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

To save terminal output automatically:

```
bash scripts/run_with_logging.sh playbooks/00_preflight_check.yml
```

After final real-lab testing, fill:

```
FINAL_TEST_REPORT.md
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
| professor_handover.md    | Main professor handover guide                     |
| project_overview.md      | Short architecture overview                       |
| adding_new_pc.md         | Steps for adding a new lab computer               |
| setup_guide.md           | Initial installation and first-time configuration |
| maintenance_checklist.md | Routine maintenance checklist                     |
| customization_guide.md   | Safe package and settings customization           |
| troubleshooting.md       | Common problems and solutions                     |
| PROJECT_STATUS.md        | Current project progress                          |
| CHANGELOG.md             | History of project changes                        |

---

# Final Notes

This toolkit was developed to simplify the management of Ubuntu laboratory computers while promoting reproducible, safe, and well-documented administrative practices.

The modular structure allows future instructors and students to extend the project with additional playbooks as laboratory requirements evolve.

Always validate new playbooks on a single workstation before deploying them across the entire laboratory.
# User Privilege Management

Each student PC uses `labadmin` as the professor/Ansible administrator and a
classroom account such as `student123` as a normal, non-sudo user. Use the safe
order: setup labadmin, check privileges, revoke student sudo, then verify.
Granting sudo restores full administrator power and should be temporary.
Passwords and private inventory details must stay out of the repository.

The setup playbook prefers `~/.ssh/id_ed25519.pub` on PC0 and falls back to
`~/.ssh/id_rsa.pub`. Set `lab_admin_public_key_file` only when another public
key must be used.

### Real-lab acceptance test: pc1

Run this sequence on Ubuntu PC0, testing only `pc1` first. Keep
`inventory.ini` private and set `ansible_user=labadmin` only after its SSH and
sudo access have been verified.

1. Pull the updated repository on PC0.

   ```bash
   cd ~/ansible-ubuntu-lab-management
   git pull origin main
   ```

2. Run local syntax checks on PC0.

   ```bash
   bash -n labmanage
   bash -n scripts/manage_lab.sh
   bash -n scripts/run_with_logging.sh
   ansible-playbook --syntax-check playbooks/08_setup_labadmin_user.yml
   ansible-playbook --syntax-check playbooks/09_check_user_privileges.yml
   ansible-playbook --syntax-check playbooks/10_revoke_student_sudo.yml
   ansible-playbook --syntax-check playbooks/11_grant_student_sudo.yml
   ```

3. Check current privileges on pc1.

   ```bash
   ansible-playbook -i inventory.ini playbooks/09_check_user_privileges.yml --limit pc1 --ask-become-pass
   ```

4. Set up labadmin on pc1 if needed.

   ```bash
   ansible-playbook -i inventory.ini playbooks/08_setup_labadmin_user.yml --limit pc1 --ask-become-pass
   ```

5. Test labadmin SSH.

   ```bash
   ansible -i inventory.ini pc1 -u labadmin -m ping
   ```

6. Test labadmin sudo. Expected result: `root`.

   ```bash
   ansible -i inventory.ini pc1 -u labadmin -m command -a "whoami" -b --ask-become-pass
   ```

7. Revoke sudo from the student account on pc1.

   ```bash
   ansible-playbook -i inventory.ini playbooks/10_revoke_student_sudo.yml --limit pc1 -u labadmin --ask-become-pass
   ```

8. Check privileges again. Expected: labadmin remains in `sudo` and `student123`
   is no longer in `sudo`.

   ```bash
   ansible-playbook -i inventory.ini playbooks/09_check_user_privileges.yml --limit pc1 -u labadmin --ask-become-pass
   ```

9. Test the existing toolkit with labadmin. Expected: `failed=0` and
   `unreachable=0`.

   ```bash
   ansible-playbook -i inventory.ini playbooks/00_preflight_check.yml --limit pc1 -u labadmin --ask-become-pass
   ```

10. Roll back by granting sudo again if required.

    ```bash
    ansible-playbook -i inventory.ini playbooks/11_grant_student_sudo.yml --limit pc1 -u labadmin --ask-become-pass
    ```

11. Check privileges after rollback. Expected: `student123` appears in `sudo`
    again.

    ```bash
    ansible-playbook -i inventory.ini playbooks/09_check_user_privileges.yml --limit pc1 -u labadmin --ask-become-pass
    ```

# Student Auto-Login Management

Student auto-login starts the PC directly in the classroom account, such as
`student123`; it must never target `labadmin`. It does not create an empty
password or reveal the classroom password. Students should normally have sudo
revoked before auto-login is enabled, and physical verification after a reboot
or logout is required.

Configure auto-login on one PC first:

```bash
ansible-playbook -i inventory.ini playbooks/12_configure_student_autologin.yml --limit pc1 -u labadmin --ask-become-pass
```

Disable it when a normal graphical login screen is needed again:

```bash
ansible-playbook -i inventory.ini playbooks/13_disable_student_autologin.yml --limit pc1 -u labadmin --ask-become-pass
```

## Real-lab auto-login acceptance test: pc1

1. Pull the latest project on PC0.

   ```bash
   cd ~/ansible-ubuntu-lab-management
   git pull origin main
   ```

2. Run syntax checks on Ubuntu PC0.

   ```bash
   bash -n labmanage
   bash -n scripts/manage_lab.sh
   bash -n scripts/run_with_logging.sh
   ansible-playbook --syntax-check playbooks/12_configure_student_autologin.yml
   ansible-playbook --syntax-check playbooks/13_disable_student_autologin.yml
   ```

3. Confirm that labadmin works. The sudo command must return `root`.

   ```bash
   ansible -i inventory.ini pc1 -u labadmin -m ping
   ansible -i inventory.ini pc1 -u labadmin -m command -a "whoami" -b --ask-become-pass
   ```

4. Confirm privileges: labadmin has sudo and `student123` does not.

   ```bash
   ansible-playbook -i inventory.ini playbooks/09_check_user_privileges.yml --limit pc1 -u labadmin
   ```

5. Configure student auto-login.

   ```bash
   ansible-playbook -i inventory.ini playbooks/12_configure_student_autologin.yml --limit pc1 -u labadmin --ask-become-pass
   ```

6. Reboot pc1 or physically log out/in. Verify that pc1 opens the student
   desktop automatically, never the labadmin desktop.

7. Verify Ansible access still works after reboot.

   ```bash
   ansible -i inventory.ini pc1 -u labadmin -m ping
   ```

8. Disable auto-login if needed, then reboot or log out and verify that the
   graphical login screen is shown.

   ```bash
   ansible-playbook -i inventory.ini playbooks/13_disable_student_autologin.yml --limit pc1 -u labadmin --ask-become-pass
   ```

# Current Professor Workflow

On Ubuntu PC0, start the menu with:

```bash
chmod +x labmanage
./labmanage
```

The main menu runs preflight, connection, status, update, install, shared
materials, cleanup, reboot-if-required, and the user privilege/auto-login
submenu. The submenu sets up labadmin, checks privileges, revokes or grants
student sudo, and configures or disables student auto-login.

Changing actions require an explicit target and confirmation. Test pc1 first,
then a small group, before considering the full lab.

Use this order: preflight; connection check; setup labadmin; test labadmin SSH
and sudo; check privileges; revoke student sudo; check again; configure student
auto-login; reboot/logout and physically verify. Grant sudo is a temporary
exception/rollback. Disable auto-login is the graphical rollback/control action.

Ubuntu Ansible syntax checks and controlled pc1 testing are pending. This
manual does not claim a completed real-lab or full-lab rollout.
