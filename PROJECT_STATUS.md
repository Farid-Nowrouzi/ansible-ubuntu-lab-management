# Project Status

## Overview

This document summarizes the current status of the Linux/Ubuntu lab management project.
The system is designed around a teacher/main PC acting as an Ansible control node and student lab PCs as managed nodes.
The focus is on reusable playbooks, safe SSH management, practical helper scripts, saved test evidence, and clear handover documentation.

## Current Progress

The lab environment has been assessed and the initial communication foundation is in place.
Key progress includes:

- Network discovery performed in the computer lab.
- Working and non-working PCs identified.
- Disconnected machines found due to unplugged Ethernet cables.
- IP addresses verified for lab machines.
- Some student machines reported both 192.x.x.x and 172.x.x.x addresses.
- OpenSSH Server installed where required.
- SSH service checked on student machines.
- Manual SSH connection from the teacher PC to student PCs validated.
- SSH keys generated and copied using `ssh-copy-id`.
- Passwordless SSH tested successfully.
- Ansible installed on the teacher/main PC.
- Ansible project directory created.
- `inventory.ini` created locally and corrected for formatting and username issues.
- `ansible -i inventory.ini students -m ping` tested successfully.
- Around seven reachable student PCs returned `SUCCESS` and `pong`.
- Eight project playbooks are now present, including the read-only `00_preflight_check.yml`.
- A root `labmanage` menu launcher, helper scripts, and final test report template have been added for handover.
- A safe central settings file, `config/lab_settings.yml`, now controls normal lab package, shared-materials, update, cleanup, threshold, and reboot-timeout settings.

## Estimated Completion

- Current estimated completion: 65-75%
- After real lab syntax/runtime testing: 80-90%
- After final professor handover review: 90-100%

## Current Architecture

Teacher/Main PC -> Ansible -> SSH -> Student PCs

## Status Summary

The control node can communicate with reachable student PCs using SSH and Ansible.
The toolkit now includes a preflight safety gate, connection check, status collection, update, install, copy, cleanup, and conditional reboot playbooks.
Relevant playbooks now load safe defaults from `config/lab_settings.yml`, while private host details remain in `inventory.ini`.

The next phase is real-lab validation: syntax check all playbooks, run preflight, test one PC first, expand to a small group, and record results in `FINAL_TEST_REPORT.md`.

## Remaining Work

- Run syntax checks for all playbooks on the Ubuntu control node.
- Test the new preflight playbook.
- Review `config/lab_settings.yml` with the professor and adjust package/destination settings if needed.
- Test the `./labmanage` menu and logging helper scripts.
- Test the connection playbook.
- Test the status collection playbook.
- Test the update playbook carefully.
- Test the software installation playbook.
- Test controlled shared materials copy.
- Test the cleanup playbook.
- Test the reboot-if-required playbook only when safe.
- Fill `FINAL_TEST_REPORT.md` after real lab validation.
- Prepare the final handover package.

## Safety Notes

- Do not store passwords in GitHub.
- Do not upload private SSH keys.
- Keep the real `inventory.ini` file private or use a private repository.
- Keep `config/lab_settings.yml` free of secrets, IP addresses, and private hostnames.
- Generated reports may contain hostnames, usernames, or IP addresses. Review before sharing.
- Test changing playbooks on one PC first before applying them to the entire lab.
- Do not run disruptive playbooks during active class time.

## Next Milestone

Working Ansible Toolkit v1

This next milestone will include tested core playbooks, a reliable preflight safety gate, lab status gathering, saved test evidence, and strong documentation for handover.
