# Linux Lab Management

This project is a starter Ansible-based management system for Ubuntu lab computers.
It is designed for a teacher or professor who wants to manage student PCs from one Ansible control node.

## Purpose

- Run a safe preflight check before any maintenance action.
- Ping all student computers to verify SSH connectivity.
- Collect lab status information safely with read-only commands.
- Keep student lab machines updated and clean.
- Install useful software packages.
- Distribute shared teaching materials to student home directories.
- Reboot student machines only when required.

## Project layout

- `ansible.cfg`: Control node Ansible configuration.
- `inventory.example.ini`: Example inventory with the `students` group.
- `config/lab_settings.yml`: Safe central settings for packages, shared-materials destination, thresholds, cleanup, updates, and reboot timeout.
- `playbooks/`: Reusable Ansible playbooks for lab management.
- `docs/`: Setup, user manual, troubleshooting, and maintenance guides.
- `labmanage`: Main professor-friendly menu launcher.
- `scripts/`: Helper scripts used by the menu and logging workflow.
- `shared_materials/`: Placeholder for materials to copy to lab computers.
- `reports/`: Output and generated report placeholder directory.
- `FINAL_TEST_REPORT.md`: Template for final real-lab validation results.

## Getting started

1. Copy `inventory.example.ini` to `inventory.ini`.
2. Update `inventory.ini` with the hostnames or IP addresses of student lab computers.
3. Review `config/lab_settings.yml` if you need to change packages, shared-materials destination, thresholds, or maintenance settings.
4. Run the safe preflight check first:

```bash
ansible-playbook playbooks/00_preflight_check.yml
ansible-playbook playbooks/00_preflight_check.yml --limit pc1
ansible-playbook playbooks/00_preflight_check.yml --ask-pass --ask-become-pass
```

5. Run the connection check:

```bash
ansible-playbook playbooks/01_check_connection.yml
```

6. Review and run additional playbooks from `playbooks/` as needed.

For the main professor handover guide, read:

```text
docs/professor_handover.md
```

For a short architecture overview, read:

```text
docs/project_overview.md
```

## Recommended workflow

1. Edit private `inventory.ini` locally from `inventory.example.ini`.
2. Edit safe shared settings in `config/lab_settings.yml` when needed.
3. Put teaching files in `shared_materials/` when needed.
4. Run `playbooks/00_preflight_check.yml`.
5. Run `playbooks/01_check_connection.yml`.
6. Run `playbooks/02_collect_lab_status.yml`.
7. Test changing playbooks on one PC first using `--limit pc1`.
8. Expand to 2-3 PCs.
9. Run on all reachable student PCs only when safe.
10. Save useful outputs/logs into `reports/`.
11. Fill `FINAL_TEST_REPORT.md` after real lab testing.

## Professor menu

Run the lab management menu:

```bash
./labmanage
```

If needed, make the launcher executable first:

```bash
chmod +x labmanage scripts/manage_lab.sh scripts/run_with_logging.sh
./labmanage
```

Save playbook output to `reports/`:

```bash
bash scripts/run_with_logging.sh playbooks/00_preflight_check.yml
bash scripts/run_with_logging.sh playbooks/01_check_connection.yml --limit pc1
```

## Notes

- Do not commit `inventory.ini` or any private keys.
- Do commit `config/lab_settings.yml` only with non-secret lab defaults.
- Generated reports may contain private lab hostnames, usernames, or IP addresses. Review before sharing.
- Use the `students` Ansible group for lab hosts.
- `ansible.cfg` is configured to disable host key checking and retry files for a lab environment.

## Documentation

| Need | Read |
| --- | --- |
| Main professor handover | `docs/professor_handover.md` |
| Quick operating commands | `docs/quick_start.md` |
| Add a new student PC | `docs/adding_new_pc.md` |
| Change packages/settings | `docs/customization_guide.md` |
| Understand the architecture quickly | `docs/project_overview.md` |
| Troubleshooting | `docs/troubleshooting.md` |

## Future use

This structure is suitable for handing over to another teacher or student, with clear documentation and reusable playbooks.
