# Project Overview

## Linux Lab Management Toolkit

This is a short architecture overview for professors, lab assistants, and future maintainers.

It explains the whole project in a few minutes.

---

## 1. Purpose

The Linux Lab Management Toolkit helps a professor manage Ubuntu/Linux student PCs from one teacher/main computer.

It uses:

```text
Ansible over SSH
```

to run safe lab-management tasks such as checks, status collection, package installation, updates, cleanup, file copying, and conditional reboot.

The project is intentionally simple. It does not use Docker, CI/CD, Kubernetes, cloud services, or monitoring systems.

---

## 2. Main Components

### `labmanage`

The main professor-facing launcher.

Run it from the project root:

```bash
./labmanage
```

It starts the interactive menu.

---

### `scripts/manage_lab.sh`

The menu script.

It shows common operations, asks for confirmation before changing actions, and calls the correct playbook.

---

### `scripts/run_with_logging.sh`

The logging helper.

It runs an Ansible playbook and saves output in:

```text
reports/
```

---

### `playbooks/`

Contains the Ansible playbooks that perform the actual lab tasks.

Examples:

- preflight check;
- connection check;
- status collection;
- system update;
- software installation;
- shared-materials copy;
- safe cleanup;
- reboot only if required.

---

### `inventory.ini`

The private list of real student PCs.

It contains host aliases, IP addresses or hostnames, and SSH usernames.

This file must stay private and should not be committed.

---

### `inventory.example.ini`

A safe example inventory file.

Use it as a template when creating `inventory.ini`.

It should not contain real private lab data.

---

### `config/lab_settings.yml`

The safe central settings file.

It controls normal lab settings such as:

- packages to install;
- shared-materials destination;
- update behavior;
- cleanup behavior;
- disk and memory thresholds;
- reboot timeout.

It should not contain passwords, SSH keys, IP addresses, hostnames, or private lab data.

---

## 3. Directory Structure

```text
linux-lab-management/
|-- labmanage
|-- ansible.cfg
|-- inventory.example.ini
|-- inventory.ini
|-- config/
|-- docs/
|-- playbooks/
|-- reports/
|-- scripts/
`-- shared_materials/
```

---

## 4. Folder Responsibilities

### `playbooks/`

Stores the Ansible automation files.

Each playbook has one main job.

Professors normally run playbooks through `./labmanage`, not by editing them.

---

### `docs/`

Stores project documentation.

Important guides include:

- `docs/professor_handover.md`
- `docs/quick_start.md`
- `docs/professor_user_manual.md`
- `docs/customization_guide.md`
- `docs/adding_new_pc.md`
- `docs/troubleshooting.md`
- `docs/playbook_reference.md`

---

### `config/`

Stores safe central settings.

The key file is:

```text
config/lab_settings.yml
```

This is where normal package, update, cleanup, copy, threshold, and reboot-timeout settings are changed.

---

### `shared_materials/`

Stores files that should be copied to student PCs.

Only approved teaching files should go here.

Do not store passwords, private keys, or confidential data here.

---

### `reports/`

Stores generated logs and evidence from lab runs.

Reports may contain private lab details, so review them before sharing.

---

### `scripts/`

Stores helper scripts used by the menu and logging workflow.

Professors normally do not need to edit these scripts.

---

## 5. Overall Workflow

Normal operation follows this order:

```text
1. Open the project on the teacher/main computer.
2. Run ./labmanage.
3. Run preflight.
4. Run connection check.
5. Collect lab status.
6. Test changing actions on one PC.
7. Expand to a small group.
8. Run on the full lab only after testing.
9. Save logs in reports/.
```

---

## 6. How A Command Travels Through The Project

The normal menu flow is:

```text
Professor
  |
  v
./labmanage
  |
  v
scripts/manage_lab.sh
  |
  v
scripts/run_with_logging.sh
  |
  v
Ansible playbook
  |
  v
inventory.ini
  |
  v
Student PCs
  |
  v
reports/
```

Meaning:

- the professor starts `./labmanage`;
- the launcher opens the menu script;
- the menu selects a playbook;
- the logging helper saves output;
- Ansible reads `inventory.ini`;
- Ansible connects to student PCs over SSH;
- results are shown on screen and saved in `reports/`.

---

## 7. What Controls What

```text
./labmanage
```

starts the system.

```text
inventory.ini
```

controls which PCs are managed.

```text
config/lab_settings.yml
```

controls packages and normal maintenance settings.

```text
shared_materials/
```

contains files copied to student PCs.

```text
reports/
```

contains logs and evidence.

---

## 8. Safety Model

The project separates safe checks from changing actions.

Safe checks:

- preflight;
- connection check;
- status collection.

Changing actions:

- update systems;
- install software;
- copy shared materials;
- clean lab computers;
- reboot if required.

Changing actions should always be tested on one PC first.

---

## 9. Where To Read Next

| Need | Read |
| --- | --- |
| Main professor handover | `docs/professor_handover.md` |
| Fast commands | `docs/quick_start.md` |
| Add a new PC | `docs/adding_new_pc.md` |
| Change settings | `docs/customization_guide.md` |
| Detailed architecture | `docs/project_architecture.md` |
| Troubleshooting | `docs/troubleshooting.md` |
| Playbook details | `docs/playbook_reference.md` |

---

## 10. Summary

This project is a simple control-node toolkit:

```text
Teacher/Main PC -> Ansible -> SSH -> Student PCs
```

The professor runs `./labmanage`, keeps `inventory.ini` private, changes normal settings in `config/lab_settings.yml`, places teaching files in `shared_materials/`, and keeps logs in `reports/`.
