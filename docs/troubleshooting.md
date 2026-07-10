# Troubleshooting Guide

## Ansible-Based Linux/Ubuntu Lab Management System

This guide helps solve common problems when setting up or running Ansible in the Ubuntu computer lab.

Use this document when:

* a student PC cannot be reached;
* SSH does not work;
* Ansible ping fails;
* a playbook fails;
* sudo/become does not work;
* file copying fails;
* package installation or updates fail;
* a machine behaves differently from the others.

---

## 1. Troubleshooting Method

Always troubleshoot in this order:

```text
1. Is the student PC powered on?
2. Is the network cable connected?
3. Does the PC have an IP address?
4. Can the teacher PC ping the student PC?
5. Can the teacher PC SSH into the student PC?
6. Does passwordless SSH work?
7. Is the inventory.ini entry correct?
8. Does Ansible ping work?
9. Does the playbook work on one PC with --limit?
10. Does the playbook work on all PCs?
```

Do not start troubleshooting from Ansible first.
Ansible depends on SSH, and SSH depends on the network.

---

## 2. Quick Diagnostic Commands

Run these from the teacher/main computer.

### Check network reachability

```bash
ping <student-ip>
```

Example:

```bash
ping 172.16.0.149
```

Stop with:

```bash
Ctrl + C
```

---

### Test manual SSH

```bash
ssh <username>@<student-ip>
```

Example:

```bash
ssh student@172.16.0.149
```

---

### Test Ansible ping

```bash
ansible -i inventory.ini students -m ping
```

Test one PC only:

```bash
ansible -i inventory.ini pc1 -m ping
```

---

### List inventory hosts

```bash
ansible -i inventory.ini students --list-hosts
```

---

### Run a playbook on one PC only

```bash
ansible-playbook -i inventory.ini playbooks/01_check_connection.yml --limit pc1
```

---

### Check playbook syntax

```bash
ansible-playbook --syntax-check playbooks/01_check_connection.yml
```

---

## 3. Problem: Student PC is Not Reachable

### Symptoms

You may see:

```text
Destination Host Unreachable
Request timeout
UNREACHABLE
No route to host
```

### Possible causes

* Student PC is powered off.
* Ethernet cable is unplugged.
* Wrong IP address is written in `inventory.ini`.
* Student PC is on a different network.
* Network interface is disabled.
* The PC has changed IP address.
* Firewall or routing issue exists.

### What to do

On the student PC, check IP address:

```bash
hostname -I
```

or:

```bash
ip addr
```

On the teacher PC, test ping:

```bash
ping <student-ip>
```

Check physical cable and switch connection.

If the student PC has multiple IP addresses, test each one from the teacher PC and use the reachable IP in `inventory.ini`.

---

## 4. Problem: SSH Service is Not Installed or Not Running

### Symptoms

You may see:

```text
Connection refused
ssh: connect to host <ip> port 22: Connection refused
```

### Meaning

The network may work, but SSH server is not running on the student PC.

### Check on the student PC

```bash
systemctl status ssh
```

### Install SSH server

```bash
sudo apt update
sudo apt install openssh-server
```

### Enable and start SSH

```bash
sudo systemctl enable ssh
sudo systemctl start ssh
```

### Check again

```bash
systemctl status ssh
```

Expected result:

```text
active (running)
```

---

## 5. Problem: SSH Permission Denied

### Symptoms

You may see:

```text
Permission denied
Permission denied (publickey,password)
```

### Possible causes

* Wrong username.
* Wrong password.
* SSH key was not copied.
* The wrong SSH key is being used.
* User account does not exist on that student PC.
* Student PCs use different usernames.

### Check the username

On the student PC:

```bash
whoami
```

Make sure `inventory.ini` uses the same username:

```ini
pc1 ansible_host=172.16.0.149 ansible_user=labadmin lab_student_user=student123
```

### Test manually

```bash
ssh labadmin@172.16.0.149
```

### Copy SSH key again

```bash
ssh-copy-id student@172.16.0.149
```

Then test:

```bash
ssh student@172.16.0.149
```

If it connects without asking for the password, SSH key authentication works.

---

## 6. Problem: Ansible Ping Fails but Manual SSH Works

### Symptoms

Manual SSH works:

```bash
ssh student@172.16.0.149
```

but Ansible fails:

```bash
ansible -i inventory.ini students -m ping
```

### Possible causes

* Wrong inventory group.
* Wrong host alias.
* Wrong `ansible_user`.
* Python is missing on the managed node.
* `ansible_python_interpreter` is incorrect.
* Ansible is using a different inventory file.

### Check inventory

```bash
cat inventory.ini
```

Example:

```ini
[students]
pc1 ansible_host=172.16.0.149 ansible_user=labadmin lab_student_user=student123
```

### List hosts

```bash
ansible -i inventory.ini students --list-hosts
```

### Test one host

```bash
ansible -i inventory.ini pc1 -m ping
```

### If Python is missing

On the student PC:

```bash
sudo apt update
sudo apt install python3
```

In inventory, you may use:

```ini
[students:vars]
ansible_python_interpreter=/usr/bin/python3
```

---

## 7. Problem: Ansible Cannot Find the Inventory

### Symptoms

You may see:

```text
No inventory was parsed
provided hosts list is empty
Could not match supplied host pattern
```

### Possible causes

* You are in the wrong folder.
* `inventory.ini` does not exist.
* You used the wrong group name.
* You used `students` but the inventory group has another name.

### Check current folder

```bash
pwd
ls
```

You should see:

```text
inventory.ini
ansible.cfg
playbooks/
```

### Check inventory exists

```bash
ls inventory.ini
```

### Use explicit inventory path

```bash
ansible -i inventory.ini students -m ping
```

### Check group name

The inventory should contain:

```ini
[students]
```

The command should use:

```bash
students
```

---

## 8. Problem: Sudo or Become Fails

### Symptoms

You may see:

```text
Missing sudo password
sudo: a password is required
This incident will be reported
user is not in the sudoers file
```

### Meaning

The playbook needs administrator privileges, but the remote user cannot use sudo correctly.

### Which playbooks need sudo?

These usually require `become: true`:

```text
03_update_system.yml
04_install_required_software.yml
06_clean_lab_computers.yml
07_reboot_if_required.yml
05_copy_shared_materials.yml if copying to protected locations
```

### Test sudo manually

SSH into the student PC:

```bash
ssh student@172.16.0.149
```

Then run:

```bash
sudo whoami
```

Expected output:

```text
root
```

### If sudo asks for a password

Run Ansible with:

```bash
ansible-playbook -i inventory.ini playbooks/03_update_system.yml --ask-become-pass
```

### If user is not allowed to use sudo

Ask the professor/administrator which user should be used.

Do not try to bypass permissions.

---

## 9. Problem: YAML Syntax Error

### Symptoms

You may see:

```text
Syntax Error while loading YAML
did not find expected key
mapping values are not allowed here
```

### Common causes

* Wrong indentation.
* Missing colon.
* Tabs instead of spaces.
* Incorrect list format.
* Quotation problem.

### Check syntax

```bash
ansible-playbook --syntax-check playbooks/03_update_system.yml
```

### YAML rules

Use spaces, not tabs.

Correct:

```yaml
tasks:
  - name: Example task
    ansible.builtin.ping:
```

Wrong:

```yaml
tasks:
- name Example task
 ansible.builtin.ping
```

---

## 10. Problem: Package Installation Fails

### Symptoms

You may see:

```text
Failed to update apt cache
Unable to locate package
Could not get lock /var/lib/dpkg/lock
Temporary failure resolving
```

### Possible causes

* No internet connection.
* Package name is wrong.
* Another apt process is running.
* Ubuntu repositories are not available.
* DNS problem.
* System update is already running.

### Check internet

On student PC:

```bash
ping 8.8.8.8
ping google.com
```

### Update package list manually

```bash
sudo apt update
```

### Check package name

```bash
apt search <package-name>
```

### If apt is locked

Wait a few minutes, then check:

```bash
ps aux | grep apt
```

Do not delete lock files unless you fully understand the risk.

---

## 11. Problem: File Copy Playbook Fails

### Symptoms

You may see:

```text
Could not find or access '../shared_materials/'
Permission denied
Destination directory does not exist
Failed to set permissions
```

### Possible causes

* `shared_materials/` is empty or missing.
* The relative path is wrong.
* Destination user does not exist.
* Destination directory permission issue.
* Wrong variable name for student user.

### Check source folder

From the project root:

```bash
ls shared_materials/
```

### Add a test file

```bash
echo "Test file from Ansible" > shared_materials/test.txt
```

### Test on one PC

```bash
ansible-playbook -i inventory.ini playbooks/05_copy_shared_materials.yml --limit pc1
```

### Check on student PC

```bash
ssh student@172.16.0.149
ls ~/Lab_Materials
```

---

## 12. Problem: Reboot Playbook Reboots Nothing

### Meaning

This may be normal.

The reboot playbook should only reboot machines when Ubuntu has created:

```text
/var/run/reboot-required
```

Check manually:

```bash
ls /var/run/reboot-required
```

If the file does not exist, reboot is not required.

This is good behavior.

---

## 13. Problem: Reboot Playbook Should Not Be Run

Do not run reboot playbooks:

* during class;
* while students are using PCs;
* without professor approval;
* before saving work;
* before confirming updates are complete.

Use:

```bash
ansible-playbook -i inventory.ini playbooks/07_reboot_if_required.yml --limit pc1
```

before running it on all machines.

---

## 14. Problem: Some PCs Work and Others Fail

### Meaning

This is common in real labs.

Different PCs may have:

* different usernames;
* different IP addresses;
* disconnected cables;
* missing SSH server;
* different Ubuntu versions;
* sudo differences;
* powered-off status.

### Test each failing PC individually

```bash
ansible -i inventory.ini pc3 -m ping
```

Then:

```bash
ping <pc3-ip>
ssh <user>@<pc3-ip>
```

Fix one PC at a time.

---

## 15. Problem: Wrong Username in Inventory

### Symptoms

You may see:

```text
Permission denied
Failed to connect to the host via ssh
```

### Check the real username

On the student PC:

```bash
whoami
```

Update inventory:

```bash
nano inventory.ini
```

Example:

```ini
pc4 ansible_host=172.16.0.183 ansible_user=labadmin lab_student_user=student123
```

Save and test:

```bash
ansible -i inventory.ini pc4 -m ping
```

---

## 16. Problem: Host Key Warning

### Symptoms

You may see:

```text
REMOTE HOST IDENTIFICATION HAS CHANGED
Host key verification failed
```

### Meaning

The teacher PC remembers an old SSH identity for that IP address.

This can happen if:

* the PC was reinstalled;
* the IP address now belongs to a different machine;
* SSH keys changed.

### Fix carefully

Remove the old known host entry:

```bash
ssh-keygen -R <ip-address>
```

Example:

```bash
ssh-keygen -R 172.16.0.149
```

Then reconnect:

```bash
ssh student@172.16.0.149
```

Only accept the new key if you are sure it is the correct machine.

---

## 17. Problem: Inventory Uses Real IPs and Should Not Go to GitHub

### Rule

The real file:

```text
inventory.ini
```

should stay private.

The safe file:

```text
inventory.example.ini
```

can be uploaded.

### Check `.gitignore`

```bash
cat .gitignore
```

It should include:

```text
inventory.ini
```

### Check Git status

```bash
git status
```

If `inventory.ini` appears under files to be committed, stop.

Fix `.gitignore` before committing.

---

## 18. Problem: Playbook Runs on Too Many PCs

### Prevention

Always test using `--limit`.

Example:

```bash
ansible-playbook -i inventory.ini playbooks/03_update_system.yml --limit pc1
```

Then expand gradually:

```bash
ansible-playbook -i inventory.ini playbooks/03_update_system.yml --limit pc1,pc2
```

Only run on all PCs after testing.

---

## 19. Problem: Command Works Manually but Not in Ansible

### Possible causes

* Different user.
* Different working directory.
* Missing sudo.
* Environment variables are different.
* Command requires interactive input.
* Relative paths are wrong.

### Solution

Use absolute paths when possible.

Run with verbose output:

```bash
ansible-playbook -i inventory.ini playbooks/05_copy_shared_materials.yml --limit pc1 -vvv
```

Read the exact error message.

---

## 20. Problem: Ansible Command Not Found

### Symptoms

```text
ansible: command not found
ansible-playbook: command not found
```

### Meaning

Ansible is not installed on the teacher/main computer.

Install it:

```bash
sudo apt update
sudo apt install ansible
```

Check:

```bash
ansible --version
```

---

## 21. Problem: Git Pull or Clone Fails

### Symptoms

```text
git: command not found
Authentication failed
Repository not found
Permission denied
```

### Fix Git missing

```bash
sudo apt update
sudo apt install git
```

### Clone project

```bash
git clone <repository-url>
```

If repository is private, make sure the correct GitHub account or access token is used.

Avoid saving personal GitHub login on a shared professor computer unless approved.

---

## 22. Problem: Shared Materials Accidentally Contains Private Files

### Rule

Only place approved teaching files inside:

```text
shared_materials/
```

Do not put:

* private professor files;
* passwords;
* SSH keys;
* personal documents;
* sensitive student data.

Before copying:

```bash
ls shared_materials/
```

If something should not be distributed, remove it before running the playbook.

---

## 23. Emergency Stop Rules

Stop immediately if:

* many machines fail at once;
* playbook affects the wrong directory;
* update process breaks packages;
* reboot starts unexpectedly;
* professor asks to pause;
* you are unsure what a command will do.

When in doubt:

```text
Stop.
Read the error.
Test one PC.
Ask before continuing.
```

---

## 24. Reporting Problems

When reporting a problem, record:

```text
Date:
Computer:
IP address:
Username:
Command run:
Full error message:
What was expected:
What happened:
What was tried:
Current status:
```

Save notes in:

```text
reports/
```

Example:

```text
reports/troubleshooting_YYYY-MM-DD.md
```

---

## 25. Best Practice Troubleshooting Flow

Use this flow:

```text
Network problem?
    |
    ├── Check cable, power, IP, ping
    |
SSH problem?
    |
    ├── Check ssh service, username, password/key
    |
Ansible problem?
    |
    ├── Check inventory, ansible_user, Python, ping module
    |
Playbook problem?
    |
    ├── Check YAML syntax, sudo, paths, variables
    |
Safety problem?
    |
    ├── Stop and test on one PC only
```

---

## 26. Final Reminder

Most Ansible problems are not actually Ansible problems.

They are usually:

* network problems;
* SSH problems;
* username problems;
* sudo permission problems;
* inventory mistakes;
* YAML indentation mistakes.

Fix the basic layer first, then continue upward.

```text
Network → SSH → Inventory → Ansible ping → Playbook
```
# User privilege issues

- **labadmin SSH works but sudo fails:** verify labadmin is in `sudo`, use
  `--ask-become-pass`, and check the password policy on the PC.
- **Permission denied as labadmin:** run playbook 08 with the old working admin
  account, verify the authorized key and home directory permissions.
- **Student still appears in sudo:** refresh the session, run playbook 09, and
  confirm the correct `lab_student_user` in private inventory.
- **Materials copied to labadmin:** define `lab_student_user` (or the default)
  and rerun playbook 05; destination ownership follows that account.
- **Inventory still uses student123 as ansible_user:** change it to
  `ansible_user=labadmin`; keep `lab_student_user=student123`.

# Student auto-login issues

- **PC does not auto-login after reboot:** check playbook 12 output, confirm
  the detected display manager, then reboot or log out/in for physical testing.
- **Wrong user auto-logs in:** verify `lab_student_user` in private inventory;
  never set it to `labadmin`.
- **Auto-login was configured for labadmin:** disable it with playbook 13,
  correct the student variable, then configure it again for the classroom user.
- **GDM3 custom.conf is missing or malformed:** run playbook 12 again after
  checking `/etc/gdm3/custom.conf`; it manages a clearly marked block.
- **Display manager is unsupported:** use GDM3 or LightDM, or set
  `student_autologin_display_manager` explicitly only for an installed one.
- **Student still has sudo after auto-login:** auto-login does not change sudo;
  inspect with playbook 09 and revoke it with playbook 10 if appropriate.
- **Need to disable auto-login:** run playbook 13, then reboot or log out and
  confirm that the graphical login screen appears.

# Current Deployment Checks

- **`./labmanage: Permission denied`:** run `chmod +x labmanage`. Before
  committing from Ubuntu, also run `git update-index --chmod=+x labmanage`.
- **`inventory.ini` missing:** copy `inventory.example.ini` locally, add real
  private host details, and do not commit it.
- **labadmin SSH or sudo fails:** stop before revoking student sudo. Re-run
  playbook 08 if needed, then test Ansible ping and `whoami -b` as labadmin.
- **Auto-login does not work or selects the wrong user:** verify
  `lab_student_user`, display-manager detection, and the physical desktop after
  reboot/logout. Never set the student account to labadmin.
- **Display manager is unsupported or ambiguous:** set
  `student_autologin_display_manager` to `gdm3` or `lightdm` only after
  confirming the installed manager.
- **SSH authenticity concern:** `host_key_checking = False` is a convenience
  trade-off. Verify host identity through a trusted lab process.
- **A log exists but the action failed:** inspect the Ansible recap and the
  saved log. A report records output; it does not make a failed action succeed.
