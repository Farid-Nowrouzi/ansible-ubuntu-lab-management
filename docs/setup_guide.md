# Setup Guide

## Ansible-Based Linux/Ubuntu Lab Management System

This guide explains how to set up a Linux/Ubuntu computer lab so that one teacher/main computer can manage multiple student computers using Ansible over SSH.

This document is written for a new student, professor, lab assistant, or administrator who wants to understand the full setup process from the beginning.

It does not assume that SSH or Ansible is already working.

---

## 1. Purpose of This Guide

The goal of this setup is to allow one central computer, called the teacher/main computer, to manage multiple Ubuntu student computers.

After the setup is complete, the teacher/main computer can:

* run a safe preflight check before maintenance;
* check whether student PCs are reachable;
* update Ubuntu packages;
* install required software;
* copy selected teaching materials;
* collect basic system information;
* clean package cache;
* reboot machines only when required.

This avoids repeating the same manual work on every student PC.

---

## 2. Basic Architecture

The system works like this:

```text
Teacher/Main PC
     |
     | Ansible commands
     |
     | SSH connection
     |
Student PC 1
Student PC 2
Student PC 3
...
Student PC N
```

The teacher/main computer is the **Ansible control node**.

The student computers are the **managed nodes**.

Ansible does not need to be installed on every student PC. The student PCs mainly need:

* Ubuntu/Linux;
* network connection;
* SSH server;
* valid username;
* reachable IP address;
* permission to run administrative tasks when needed.

---

## 3. Important Concepts

### 3.1 What is SSH?

SSH means Secure Shell.

It allows one Linux computer to remotely connect to another Linux computer through the network.

Example:

```bash
ssh student@192.168.1.101
```

This means:

```text
Connect to the computer with IP address 192.168.1.101 using the username student.
```

Before Ansible can work, SSH must work.

---

### 3.2 What is Ansible?

Ansible is an automation tool.

Instead of logging into each computer manually and running commands one by one, Ansible allows the teacher/main computer to run tasks on many student PCs at the same time.

Example:

```bash
ansible -i inventory.ini students -m ping
```

This asks Ansible to check whether all computers in the `students` group are reachable.

---

### 3.3 What is an Inventory File?

The inventory file tells Ansible which computers it should manage.

Example:

```ini
[students]
pc1 ansible_host=192.168.1.101 ansible_user=student
pc2 ansible_host=192.168.1.102 ansible_user=student
```

Each line contains:

```text
pc1                 = local Ansible name for the computer
ansible_host        = IP address of the computer
ansible_user        = Linux username used for SSH
```

The real inventory file is called:

```text
inventory.ini
```

For security, the real `inventory.ini` should not be uploaded to GitHub.

The example file is:

```text
inventory.example.ini
```

---

## 4. Before Starting

You need physical or authorized access to:

* the teacher/main computer;
* each student computer;
* the student usernames/passwords if SSH keys are not configured yet;
* administrator/sudo permissions where required.

You should also confirm:

* the professor or lab owner approves the work;
* testing is not done during an active class;
* no important student work will be interrupted;
* reboots are only done with approval.

---

## 5. Step 1 — Inspect the Teacher/Main Computer

Start on the teacher/main computer.

Open a terminal.

Check the current username:

```bash
whoami
```

Check the hostname:

```bash
hostname
```

Check the IP addresses:

```bash
hostname -I
```

Alternative command:

```bash
ip addr
```

Write down:

```text
Teacher PC username:
Teacher PC hostname:
Teacher PC IP address:
```

This computer will run Ansible.

---

## 6. Step 2 — Inspect Each Student Computer

Go to each student computer physically.

Open a terminal and collect the basic information.

Check username:

```bash
whoami
```

Check hostname:

```bash
hostname
```

Check IP addresses:

```bash
hostname -I
```

Alternative:

```bash
ip addr
```

Write down the information in a table like this:

```text
PC name | Username | IP address | SSH installed? | Notes
pc1     | student  | 192.168.x.x | yes/no         | working
pc2     | student  | 172.16.x.x  | yes/no         | cable unplugged
```

Important: Some computers may show more than one IP address, for example a `192.x.x.x` address and a `172.x.x.x` address. Use the IP address that is reachable from the teacher/main computer.

---

## 7. Step 3 — Check Network Connectivity

From the teacher/main computer, test whether a student PC can be reached.

Example:

```bash
ping 192.168.1.101
```

If the PC replies, the network is working.

Stop ping using:

```bash
Ctrl + C
```

If ping fails, check:

* Is the student PC powered on?
* Is the Ethernet cable connected?
* Is the IP address correct?
* Are the teacher PC and student PC on the same network?
* Is the computer using a different IP address?

Repeat this for every student PC.

---

## 8. Step 4 — Check Whether SSH Server is Installed on Student PCs

On each student PC, run:

```bash
systemctl status ssh
```

If SSH is installed and running, you should see something like:

```text
active (running)
```

If the service is missing, install OpenSSH Server:

```bash
sudo apt update
sudo apt install openssh-server
```

Enable and start SSH:

```bash
sudo systemctl enable ssh
sudo systemctl start ssh
```

Check again:

```bash
systemctl status ssh
```

The goal is:

```text
SSH service active and running on every student PC that should be managed.
```

---

## 9. Step 5 — Test Manual SSH from Teacher PC to Student PC

Return to the teacher/main computer.

Try connecting manually to a student PC:

```bash
ssh student@192.168.1.101
```

Replace:

```text
student       with the real username
192.168.1.101 with the real student PC IP address
```

If this is the first time connecting, SSH may ask:

```text
Are you sure you want to continue connecting?
```

Type:

```text
yes
```

Then enter the password if requested.

If login works, exit the remote machine:

```bash
exit
```

Repeat this test for each student PC.

Do not continue to Ansible until manual SSH works.

---

## 10. Step 6 — Create SSH Key on the Teacher/Main Computer

On the teacher/main computer, create an SSH key if one does not already exist.

Check whether a key already exists:

```bash
ls ~/.ssh
```

If you see files like:

```text
id_rsa
id_rsa.pub
```

or

```text
id_ed25519
id_ed25519.pub
```

then a key already exists.

If no key exists, create one:

```bash
ssh-keygen
```

For a simple lab setup, you can press Enter for the default file location.

This creates a public/private key pair.

Important:

* The private key stays on the teacher/main computer.
* The public key can be copied to student computers.
* Never upload private SSH keys to GitHub.

---

## 11. Step 7 — Copy SSH Key to Each Student PC

Use `ssh-copy-id` from the teacher/main computer.

Example:

```bash
ssh-copy-id student@192.168.1.101
```

Enter the student PC password when asked.

Then test passwordless SSH:

```bash
ssh student@192.168.1.101
```

If it connects without asking for the password, SSH key authentication is working.

Exit:

```bash
exit
```

Repeat this for every student PC.

---

## 12. Step 8 — Install Ansible on the Teacher/Main Computer

Ansible is installed only on the teacher/main computer.

Run:

```bash
sudo apt update
sudo apt install ansible
```

Check the installed version:

```bash
ansible --version
```

If this works, the teacher/main computer is ready to run Ansible commands.

The professor can later open the menu with:

```bash
./labmanage
```

If Linux says the launcher is not executable, run:

```bash
chmod +x labmanage scripts/manage_lab.sh scripts/run_with_logging.sh
```

---

## 13. Step 9 — Create or Clone the Project Folder

The project folder should be stored on the teacher/main computer.

Example:

```bash
cd ~
git clone <repository-url>
cd linux-lab-management
```

If GitHub is not used yet, create the folder manually:

```bash
mkdir -p ~/linux-lab-management
cd ~/linux-lab-management
```

The project should contain:

```text
README.md
ansible.cfg
inventory.example.ini
inventory.ini
labmanage
playbooks/
scripts/
docs/
shared_materials/
reports/
```

The real `inventory.ini` may need to be created manually.

---

## 14. Step 10 — Create the Real Inventory File

Copy the example inventory:

```bash
cp inventory.example.ini inventory.ini
```

Edit it:

```bash
nano inventory.ini
```

Example format:

```ini
[students]
pc1 ansible_host=192.168.1.101 ansible_user=student
pc2 ansible_host=192.168.1.102 ansible_user=student
pc3 ansible_host=172.16.0.149 ansible_user=students
```

Rules:

* Use one line per student PC.
* Use the IP address reachable from the teacher/main computer.
* Use the correct Linux username for each PC.
* Do not write passwords in this file.
* Keep the group name as `[students]`.

Save in nano:

```text
Ctrl + O
Enter
Ctrl + X
```

---

## 15. Step 11 — Test Ansible Inventory

From the project folder, run:

```bash
ansible -i inventory.ini students --list-hosts
```

This should list the PCs from the inventory.

Then run:

```bash
ansible -i inventory.ini students -m ping
```

Successful output looks like:

```text
pc1 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

If a machine fails, check:

* IP address;
* username;
* SSH service;
* SSH key;
* network cable;
* whether the PC is powered on.

---

## 16. Step 12 — Test One PC First

Before running playbooks on the whole lab, run the safe preflight check and then test one PC.

```bash
ansible-playbook -i inventory.ini playbooks/00_preflight_check.yml
```

Example:

```bash
ansible-playbook -i inventory.ini playbooks/01_check_connection.yml --limit pc1
```

The `--limit pc1` part means:

```text
Run only on pc1.
```

This is safer than running immediately on every student PC.

Recommended safe first tests:

```bash
ansible-playbook -i inventory.ini playbooks/00_preflight_check.yml --limit pc1
ansible-playbook -i inventory.ini playbooks/01_check_connection.yml --limit pc1
ansible-playbook -i inventory.ini playbooks/02_collect_lab_status.yml --limit pc1
```

If these work, test all reachable PCs:

```bash
ansible-playbook -i inventory.ini playbooks/01_check_connection.yml
ansible-playbook -i inventory.ini playbooks/02_collect_lab_status.yml
```

---

## 17. Step 13 — Run Core Playbooks

### 17.1 Run Preflight Check

```bash
ansible-playbook -i inventory.ini playbooks/00_preflight_check.yml
```

Purpose:

```text
Checks inventory, SSH, Python 3, sudo, OS compatibility, disk space, memory, and host identity before maintenance.
```

---

### 17.2 Check Connection

```bash
ansible-playbook -i inventory.ini playbooks/01_check_connection.yml
```

Purpose:

```text
Confirms that Ansible can reach the student PCs.
```

---

### 17.3 Collect Lab Status

```bash
ansible-playbook -i inventory.ini playbooks/02_collect_lab_status.yml
```

Purpose:

```text
Collects useful information such as hostname, IP address, Ubuntu version, memory, disk, and system facts.
```

---

### 17.4 Install Required Software

Test on one PC first:

```bash
ansible-playbook -i inventory.ini playbooks/04_install_required_software.yml --limit pc1
```

Then run on all PCs only after confirming it works:

```bash
ansible-playbook -i inventory.ini playbooks/04_install_required_software.yml
```

Purpose:

```text
Installs required packages such as vim, htop, curl, git, tree, net-tools, python3, and python3-pip.
```

To add more packages, edit:

```text
playbooks/04_install_required_software.yml
```

and update the `required_packages` list.

---

### 17.5 Copy Shared Materials

Put approved files inside:

```text
shared_materials/
```

Then test on one PC:

```bash
ansible-playbook -i inventory.ini playbooks/05_copy_shared_materials.yml --limit pc1
```

Then run on all PCs:

```bash
ansible-playbook -i inventory.ini playbooks/05_copy_shared_materials.yml
```

Important:

This does not copy the whole teacher PC. It only copies files placed inside the controlled `shared_materials/` folder.

---

### 17.6 Update Ubuntu Packages

Run only after professor/lab approval.

Test one PC first:

```bash
ansible-playbook -i inventory.ini playbooks/03_update_system.yml --limit pc1
```

Then run on all PCs if approved:

```bash
ansible-playbook -i inventory.ini playbooks/03_update_system.yml
```

This playbook updates packages but should not reboot machines automatically.

---

### 17.7 Clean Package Cache

```bash
ansible-playbook -i inventory.ini playbooks/06_clean_lab_computers.yml
```

Purpose:

```text
Runs safe package cleanup commands such as apt autoremove and apt autoclean.
```

This should not delete student files.

---

### 17.8 Reboot Only If Required

Run only when safe and approved:

```bash
ansible-playbook -i inventory.ini playbooks/07_reboot_if_required.yml
```

Purpose:

```text
Reboots only machines where Ubuntu says a reboot is required.
```

Avoid running this during class time.

---

## 18. Recommended Testing Order

Use this order during real lab testing:

```text
1. Manual ping from teacher PC to student PC
2. Manual SSH from teacher PC to student PC
3. SSH key copy using ssh-copy-id
4. Passwordless SSH test
5. Ansible inventory list
6. Ansible ping
7. 00_preflight_check.yml
8. 01_check_connection.yml on one PC
9. 02_collect_lab_status.yml on one PC
10. Install/copy/update playbooks on one PC
11. Expand to 2-3 PCs
12. Run on all reachable PCs only when safe
13. Save results in reports/
14. Fill FINAL_TEST_REPORT.md
15. Update PROJECT_STATUS.md
```

---

## 19. Understanding Ansible Output

Ansible commonly shows:

```text
ok
changed
failed
unreachable
```

Meaning:

```text
ok          = task completed and nothing needed to change
changed     = task completed and made a change
failed      = task ran but failed
unreachable = Ansible could not connect to the machine
```

If you see `failed` or `unreachable`, stop and check the problem before running more playbooks.

---

## 20. What to Record

During setup and testing, record:

```text
Date:
Tested by:
Teacher PC:
Student PC:
IP address:
Username:
Command used:
Result:
Error message:
Notes:
```

Reports can be saved in:

```text
reports/
```

Example report name:

```text
reports/lab_test_YYYY-MM-DD.md
```

---

## 21. Safety Rules

Follow these rules:

* Do not upload `inventory.ini` to GitHub.
* Do not upload SSH private keys.
* Do not store passwords in project files.
* Test on one PC first using `--limit`.
* Do not reboot during active class time.
* Do not run update/install/cleanup tasks without approval.
* Do not add destructive delete commands unless approved.
* Keep professor/private files outside `shared_materials/`.

---

## 22. Troubleshooting Direction

If something fails:

1. Check network first:

```bash
ping <ip-address>
```

2. Check SSH manually:

```bash
ssh <username>@<ip-address>
```

3. Check inventory:

```bash
nano inventory.ini
```

4. Check Ansible ping:

```bash
ansible -i inventory.ini students -m ping
```

5. Check playbook syntax:

```bash
ansible-playbook --syntax-check playbooks/01_check_connection.yml
```

Use:

```text
docs/troubleshooting.md
```

for detailed problem-solving.

---

## 23. Final Success Criteria

The setup is successful when:

* the teacher/main computer can SSH into student PCs;
* SSH key-based login works;
* Ansible is installed on the teacher/main computer;
* `inventory.ini` contains reachable student PCs;
* `ansible -i inventory.ini students -m ping` returns success;
* connection and status playbooks run successfully;
* software installation, update, copy, cleanup, and reboot playbooks are tested safely;
* documentation is updated for future users.

---

## 24. Final Notes

This setup is not intended to be a full enterprise management platform.

It is a practical, documented, reusable Ansible-based toolkit for managing Ubuntu student computers from one central teacher/main computer.

Future improvements should stay practical for the lab, such as:

* improving tested examples in `reports/`;
* adjusting the required package list for real courses;
* adding clearer professor handover notes after feedback;
* improving inventory examples if the lab layout changes.

For the first version, the priority is:

```text
SSH works
Ansible works
Playbooks are tested
Documentation is clear
Future users can continue the project
```
