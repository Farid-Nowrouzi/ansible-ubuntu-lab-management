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

Edit:

```yaml
shared_materials_destination: /home/student/Lab_Materials
shared_materials_owner: student
shared_materials_group: student
```

Use a destination that exists under the correct student account, or make sure the configured owner and group are valid on the student PCs.

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
