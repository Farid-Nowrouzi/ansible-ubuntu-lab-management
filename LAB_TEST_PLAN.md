# Lab Test Plan

## 1. Purpose

This document defines the safe testing order and procedures for the Ansible Linux/Ubuntu Lab Management toolkit. It is intended to guide a junior administrator or teaching assistant through step-by-step verification on the teacher/main computer before applying changes to all student PCs.

## 2. Pre-Test Checklist

- Confirm you are on the teacher/main computer (the Ansible control node).
- Confirm Ansible is installed and accessible (`ansible --version`).
- Confirm the real `inventory.ini` exists on the teacher/main computer.
- Confirm `inventory.ini` is not uploaded to GitHub or a public repo.
- Confirm SSH key-based access works and passwordless SSH is set up.
- Confirm at least one student PC is online and reachable.
- Confirm the professor or responsible instructor approves any update, install, cleanup, or reboot operation.
- Avoid testing during active class time or when students are using lab machines.

## 3. Safety Rule

Always test playbooks on a single, representative student PC first using `--limit` before running against the entire `students` group. This prevents accidental mass changes.

Example:

```bash
ansible-playbook -i inventory.ini playbooks/01_check_connection.yml --limit pc01
```

## 4. Recommended Test Order

1. Manual Ansible ping (`ansible -i inventory.ini students -m ping`) to confirm baseline connectivity.
2. `01_check_connection.yml` to verify Ansible ping via a playbook.
3. `02_collect_lab_status.yml` to collect read-only system information.
4. `04_install_required_software.yml` on one PC first (`--limit pc01`) to verify package installation.
5. `05_copy_shared_materials.yml` on one PC first (`--limit pc01`) to verify file distribution and permissions.
6. `03_update_system.yml` only after explicit approval from the professor; run on one PC first.
7. `06_clean_lab_computers.yml` only after the update playbook is verified on at least one PC.
8. `07_reboot_if_required.yml` only when it is safe and approved; test on one PC first.

## 5. Commands to Run

Copyable commands for common test steps:

```bash
ansible -i inventory.ini students -m ping
ansible-playbook -i inventory.ini playbooks/01_check_connection.yml
ansible-playbook -i inventory.ini playbooks/02_collect_lab_status.yml
ansible-playbook -i inventory.ini playbooks/04_install_required_software.yml --limit pc01
ansible-playbook -i inventory.ini playbooks/05_copy_shared_materials.yml --limit pc01
ansible-playbook -i inventory.ini playbooks/03_update_system.yml --limit pc01
```

## 6. What to Record During Testing

Record the following for every test:

- Date and time
- Which PC was tested (use the inventory `name`)
- Which command or playbook was run
- Whether the run succeeded or failed
- Any error messages or stack traces
- Any machine that was offline or unreachable
- Any machine that requires manual intervention after the run

## 7. When to Stop

Stop testing and escalate to the professor or lab administrator if any of the following occur:

- SSH fails on multiple machines unexpectedly
- `sudo` prompts for a password when it should not
- A playbook modifies or affects the wrong directory
- Package installation fails consistently on multiple PCs
- Network instability or frequent timeouts appear
- The professor or instructor requests a pause

## 8. After Successful Testing

Once a playbook has been validated on one PC:

- Run the same playbook on all reachable student PCs with confidence, using the normal inventory.
- Update `PROJECT_STATUS.md` to record the test outcome and progress.
- Document any manual steps or workarounds observed during testing in `docs/troubleshooting.md`.

## 9. GitHub Safety Notes

- Do not commit `inventory.ini` to the repository.
- Do not commit private SSH keys or key files.
- Do not commit passwords or secrets.
- Use `inventory.example.ini` for public documentation and examples.
- Keep real lab-specific configuration on the teacher/main PC or in a private local copy only.


---

This plan is written for clarity and safe operation by junior administrators during an Erasmus internship. Follow it carefully and consult the professor for any uncertainty.