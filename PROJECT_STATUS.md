# Project Status

## Overview

This document summarizes the current status of the Linux/Ubuntu lab management project.
The system is designed around a teacher/main PC acting as an Ansible control node and student lab PCs as managed nodes.
The focus is on reusable playbooks, safe SSH management, and clear handover documentation.

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
- `inventory.ini` created and corrected for formatting and username issues.
- `ansible -i inventory.ini students -m ping` tested successfully.
- Around seven reachable student PCs returned `SUCCESS` and `pong`.

## Estimated Completion

- Current estimated completion: 40–50%
- After core playbooks are tested: 70–80%
- After documentation and handover are complete: 90–100%

## Current Architecture

Teacher/Main PC → Ansible → SSH → Student PCs

## Status Summary

The control node can now communicate with reachable student PCs using SSH and Ansible.
The next phase is to create, validate, and document the lab management playbooks so the project can become a reusable toolkit for future instructors.

## Remaining Work

- Test the connection playbook.
- Test the status collection playbook.
- Test the update playbook carefully.
- Test the software installation playbook.
- Test controlled shared materials copy.
- Test the cleanup playbook.
- Test the reboot-if-required playbook only when safe.
- Improve documentation for the professor or future users.
- Prepare the final handover package.

## Safety Notes

- Do not store passwords in GitHub.
- Do not upload private SSH keys.
- Keep the real `inventory.ini` file private or use a private repository.
- Test dangerous playbooks on one PC first before applying them to the entire lab.

## Next Milestone

Working Ansible Toolkit v1

This next milestone will include tested core playbooks, reliable lab status gathering, and strong documentation for handover.
