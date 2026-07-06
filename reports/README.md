# Reports

This directory is reserved for playbook outputs, audit notes, and lab status reports.

Use the logging helper when you want to save terminal output:

```bash
bash scripts/run_with_logging.sh playbooks/00_preflight_check.yml
bash scripts/run_with_logging.sh playbooks/01_check_connection.yml --limit pc1
```

Generated reports may contain private hostnames, usernames, IP addresses, or system details. Review and anonymize them before sharing outside the lab.
