# Project Architecture

# Linux/Ubuntu Lab Management Toolkit

---

# Purpose

This document explains the overall architecture of the Linux/Ubuntu Lab Management Toolkit.

Rather than explaining individual playbooks, this document describes how every component of the project works together to manage an Ubuntu computer laboratory using Ansible.

It is intended for:

- Professors
- Laboratory administrators
- IT staff
- Future internship students
- Future project contributors

Reading this document should provide a complete understanding of the project before modifying or extending it.

---

# High-Level Architecture

The toolkit follows a simple centralized management architecture.

```
                    +--------------------------------+
                    |      Teacher / Main PC         |
                    |                                |
                    |  Ubuntu Linux                  |
                    |  Ansible Installed             |
                    |  Project Repository            |
                    |  inventory.ini                |
                    +---------------+----------------+
                                    |
                                    |
                             SSH Connections
                                    |
          -------------------------------------------------------
          |            |            |            |              |
          |            |            |            |              |
      +-------+    +-------+    +-------+    +-------+    +-------+
      | PC1   |    | PC2   |    | PC3   |    | PC4   |    | PC... |
      |Ubuntu |    |Ubuntu |    |Ubuntu |    |Ubuntu |    |Ubuntu |
      +-------+    +-------+    +-------+    +-------+    +-------+
```

The Teacher/Main PC is the control node.

Every student computer acts as a managed node.

All management tasks originate from the control node.

No software changes are manually repeated on every computer.

Instead, Ansible executes the same playbook on every selected host.

---

# System Components

## 1. Teacher / Main Computer

The teacher computer acts as the control node.

Responsibilities:

- Stores the project repository
- Stores inventory.ini
- Executes playbooks
- Maintains SSH keys
- Controls all student computers
- Receives execution results

This is the only computer where Ansible is required.

---

## 2. Student Computers

Each Ubuntu laboratory computer acts as a managed node.

Responsibilities:

- Accept SSH connections
- Execute Ansible tasks
- Return execution status
- Receive updates
- Receive shared teaching materials

Student computers do not require Ansible to be installed.

Only Python and SSH are required.

---

## 3. SSH Layer

SSH provides secure communication between the teacher computer and every managed node.

Responsibilities:

- Authentication
- Secure communication
- Remote command execution
- File transfer

Recommended authentication:

```
SSH Key Authentication
```

instead of passwords.

---

## 4. Inventory

The inventory tells Ansible which computers exist.

Example:

```
inventory.ini
```

Contains:

- hostnames
- IP addresses
- usernames
- connection variables

Example:

```
pc1 ansible_host=172.16.x.x
pc2 ansible_host=172.16.x.x
```

The inventory is the bridge between Ansible and the laboratory.

---

## 5. ansible.cfg

This file configures Ansible itself.

Typical settings include:

- inventory location
- SSH behaviour
- host key checking
- retry files
- timeout

It ensures consistent execution across all playbooks.

---

# Project Folder Structure

```
linux-lab-management/

│
├── ansible.cfg
├── inventory.ini
├── inventory.example.ini
├── README.md
├── CHANGELOG.md
├── PROJECT_STATUS.md
├── LAB_TEST_PLAN.md
│
├── playbooks/
│
├── docs/
│
├── reports/
│
└── shared_materials/
```

Every folder has a single responsibility.

---

# Folder Responsibilities

## playbooks/

Contains all automation tasks.

Examples:

```
01_check_connection.yml
02_collect_lab_status.yml
03_update_system.yml
04_install_required_software.yml
05_copy_shared_materials.yml
06_clean_lab_computers.yml
07_reboot_if_required.yml
```

Every playbook performs one clearly defined administrative operation.

---

## docs/

Contains all documentation.

Examples:

- Setup Guide
- Quick Start
- Troubleshooting
- Maintenance Checklist
- Security Guidelines
- Project Architecture
- Playbook Reference

This folder enables future maintainers to understand and extend the project.

---

## reports/

Stores generated reports.

Examples:

- maintenance logs
- audit reports
- exported inventories
- status reports

Nothing inside this folder is required for execution.

It stores outputs only.

---

## shared_materials/

Stores teaching resources that should be copied to student computers.

Typical contents:

```
PDFs

Assignments

Python files

Slides

Datasets

Laboratory instructions
```

Playbook:

```
05_copy_shared_materials.yml
```

copies files from this directory to the destination configured by the administrator.

---

# Control Flow

Every execution follows the same sequence.

```
Administrator

↓

Teacher PC

↓

Ansible

↓

Inventory

↓

SSH

↓

Student PCs

↓

Task Execution

↓

Results Returned

↓

Reports / Terminal Output
```

Nothing happens directly on student computers.

Everything originates from the Teacher PC.

---

# Typical Workflow

A normal maintenance session follows this sequence.

```
1. Verify inventory

↓

2. Test SSH connectivity

↓

3. Run Ansible ping

↓

4. Check system status

↓

5. Install required software

↓

6. Copy teaching materials

↓

7. Update packages

↓

8. Clean package cache

↓

9. Reboot only if required

↓

10. Save reports
```

This order minimizes operational risk.

---

# Design Principles

This toolkit follows several engineering principles.

## Modular

Each playbook performs one task only.

---

## Reusable

Playbooks can be reused independently.

---

## Idempotent

Running a playbook multiple times should not damage systems.

---

## Centralized

Everything is managed from one location.

---

## Documented

Every component includes documentation.

---

## Safe

Risky operations are separated from read-only operations.

---

## Scalable

Adding another laboratory computer requires only adding a new inventory entry.

No playbook modifications are necessary.

---

# Data Flow

```
Project Files

↓

Inventory

↓

Ansible

↓

SSH

↓

Managed Nodes

↓

Execution

↓

Results

↓

Reports
```

The inventory determines where tasks go.

Playbooks determine what happens.

Reports record what happened.

---

# Security Model

The architecture intentionally separates:

Public Documentation

↓

Project Code

↓

Private Inventory

↓

SSH Keys

Sensitive information is never committed to Git.

Only the teacher computer contains:

- inventory.ini
- SSH private keys

The GitHub repository contains only:

```
inventory.example.ini
```

---

# Future Expansion

The current architecture has been designed so additional functionality can be added without restructuring the project.

Potential future extensions include:

- Grafana monitoring dashboards
- Prometheus metrics
- Automatic inventory generation
- Docker-based student environments
- Classroom imaging
- Backup automation
- Scheduled maintenance
- Web dashboard
- Email notifications
- Central logging
- Remote classroom management

These additions can be integrated while preserving the current architecture.

---

# Architecture Summary

The Linux/Ubuntu Lab Management Toolkit follows a centralized architecture where a single Ubuntu control node uses Ansible and SSH to safely automate administrative tasks across multiple laboratory computers.

By separating configuration, automation, documentation, reports, and teaching materials into dedicated components, the project remains modular, maintainable, secure, and easy to extend for future academic laboratory environments.