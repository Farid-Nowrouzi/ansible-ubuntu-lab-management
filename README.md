# Linux Lab Management

This project is a starter Ansible-based management system for Ubuntu lab computers.
It is designed for a teacher or professor who wants to manage student PCs from one Ansible control node.

## Purpose

- Ping all student computers to verify SSH connectivity.
- Collect lab status information safely with read-only commands.
- Keep student lab machines updated and clean.
- Install useful software packages.
- Distribute shared teaching materials to student home directories.
- Reboot student machines only when required.

## Project layout

- `ansible.cfg`: Control node Ansible configuration.
- `inventory.example.ini`: Example inventory with the `students` group.
- `playbooks/`: Reusable Ansible playbooks for lab management.
- `docs/`: Setup, user manual, troubleshooting, and maintenance guides.
- `shared_materials/`: Placeholder for materials to copy to lab computers.
- `reports/`: Output and generated report placeholder directory.

## Getting started

1. Copy `inventory.example.ini` to `inventory.ini`.
2. Update `inventory.ini` with the hostnames or IP addresses of student lab computers.
3. Run a simple connection check:

```bash
ansible-playbook playbooks/01_check_connection.yml
```

4. Review and run additional playbooks from `playbooks/` as needed.

## Notes

- Do not commit `inventory.ini` or any private keys.
- Use the `students` Ansible group for lab hosts.
- `ansible.cfg` is configured to disable host key checking and retry files for a lab environment.

## Future use

This structure is suitable for handing over to another teacher or student, with clear documentation and reusable playbooks.
