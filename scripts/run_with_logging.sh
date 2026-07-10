#!/usr/bin/env bash
#
# scripts/run_with_logging.sh
#
# Run an Ansible playbook and save the terminal output into reports/.
#
# Purpose:
#   This helper allows the professor/future maintainer to keep evidence of
#   lab checks, updates, status collection, privilege changes, auto-login
#   changes, and maintenance actions.
#
# Usage:
#   bash scripts/run_with_logging.sh playbooks/00_preflight_check.yml
#   bash scripts/run_with_logging.sh playbooks/01_check_connection.yml --limit pc1
#   bash scripts/run_with_logging.sh playbooks/02_collect_lab_status.yml --ask-pass --ask-become-pass
#
# Safety:
#   - This script always uses the private inventory.ini from the project root.
#   - This script does not store passwords.
#   - If Ansible asks for passwords, they are entered through Ansible prompts.
#   - Generated reports may contain hostnames, usernames, IP addresses, and task output.
#   - Review logs before sharing them outside the lab/team.
#   - Do not pass secrets, passwords, tokens, or plaintext credentials as command-line options.

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
  bash scripts/run_with_logging.sh playbooks/09_check_user_privileges.yml --limit pc1 -u labadmin

Notes:
  - The inventory is always inventory.ini from the project root.
  - Do not pass -i / --inventory here.
  - Do not pass passwords, tokens, or secrets as command-line options.
  - Use Ansible prompts such as --ask-pass and --ask-become-pass.
  - Logs are saved under reports/.
EOF
}

print_error() {
  echo "ERROR: $*" >&2
}

print_quoted_args() {
  if [ "$#" -eq 0 ]; then
    printf 'none'
    return 0
  fi

  printf '%q' "$1"
  shift || true

  while [ "$#" -gt 0 ]; do
    printf ' %q' "$1"
    shift || true
  done
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

validate_playbook_path() {
  local playbook="$1"

  if [[ "$playbook" == -* ]]; then
    print_error "The first argument must be a playbook path, not an option."
    return 1
  fi

  if [[ "$playbook" == /* ]]; then
    print_error "Use a project-relative playbook path, not an absolute path."
    echo "Example:"
    echo "  playbooks/00_preflight_check.yml"
    return 1
  fi

  if [[ "$playbook" == *".."* ]]; then
    print_error "Playbook paths must not contain '..'."
    echo "Use a normal project-relative path such as:"
    echo "  playbooks/00_preflight_check.yml"
    return 1
  fi

  if [ ! -f "$playbook" ]; then
    print_error "Playbook not found: $playbook"
    echo
    echo "Example:"
    echo "  bash scripts/run_with_logging.sh playbooks/00_preflight_check.yml"
    return 1
  fi

  if [[ "$playbook" != playbooks/*.yml && "$playbook" != playbooks/*.yaml ]]; then
    echo "WARNING: The selected file is not inside playbooks/."
    echo "Selected playbook: $playbook"
    echo
    echo "This is allowed, but the official project workflow uses files inside playbooks/."
    echo
  fi

  return 0
}

validate_ansible_options() {
  local arg

  for arg in "$@"; do
    case "$arg" in
      -i*|--inventory|--inventory=*)
        print_error "Do not pass inventory options to this helper."
        echo "This script always uses:"
        echo "  inventory.ini"
        return 1
        ;;
      -e|--extra-vars|--extra-vars=*|-e*)
        print_error "Do not use --extra-vars with this logged helper."
        echo "Edit config/lab_settings.yml or inventory variables instead."
        echo "This prevents bypassing safety settings from the command line."
        return 1
        ;;
      --become-password-file|--become-password-file=*|--connection-password-file|--connection-password-file=*)
        print_error "Do not pass password files through this helper."
        echo "Use --ask-pass or --ask-become-pass instead."
        return 1
        ;;
      --vault-password-file|--vault-password-file=*)
        print_error "Do not pass vault password files through this helper."
        return 1
        ;;
      *password*|*passwd*|*secret*|*token*)
        print_error "Potential secret detected in a command-line option."
        echo "Do not pass passwords, tokens, or secrets as command-line arguments."
        echo "Use Ansible prompts instead."
        return 1
        ;;
    esac
  done

  return 0
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

  validate_playbook_path "$playbook" || exit 2
  validate_ansible_options "$@" || exit 2

  if ! command -v ansible-playbook >/dev/null 2>&1; then
    print_error "ansible-playbook was not found."
    echo
    echo "Install Ansible on the teacher/control computer first."
    echo "Example on Ubuntu:"
    echo "  sudo apt update"
    echo "  sudo apt install ansible"
    exit 1
  fi

  if ! command -v tee >/dev/null 2>&1; then
    print_error "tee was not found."
    echo "The logging helper needs tee to show output and save logs at the same time."
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

  # Make generated reports private by default.
  # Logs may contain hostnames, usernames, IP addresses, task output, and system details.
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
  printf 'Options:      '
  print_quoted_args "$@"
  echo
  echo "Log file:     $log_file"
  echo
  echo "Privacy note:"
  echo "  Logs may contain hostnames, usernames, IP addresses, task output,"
  echo "  package names, system status, and other lab information."
  echo "  Review logs before sharing them outside the lab/team."
  echo
  echo "Running playbook..."
  echo "------------------------------------------------------------"
  echo

  local status=0
  local ansible_status=0
  local tee_status=0
  local pipe_status

  ansible-playbook -i "$INVENTORY_FILE" "$playbook" "$@" 2>&1 | tee "$log_file"
  pipe_status=("${PIPESTATUS[@]}")

  ansible_status="${pipe_status[0]:-1}"
  tee_status="${pipe_status[1]:-1}"

  if [ "$tee_status" -ne 0 ]; then
    echo
    print_error "Logging failed or was interrupted while writing to: $log_file"
    echo "Ansible exit code: $ansible_status"
    echo "tee/logging exit code: $tee_status"

    if [ "$ansible_status" -eq 0 ]; then
      status="$tee_status"
    else
      status="$ansible_status"
    fi
  else
    status="$ansible_status"
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
  elif [ "$tee_status" -ne 0 ]; then
    echo "Result: LOGGING ERROR"
    echo "The playbook may or may not have completed. Check the terminal output above."
    echo "Exit code: $status"
  elif [ "$unreachable_count" -gt 0 ] && [ "$failed_count" -eq 0 ]; then
    echo "Result: COMPLETED WITH UNREACHABLE HOSTS"
    echo "Some selected PCs were offline or unreachable."
    echo "All reachable PCs may have completed their tasks."
    echo "Check the play recap above and the saved log file for details."
    echo "Ansible exit code: $status"
  else
    echo "Result: FAILED"
    echo "Exit code: $status"

    if [ "$unreachable_count" -gt 0 ]; then
      echo "Unreachable hosts were reported. Check network, power state, SSH, and inventory."
    fi

    if [ "$failed_count" -gt 0 ]; then
      echo "One or more reachable hosts had task failures."
    fi
  fi

  echo
  echo "Recap totals from log:"
  echo "  unreachable: $unreachable_count"
  echo "  failed:      $failed_count"
  echo
  echo "Log saved to:"
  echo "  $log_file"
  echo

  exit "$status"
}

main "$@"
