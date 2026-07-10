# Linux Lab Management

An Ansible toolkit for managing Ubuntu student laboratory PCs from one
professor/control PC. It supports routine maintenance, controlled student
privilege management, and classroom-student graphical auto-login.

## Security model

- `labadmin` is the administrator account used by Ansible and the professor.
- `student123` (or the configured classroom user) is the student-facing
  account and should normally not have sudo.
- Student-facing tasks resolve the user in this order: `lab_student_user`,
  `lab_student_user_default`, then `ansible_user` for older/simple setups.
- Keep the real `inventory.ini` private. Do not commit it, passwords, or SSH
  private keys.

Example private-inventory host entry:

```ini
pc1 ansible_host=192.168.x.x ansible_user=labadmin lab_student_user=student123
```

## Playbooks

| Playbook | Purpose |
| --- | --- |
| `00_preflight_check.yml` | Read-only readiness and sudo check |
| `01_check_connection.yml` | Verify Ansible connectivity |
| `02_collect_lab_status.yml` | Collect read-only system status |
| `03_update_system.yml` | Update Ubuntu packages |
| `04_install_required_software.yml` | Install configured packages |
| `05_copy_shared_materials.yml` | Copy materials to the classroom user |
| `06_clean_lab_computers.yml` | Controlled APT and optional `/tmp` cleanup |
| `07_reboot_if_required.yml` | Reboot only when Ubuntu requests it |
| `08_setup_labadmin_user.yml` | Create/prepare `labadmin` safely |
| `09_check_user_privileges.yml` | Read-only privilege report |
| `10_revoke_student_sudo.yml` | Remove sudo from the classroom user safely |
| `11_grant_student_sudo.yml` | Temporary/rollback sudo grant |
| `12_configure_student_autologin.yml` | Configure student graphical auto-login |
| `13_disable_student_autologin.yml` | Disable managed graphical auto-login |

## Safe workflow

1. Test `pc1` first; do not start with the full lab.
2. Run preflight, connection, and status checks.
3. Set up and test `labadmin` SSH and sudo.
4. Check privileges, then revoke student sudo when appropriate.
5. Configure auto-login only for the limited classroom user.
6. Reboot or log out and physically verify the student desktop.
7. Test a small group before any full-lab action.

Changing menu actions require an explicit target and confirmation.

## Start on Ubuntu PC0

```bash
chmod +x labmanage
git update-index --chmod=+x labmanage
./labmanage
```

Copy the example inventory before first use:

```bash
cp inventory.example.ini inventory.ini
```

Run syntax checks and a controlled `pc1` test before using changing playbooks.
Those checks and real-lab validation are still pending; see
`LAB_TEST_PLAN.md` and `docs/professor_user_manual.md`.

## Important security note

`ansible.cfg` currently has `host_key_checking = False` as a lab convenience.
This is a security trade-off: the professor or maintainer should review it
before a wider rollout.

Generated reports can include hostnames, usernames, IP addresses, and system
details. Review them before sharing.

## Documentation

- `docs/professor_user_manual.md` — day-to-day operation
- `docs/playbook_reference.md` — playbook details
- `docs/setup_guide.md` and `docs/quick_start.md` — PC0 setup
- `docs/customization_guide.md` — settings reference
- `docs/security_guidelines.md` — operational security
- `docs/troubleshooting.md` — common failures
- `LAB_TEST_PLAN.md` — controlled pc1 test plan
