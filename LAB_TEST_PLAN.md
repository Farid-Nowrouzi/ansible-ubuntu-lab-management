# Controlled Lab Test Plan

## Status

Controlled `pc1` testing is pending. Do not treat this plan as evidence that
syntax checks, auto-login, or full-lab operation have already succeeded.

## Safety rule

Do not start with all PCs. Test `pc1`, then a small group, and only then
consider the full `students` group during an approved maintenance window.

## Ubuntu PC0 preparation

```bash
cd ~/ansible-ubuntu-lab-management
git pull origin main
chmod +x labmanage
git update-index --chmod=+x labmanage

bash -n labmanage
bash -n scripts/manage_lab.sh
bash -n scripts/run_with_logging.sh

for f in playbooks/*.yml; do
  ansible-playbook --syntax-check "$f" || break
done
```

Do not continue if any syntax check fails. Keep `inventory.ini` private and
confirm that `pc1` uses `ansible_user=labadmin` and the correct
`lab_student_user`.

## Controlled pc1 sequence

1. Confirm labadmin connectivity.

   ```bash
   ansible -i inventory.ini pc1 -u labadmin -m ping
   ansible -i inventory.ini pc1 -u labadmin -m command -a "whoami" -b --ask-become-pass
   ```

   Expected sudo result: `root`.

2. Inspect privileges.

   ```bash
   ansible-playbook -i inventory.ini playbooks/09_check_user_privileges.yml --limit pc1 -u labadmin
   ```

   Expected hardened state: labadmin has sudo; the classroom user does not.

3. If the classroom user still has sudo, revoke it only after step 1 succeeds.

   ```bash
   ansible-playbook -i inventory.ini playbooks/10_revoke_student_sudo.yml --limit pc1 -u labadmin --ask-become-pass
   ansible-playbook -i inventory.ini playbooks/09_check_user_privileges.yml --limit pc1 -u labadmin
   ```

4. Configure auto-login for the classroom user, never labadmin.

   ```bash
   ansible-playbook -i inventory.ini playbooks/12_configure_student_autologin.yml --limit pc1 -u labadmin --ask-become-pass
   ```

5. Reboot or log out during a maintenance window and physically verify that
   `pc1` opens the student desktop, not labadmin.

6. Confirm Ansible still works after the reboot/logout.

   ```bash
   ansible -i inventory.ini pc1 -u labadmin -m ping
   ```

7. Disable auto-login if needed and verify the normal login screen.

   ```bash
   ansible-playbook -i inventory.ini playbooks/13_disable_student_autologin.yml --limit pc1 -u labadmin --ask-become-pass
   ```

## Record

For each run, record the date, host, command, result, unreachable hosts,
display manager detected, and any manual action. Save logs with
`scripts/run_with_logging.sh`, but review them before sharing.
