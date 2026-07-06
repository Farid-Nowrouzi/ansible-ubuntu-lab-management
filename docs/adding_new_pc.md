# Adding A New Laboratory Computer

This guide explains how to add a new Ubuntu/Linux student PC to the Linux Lab Management Toolkit.

Use this when a new computer is installed, repaired, renamed, reinstalled, or added to the lab.

---

## 1. Goal

The goal is to add one new student PC to:

```text
inventory.ini
```

and then verify that Ansible can manage it safely.

Adding a PC does not require editing playbooks.

---

## 2. Prerequisites

Before adding the new PC, confirm:

- the PC is powered on;
- Ubuntu or compatible Linux is installed;
- the PC is connected to the lab network;
- SSH server is installed and running;
- the teacher/main computer can reach the same network;
- you know the correct SSH username;
- the SSH user can use sudo if maintenance playbooks will be used.

Why this matters:

Ansible connects over SSH. If network or SSH is not working, the playbooks cannot manage the computer.

---

## 3. Find The Hostname Or IP Address

On the new student PC, run:

```bash
hostname
hostname -I
```

or:

```bash
ip addr
```

Write down the reachable IP address.

Example:

```text
192.168.1.120
```

Why this matters:

The inventory needs a stable address or hostname so Ansible knows where to connect.

---

## 4. Verify Network Reachability

From the teacher/main computer, test:

```bash
ping 192.168.1.120
```

Stop the ping with:

```text
Ctrl + C
```

If ping fails, check:

- power;
- network cable;
- Wi-Fi or Ethernet status;
- IP address;
- lab network connection.

Why this matters:

Network connectivity must work before SSH or Ansible can work.

---

## 5. Verify SSH Access

From the teacher/main computer:

```bash
ssh student@192.168.1.120
```

Replace `student` with the real username.

If SSH is not installed on the student PC, install and start it on that PC:

```bash
sudo apt update
sudo apt install openssh-server
sudo systemctl enable ssh
sudo systemctl start ssh
```

Why this matters:

Ansible uses SSH to run commands on the student PC.

---

## 6. Check The Username

On the student PC, confirm the username:

```bash
whoami
```

Example result:

```text
student
```

If the username is different, use the real username in `inventory.ini`.

Why this matters:

A wrong username is one of the most common reasons Ansible cannot connect.

---

## 7. Optional: Copy SSH Key

If the lab uses SSH keys, copy the teacher/main computer's SSH key:

```bash
ssh-copy-id student@192.168.1.120
```

Then test again:

```bash
ssh student@192.168.1.120
```

Why this matters:

SSH keys allow Ansible to connect without typing a password each time.

If password-based access is used, Ansible can be run with:

```bash
--ask-pass
```

and sudo password prompting can use:

```bash
--ask-become-pass
```

---

## 8. Add The PC To `inventory.ini`

Open the private inventory file:

```bash
nano inventory.ini
```

Add the new PC under:

```ini
[students]
```

Example with username per host:

```ini
[students]
pc1 ansible_host=192.168.1.101 ansible_user=student
pc2 ansible_host=192.168.1.102 ansible_user=student
pc3 ansible_host=192.168.1.120 ansible_user=student
```

Example with shared username:

```ini
[students]
pc1 ansible_host=192.168.1.101
pc2 ansible_host=192.168.1.102
pc3 ansible_host=192.168.1.120

[students:vars]
ansible_user=student
ansible_python_interpreter=/usr/bin/python3
```

Why this matters:

`inventory.ini` is the list of computers Ansible manages.

Do not put real lab IP addresses in `inventory.example.ini`.

---

## 9. List Inventory Hosts

From the project root:

```bash
ansible -i inventory.ini students --list-hosts
```

Confirm the new PC appears in the output.

Why this matters:

This confirms that Ansible can read the inventory entry.

---

## 10. Run The Preflight Check On The New PC

Use the new inventory name:

```bash
ansible-playbook -i inventory.ini playbooks/00_preflight_check.yml --limit localhost,pc3
```

Use the correct host alias instead of `pc3`.

Why include `localhost`?

The preflight playbook also checks the inventory from the teacher/main computer. Including `localhost` keeps that check active when limiting to one PC.

Why this matters:

Preflight verifies SSH, Python 3, sudo access, OS compatibility, disk space, memory, and host identity before any changing task.

---

## 11. Run The Connection Check

```bash
ansible-playbook -i inventory.ini playbooks/01_check_connection.yml --limit pc3
```

Why this matters:

This confirms Ansible can communicate with the new PC using the normal playbook workflow.

---

## 12. Collect Status From The New PC

```bash
ansible-playbook -i inventory.ini playbooks/02_collect_lab_status.yml --limit pc3
```

Why this matters:

This records basic information such as hostname, operating system, memory, and network data.

---

## 13. Test A Safe Changing Operation

If approved, test one changing operation on the new PC.

For example, copy teaching materials:

```bash
ansible-playbook -i inventory.ini playbooks/05_copy_shared_materials.yml --limit pc3
```

or install required software:

```bash
ansible-playbook -i inventory.ini playbooks/04_install_required_software.yml --limit pc3
```

Why this matters:

The new PC may have different permissions, packages, disk space, or user setup than the rest of the lab.

---

## 14. Common Mistakes

Common problems include:

- wrong IP address;
- PC is powered off;
- network cable is unplugged;
- SSH server is not installed;
- wrong SSH username;
- SSH key was not copied;
- user cannot use sudo;
- new host was added outside the `[students]` group;
- inventory alias does not match the `--limit` value;
- Python 3 is missing on the student PC.

---

## 15. Troubleshooting

If the new PC fails, use this order:

```text
1. Ping the IP address.
2. Try manual SSH.
3. Check the username.
4. Check SSH service on the student PC.
5. Check inventory.ini formatting.
6. Run Ansible ping.
7. Run the preflight playbook with --limit.
8. Read docs/troubleshooting.md.
```

Useful commands:

```bash
ping 192.168.1.120
ssh student@192.168.1.120
ansible -i inventory.ini pc3 -m ping
ansible-playbook -i inventory.ini playbooks/00_preflight_check.yml --limit localhost,pc3
```

---

## 16. Best Practices

- Use clear host aliases such as `pc1`, `pc2`, `student01`, or `lab01`.
- Keep naming consistent across the lab.
- Do not reuse the same alias for two different machines.
- Do not commit `inventory.ini`.
- Keep `inventory.example.ini` generic and safe.
- Test the new PC alone before including it in full-lab maintenance.
- Record unusual setup notes in `reports/` or `FINAL_TEST_REPORT.md`.

---

## 17. Final Checklist

Before considering the new PC ready:

- it appears in `ansible -i inventory.ini students --list-hosts`;
- manual SSH works;
- Ansible ping works;
- preflight passes;
- connection check passes;
- status collection works;
- at least one approved changing task has been tested if needed.

After this, the new PC can be managed with the rest of the `students` group.
