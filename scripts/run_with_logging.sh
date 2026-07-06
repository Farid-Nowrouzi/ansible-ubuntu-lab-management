#!/usr/bin/env bash
#
# scripts/run_with_logging.sh
#
# Run an Ansible playbook and save the terminal output into reports/.
#
# Purpose:
#   This helper allows the professor/future maintainer to keep evidence of
#   lab checks, updates, status collection, and maintenance actions.
#
# Usage:
#   bash scripts/run_with_logging.sh playbooks/00_preflight_check.yml
#   bash scripts/run_with_logging.sh playbooks/01_check_connection.yml --limit pc1
#   bash scripts/run_with_logging.sh playbooks/02_collect_lab_status.yml --ask-pass --ask-become-pass
#
# Safety:
#   - This script does not store passwords.
#   - If Ansible asks for passwords, they are entered through Ansible prompts.
#   - Generated reports may contain hostnames, usernames, and IP addresses.
#   - Review logs before sharing them outside the lab/team.

set -Euo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
INVENTORY_FILE="$PROJECT_ROOT/inventory.ini"
REPORTS_DIR="$PROJECT_ROOT/reports"

trap 'echo; echo "Interrupted. Log may be incomplete."; exit 130' INT

show_usage() {
  cat <<EOF
Usage:
  bash scripts/run_with_logging.sh PLAYBOOK [ANSIBLE_OPTIONS...]

Examples:
  bash scripts/run_with_logging.sh playbooks/00_preflight_check.yml
  bash scripts/run_with_logging.sh playbooks/01_check_connection.yml --limit pc1
  bash scripts/run_with_logging.sh playbooks/02_collect_lab_status.yml --ask-pass --ask-become-pass

Notes:
  - Do not type passwords as command-line options.
  - Use Ansible prompts such as --ask-pass and --ask-become-pass.
  - Logs are saved under reports/.
EOF
}

print_error() {
  echo "ERROR: $*" >&2
}

sum_recap_value() {
  local key="$1"
  local file="$2"

  awk -v key="$key" '
    $0 ~ /:[[:space:]]/ && $0 ~ key "=" {
      for (i = 1; i <= NF; i++) {
        split($i, field, "=")
        if (field[1] == key) {
          total += field[2]
        }
      }
    }
    END { print total + 0 }
  ' "$file"
}

main() {
  if [ "$#" -lt 1 ]; then
    show_usage
    exit 2
  fi

  case "${1:-}" in
    -h|--help)
      show_usage
      exit 0
      ;;
  esac

  cd "$PROJECT_ROOT"

  local playbook="$1"
  shift

  if [[ "$playbook" == -* ]]; then
    print_error "The first argument must be a playbook path, not an option."
    echo
    show_usage
    exit 2
  fi

  if ! command -v ansible-playbook >/dev/null 2>&1; then
    print_error "ansible-playbook was not found."
    echo "Install Ansible on the teacher/control computer first."
    echo "Example on Ubuntu:"
    echo "  sudo apt update"
    echo "  sudo apt install ansible"
    exit 1
  fi

  if [ ! -f "$INVENTORY_FILE" ]; then
    print_error "inventory.ini was not found."
    echo
    echo "Create it first from the example:"
    echo "  cp inventory.example.ini inventory.ini"
    echo "  nano inventory.ini"
    echo
    echo "Important:"
    echo "  Do not commit inventory.ini because it contains private lab details."
    exit 1
  fi

  if [ ! -f "$playbook" ]; then
    print_error "Playbook not found: $playbook"
    echo
    echo "Example:"
    echo "  bash scripts/run_with_logging.sh playbooks/00_preflight_check.yml"
    exit 1
  fi

  if [[ "$playbook" != playbooks/*.yml && "$playbook" != playbooks/*.yaml ]]; then
    echo "WARNING: The selected file is not inside playbooks/."
    echo "Selected playbook: $playbook"
    echo
    echo "This is allowed, but the official project workflow uses files inside playbooks/."
    echo
  fi

  # Make generated reports private by default.
  # This matters because logs may contain hostnames, usernames, or IP addresses.
  umask 077
  if ! mkdir -p "$REPORTS_DIR"; then
    print_error "Could not create reports directory: $REPORTS_DIR"
    echo "Check folder permissions on the teacher/control computer."
    exit 1
  fi

  if [ ! -w "$REPORTS_DIR" ]; then
    print_error "Reports directory is not writable: $REPORTS_DIR"
    echo "Check folder permissions before running logged playbooks."
    exit 1
  fi

  local timestamp
  timestamp="$(date +%Y%m%d_%H%M%S)"

  local playbook_name
  playbook_name="$(basename "$playbook")"
  playbook_name="${playbook_name%.*}"

  local safe_name
  safe_name="$(printf '%s' "$playbook_name" | tr -c 'A-Za-z0-9_-' '_')"

  local log_file
  log_file="$REPORTS_DIR/${safe_name}_${timestamp}.log"

  echo "============================================================"
  echo " Linux Lab Management Toolkit - Logged Ansible Run"
  echo "============================================================"
  echo "Project root: $PROJECT_ROOT"
  echo "Playbook:     $playbook"
  echo "Inventory:    inventory.ini"
  echo "Log file:     $log_file"
  echo
  echo "Privacy note:"
  echo "  Logs may contain hostnames, usernames, IP addresses, and task output."
  echo "  Review logs before sharing them outside the lab/team."
  echo
  echo "Running playbook..."
  echo "------------------------------------------------------------"
  echo

  local status=0

  if ansible-playbook -i "$INVENTORY_FILE" "$playbook" "$@" 2>&1 | tee "$log_file"; then
    status=0
  else
    status="${PIPESTATUS[0]}"
  fi

  local unreachable_count=0
  local failed_count=0

  if [ -f "$log_file" ]; then
    unreachable_count="$(sum_recap_value "unreachable" "$log_file")"
    failed_count="$(sum_recap_value "failed" "$log_file")"
  fi

  echo
  echo "------------------------------------------------------------"
  if [ "$status" -eq 0 ]; then
    echo "Result: SUCCESS"
  elif [ "$unreachable_count" -gt 0 ] && [ "$failed_count" -eq 0 ]; then
    echo "Result: COMPLETED WITH UNREACHABLE HOSTS"
    echo "Some selected PCs were offline or unreachable."
    echo "All reachable PCs completed their tasks."
    echo "Check the play recap above and the saved log file for details."
    echo "Ansible exit code: $status"
  else
    echo "Result: FAILED"
    echo "Exit code: $status"
    if [ "$unreachable_count" -gt 0 ]; then
      echo "Unreachable hosts were reported. Check the play recap above."
    fi
    if [ "$failed_count" -gt 0 ]; then
      echo "One or more reachable hosts had task failures."
    fi
  fi

  echo "Log saved to:"
  echo "  $log_file"
  echo

  exit "$status"
}

main "$@"
