# Customization Guide

This guide explains the simple settings files and folders a professor is most likely to edit.

## Main Idea

The normal professor workflow is:

```text
./labmanage runs the system
inventory.ini controls which PCs are managed
config/lab_settings.yml controls packages and maintenance settings
shared_materials/ contains files to copy
reports/ contains logs and evidence
```

## What `config/lab_settings.yml` Is

`config/lab_settings.yml` is the central settings file for common lab choices.

It is safe to commit because it must not contain secrets, passwords, SSH keys, IP addresses, hostnames, or private lab data.

Use it for:

- packages to install;
- shared-materials destination and ownership;
- update behavior;
- cleanup behavior;
- preflight disk and memory thresholds;
- reboot timeout.

## What The Professor Can Safely Change

The professor can safely change these values in `config/lab_settings.yml`:

- `required_packages`
- `update_package_cache`
- `upgrade_system_packages`
- `autoremove_unused_packages`
- `shared_materials_source`
- `shared_materials_destination`
- `shared_materials_owner`
- `shared_materials_group`
- `shared_materials_directory_mode`
- `shared_materials_file_mode`
- `student_autologin_enabled`
- `student_autologin_display_manager`
- `student_autologin_reboot_after_change`
- `minimum_free_disk_gb`
- `minimum_memory_mb_warning`
- `clean_package_cache`
- `clean_apt_autoremove`
- `clean_temp_files`
- `reboot_timeout_seconds`

Do not put private lab details in this file.

## Change The Package List

Edit:

```yaml
required_packages:
  - vim
  - git
  - curl
```

Add one package per line.

Then test on one PC first:

```bash
ansible-playbook -i inventory.ini playbooks/04_install_required_software.yml --limit pc1
```

## Change Shared Materials Destination

Shared materials go to the classroom student account, which is not necessarily
the Ansible administrator account. The project resolves the destination and
ownership in this order:

1. `lab_student_user` host variable
2. `lab_student_user_default` in `config/lab_settings.yml`
3. `ansible_user` as a fallback for older or simple setups

For example:

```ini
pc1 ansible_host=192.168.22.196 ansible_user=labadmin lab_student_user=student123
```

Ansible connects as `labadmin`, but shared materials are copied to
`/home/student123/Lab_Materials`, not `/home/labadmin/Lab_Materials`.

The default settings are:

```yaml
shared_materials_destination: "/home/{{ lab_student_user | default(lab_student_user_default | default(ansible_user), true) }}/Lab_Materials"
shared_materials_owner: "{{ lab_student_user | default(lab_student_user_default | default(ansible_user), true) }}"
shared_materials_group: "{{ lab_student_user | default(lab_student_user_default | default(ansible_user), true) }}"
```

## Configure Student Auto-Login

The auto-login playbook always resolves the classroom user, not the Ansible
administrator. Keep the safe defaults below unless a reboot immediately after a
successful configuration is specifically desired.

```yaml
student_autologin_enabled: true
student_autologin_display_manager: "auto"  # auto, gdm3, or lightdm
student_autologin_reboot_after_change: false
```

Use `auto` to detect GDM3 or LightDM. The playbooks never change passwords or
sudo privileges; use the separate privilege-management playbooks for those.

## Current Settings Reference

| Setting | Purpose |
| --- | --- |
| `required_packages` | Packages installed by playbook 04 |
| `update_package_cache`, `upgrade_system_packages`, `autoremove_unused_packages`, `apt_cache_valid_time_seconds` | Update/cache behavior |
| `shared_materials_source`, `shared_materials_destination`, `shared_materials_owner`, `shared_materials_group` | Student-facing material source and ownership |
| `lab_admin_user`, `lab_student_user_default`, `sudo_group_name` | Account/group defaults |
| `lab_admin_password_hash`, `lab_admin_public_key_file` | Optional labadmin credential/key settings; never plaintext or private keys |
| `student_autologin_enabled`, `student_autologin_display_manager`, `student_autologin_reboot_after_change` | Student-only graphical auto-login behavior |
| `minimum_free_disk_gb`, `minimum_memory_mb_warning` | Preflight thresholds |
| `clean_package_cache`, `clean_apt_autoremove`, `clean_temp_files`, `clean_temp_files_older_than` | Cleanup behavior and temporary-file age |
| `reboot_timeout_seconds` | Conditional reboot timeout |

Shared materials and auto-login target the classroom student account, never
labadmin. Do not put secrets, private IPs, passwords, or SSH private keys in
this configuration file.

The normal classroom-user resolution is `lab_student_user`, then
`lab_student_user_default`, then `ansible_user`. The current shared-materials
template also contains a final legacy `student` fallback if all three are empty;
do not rely on it. Set an explicit classroom user instead.

## Change Update Behavior

Edit:

```yaml
update_package_cache: true
upgrade_system_packages: true
autoremove_unused_packages: false
```

Leave `autoremove_unused_packages` as `false` unless the professor wants unused dependencies removed during the update playbook. Cleanup can also be handled separately by `06_clean_lab_computers.yml`.

## Change Cleanup Behavior

Edit:

```yaml
clean_package_cache: true
clean_apt_autoremove: true
clean_temp_files: false
```

The default cleanup is intentionally safe and does not delete student documents.

`clean_temp_files` is disabled by default. If enabled, it removes old files from `/tmp`, not files from student home directories.

## Change Preflight Thresholds

Edit:

```yaml
minimum_free_disk_gb: 2
minimum_memory_mb_warning: 2048
```

`minimum_free_disk_gb` controls when preflight fails for low disk space on `/`.

`minimum_memory_mb_warning` controls when preflight prints a low-memory warning.

## File And Folder Differences

`inventory.ini`:
Private file. Controls which student PCs are managed. This may contain IP addresses, hostnames, and SSH usernames. Do not commit it.

`config/lab_settings.yml`:
Safe shared settings. Controls packages, destinations, thresholds, cleanup options, and reboot timeout. Do not put secrets here.

`shared_materials/`:
Files placed here are copied to student PCs by `05_copy_shared_materials.yml`.

`playbooks/`:
Ansible automation files. Professors normally do not need to edit these for routine settings.

`./labmanage`:
Professor-friendly menu launcher for running the toolkit.

## Safe Workflow After Changing Settings

After changing `config/lab_settings.yml`, use this order:

1. Run the preflight check.
2. Test the changed action on one PC with `--limit pc1`.
3. Test on a small group.
4. Run on the full lab only after the smaller tests succeed.

Example:

```bash
ansible-playbook -i inventory.ini playbooks/00_preflight_check.yml
ansible-playbook -i inventory.ini playbooks/04_install_required_software.yml --limit pc1
```
