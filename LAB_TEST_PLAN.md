# Lab Test Plan

## 1. Purpose

This document defines the safe testing order and procedures for the Ansible Linux/Ubuntu Lab Management toolkit. It is intended to guide a junior administrator or teaching assistant through step-by-step verification on the teacher/main computer before applying changes to all student PCs.

## 2. Pre-Test Checklist

- Confirm you are on the teacher/main computer (the Ansible control node).
- Confirm Ansible is installed and accessible (`ansible --version`).
- Confirm the real `inventory.ini` exists on the teacher/main computer.
- Confirm `inventory.ini` is not uploaded to GitHub or a public repo.
- Confirm `config/lab_settings.yml` contains only safe, non-secret settings.
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

1. `00_preflight_check.yml` to verify inventory, connectivity, Python, sudo, OS, disk, memory, and host identity before any risky action.
2. Review `config/lab_settings.yml` if package, copy, update, cleanup, threshold, or reboot settings were changed.
3. Manual Ansible ping (`ansible -i inventory.ini students -m ping`) to confirm baseline connectivity.
4. `01_check_connection.yml` to verify Ansible ping via a playbook.
5. `02_collect_lab_status.yml` to collect read-only system information.
6. `04_install_required_software.yml` on one PC first (`--limit pc01`) to verify package installation.
7. `05_copy_shared_materials.yml` on one PC first (`--limit pc01`) to verify file distribution and permissions.
8. `03_update_system.yml` only after explicit approval from the professor; run on one PC first.
9. `06_clean_lab_computers.yml` only after the update playbook is verified on at least one PC.
10. `07_reboot_if_required.yml` only when it is safe and approved; test on one PC first.

## 5. Commands to Run

Copyable commands for common test steps:

```bash
ansible-playbook -i inventory.ini playbooks/00_preflight_check.yml
ansible-playbook -i inventory.ini playbooks/00_preflight_check.yml --limit pc01
ansible-playbook -i inventory.ini playbooks/00_preflight_check.yml --ask-pass --ask-become-pass
ansible -i inventory.ini students -m ping
ansible-playbook -i inventory.ini playbooks/01_check_connection.yml
ansible-playbook -i inventory.ini playbooks/02_collect_lab_status.yml
ansible-playbook -i inventory.ini playbooks/04_install_required_software.yml --limit pc01
ansible-playbook -i inventory.ini playbooks/05_copy_shared_materials.yml --limit pc01
ansible-playbook -i inventory.ini playbooks/03_update_system.yml --limit pc01
bash scripts/run_with_logging.sh playbooks/00_preflight_check.yml
./labmanage
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
- Save important terminal output in `reports/` using `scripts/run_with_logging.sh`.
- Fill `FINAL_TEST_REPORT.md` after the final real-lab validation.
- Update `PROJECT_STATUS.md` to record the test outcome and progress.
- Document any manual steps or workarounds observed during testing in `docs/troubleshooting.md`.

## 9. GitHub Safety Notes

- Do not commit `inventory.ini` to the repository.
- Do not commit private SSH keys or key files.
- Do not commit passwords or secrets.
- Use `inventory.example.ini` for public documentation and examples.
- Keep real lab-specific configuration on the teacher/main PC or in a private local copy only.
- Keep `config/lab_settings.yml` free of secrets so it can remain trackable.


---

This plan is written for clarity and safe operation by junior administrators during an Erasmus internship. Follow it carefully and consult the professor for any uncertainty.
