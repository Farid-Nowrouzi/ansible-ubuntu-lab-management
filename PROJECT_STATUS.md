# Project Status

## Current status

The code audit is complete and code-level blockers found by that audit have
been fixed. The project supports playbooks `00` through `13`, including
privilege management and student auto-login management.

## Validation completed in this workspace

- Bash syntax checks passed through Git Bash for `labmanage`,
  `scripts/manage_lab.sh`, and `scripts/run_with_logging.sh`.
- YAML and Jinja parsing passed for `config/lab_settings.yml` and playbooks
  `00` through `13`.

## Validation still pending

- Ansible `--syntax-check` on Ubuntu PC0.
- Controlled real-lab test on `pc1`.
- Physical verification of student auto-login after reboot/logout.
- Small-group and full-lab rollout.

## Remaining operational blockers

1. Ensure the launcher executable bit is committed:

   ```bash
   chmod +x labmanage
   git update-index --chmod=+x labmanage
   ```

2. Run the Ubuntu PC0 checks in `LAB_TEST_PLAN.md`.
3. Complete the controlled `pc1` workflow before a wider rollout.
4. Review the host-key-checking trade-off in `ansible.cfg`.

## Honest rollout statement

The project is **not yet fully lab-tested or rolled out**. It is prepared for
controlled `pc1` validation after the pending Ubuntu checks.
