#!/usr/bin/env bash
#
# scripts/manage_lab.sh
#
# Professor-friendly menu for the Linux Lab Management Toolkit.
#
# Purpose:
#   Run common Ansible lab-management actions from a simple interactive menu.
#
# Recommended launcher:
#   ./labmanage
#
# Direct usage:
#   bash scripts/manage_lab.sh
#
# Safety:
#   - Read-only checks can run normally.
#   - Changing actions require confirmation.
#   - Reboot requires stronger confirmation.
#   - Passwords are never stored in this script.
#   - Output is saved through scripts/run_with_logging.sh when available.

set -Eeuo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
RUN_WITH_LOGGING="$PROJECT_ROOT/scripts/run_with_logging.sh"
INVENTORY_FILE="$PROJECT_ROOT/inventory.ini"
CONFIG_FILE="$PROJECT_ROOT/config/lab_settings.yml"
SHARED_MATERIALS_DIR="$PROJECT_ROOT/shared_materials"

trap 'echo; echo "Interrupted. Returning safely."; exit 130' INT

trim_input() {
  local value="$1"
  value="${value//$'\r'/}"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf '%s' "$value"
}

pause() {
  echo
  read -r -p "Press Enter to return to the menu..." || true
}

print_header() {
  clear 2>/dev/null || true
  echo "============================================================"
  echo " Linux Lab Management Toolkit"
  echo "============================================================"
  echo " Project root: $PROJECT_ROOT"
  echo
  echo " Recommended safe workflow:"
  echo "   1. Run preflight check"
  echo "   2. Check connections"
  echo "   3. Collect lab status"
  echo "   4. Test changing actions on ONE PC first"
  echo "   5. Expand to 2-3 PCs"
  echo "   6. Run on all reachable PCs only after successful checks"
  echo "   Edit config/lab_settings.yml to change packages, shared-materials destination, and maintenance settings."
  echo
}

check_requirements() {
  if ! command -v ansible-playbook >/dev/null 2>&1; then
    echo "ERROR: ansible-playbook was not found."
    echo
    echo "Install Ansible on the teacher/control computer first."
    echo "Example on Ubuntu:"
    echo "  sudo apt update"
    echo "  sudo apt install ansible"
    pause
    return 1
  fi

  if [ ! -f "$INVENTORY_FILE" ]; then
    echo "ERROR: inventory.ini was not found."
    echo
    echo "Create the private inventory file first:"
    echo "  cp inventory.example.ini inventory.ini"
    echo "  nano inventory.ini"
    echo
    echo "Important:"
    echo "  Do not commit inventory.ini because it contains private lab details."
    pause
    return 1
  fi

  if [ ! -d "$PROJECT_ROOT/playbooks" ]; then
    echo "ERROR: playbooks/ directory was not found."
    echo "This does not look like a complete project folder."
    pause
    return 1
  fi

  if [ ! -f "$CONFIG_FILE" ]; then
    echo "ERROR: config/lab_settings.yml was not found."
    echo
    echo "This file contains safe lab settings used by several playbooks."
    echo "Restore it before running maintenance actions."
    pause
    return 1
  fi

  return 0
}

ask_limit_args() {
  local include_localhost="${1:-no}"
  local target

  echo
  echo "Target selection:"
  echo "  - Leave empty to use the playbook default."
  echo "  - Enter pc1 to run on one computer."
  echo "  - Enter pc1,pc2 to run on a small group."
  echo "  - Enter students to run on all student PCs."
  echo "  - Type q to cancel and return to the menu."
  echo
  read -r -p "Target host/group (blank = playbook default): " target || target=""
  target="$(trim_input "$target")"

  LIMIT_ARGS=()

  case "${target,,}" in
    q|quit|exit|cancel)
      echo "Cancelled."
      return 1
      ;;
  esac

  if [ -n "$target" ]; then
    if [[ "$target" == -* ]]; then
      echo "ERROR: Target must be a host/group name, not an Ansible option."
      echo "Example target: pc1"
      return 1
    fi

    if [[ ! "$target" =~ ^[A-Za-z0-9_.:-]+(,[A-Za-z0-9_.:-]+)*$ ]]; then
      echo "ERROR: Target contains unsupported characters."
      echo "Use inventory host or group names such as pc1, pc1,pc2, or students."
      return 1
    fi

    # The preflight playbook includes a localhost validation play.
    # If the user limits to pc1, include localhost too so inventory validation is not skipped.
    if [ "$include_localhost" = "yes" ] && [[ "$target" != *"localhost"* ]]; then
      target="localhost,$target"
    fi

    LIMIT_ARGS=(--limit "$target")
  fi

  return 0
}

ask_auth_args() {
  local ssh_answer
  local sudo_answer
  local advanced_answer
  local advanced_text

  EXTRA_ARGS=()

  echo
  echo "Authentication options:"
  echo "  Passwords are not written here."
  echo "  If needed, Ansible will ask for them securely."
  echo

  read -r -p "Need SSH password prompt? [y/N]: " ssh_answer || ssh_answer=""
  ssh_answer="$(trim_input "$ssh_answer")"

  if [[ "$ssh_answer" =~ ^[Yy]([Ee][Ss])?$ ]]; then
    EXTRA_ARGS+=(--ask-pass)
  fi

  read -r -p "Need sudo/admin password prompt? [y/N]: " sudo_answer || sudo_answer=""
  sudo_answer="$(trim_input "$sudo_answer")"

  if [[ "$sudo_answer" =~ ^[Yy]([Ee][Ss])?$ ]]; then
    EXTRA_ARGS+=(--ask-become-pass)
  fi

  echo
  read -r -p "Add advanced Ansible options? [y/N]: " advanced_answer || advanced_answer=""
  advanced_answer="$(trim_input "$advanced_answer")"

  if [[ "$advanced_answer" =~ ^[Yy]([Ee][Ss])?$ ]]; then
    echo "Example: --check"
    echo "Do not enter --limit or -i here; the menu handles target and inventory."
    echo "Do not enter passwords here."
    read -r -p "Advanced options: " advanced_text || advanced_text=""
    advanced_text="$(trim_input "$advanced_text")"

    if [ -n "$advanced_text" ]; then
      # Simple splitting is intentional for optional CLI flags.
      # Do not enter secrets/passwords here.
      local old_ifs="$IFS"
      IFS=' '
      # shellcheck disable=SC2206
      ADVANCED_ARGS=($advanced_text)
      IFS="$old_ifs"

      for arg in "${ADVANCED_ARGS[@]}"; do
        case "$arg" in
          -i|--inventory|--inventory=*|-l|--limit|--limit=*)
            echo "ERROR: Do not enter inventory or limit options as advanced options."
            echo "Use the menu target prompt instead."
            return 1
            ;;
          *password*|*passwd*|*secret*)
            echo "ERROR: Do not enter passwords or secrets as command-line options."
            echo "Use Ansible password prompts instead."
            return 1
            ;;
        esac
      done

      EXTRA_ARGS+=("${ADVANCED_ARGS[@]}")
    fi
  fi
}

confirm_run_action() {
  local label="$1"
  local strong_confirm="${2:-no}"

  echo
  if [ "$strong_confirm" = "yes" ]; then
    echo "CRITICAL WARNING: Reboot may interrupt users and active class work."
    echo
    echo "Only continue if:"
    echo "  - Class is not active."
    echo "  - You already tested on one PC."
    echo "  - You understand selected PCs may restart."
    echo
    read -r -p "Type YES to run this reboot check: " answer || answer=""
    answer="$(trim_input "$answer")"
    [ "$answer" = "YES" ]
    return
  fi

  echo "WARNING: $label can change student computers."
  echo
  echo "Only continue if:"
  echo "  - Class is not active."
  echo "  - You already ran the preflight check."
  echo "  - You tested on one PC first when appropriate."
  echo
  read -r -p "Type yes to run this action: " answer || answer=""
  answer="$(trim_input "$answer")"

  [ "$answer" = "yes" ]
}

run_playbook() {
  local label="$1"
  local playbook="$2"
  local changing="${3:-no}"
  local strong_confirm="${4:-no}"
  local include_localhost_in_limit="${5:-no}"
  local status=0

  check_requirements || return

  if [ ! -f "$PROJECT_ROOT/$playbook" ]; then
    echo "ERROR: Missing playbook:"
    echo "  $playbook"
    pause
    return
  fi

  if [ "$playbook" = "playbooks/05_copy_shared_materials.yml" ] && [ ! -d "$SHARED_MATERIALS_DIR" ]; then
    echo "ERROR: shared_materials/ directory was not found."
    echo
    echo "Create the directory and place approved teaching files there before copying materials."
    pause
    return
  fi

  ask_limit_args "$include_localhost_in_limit" || {
    pause
    return
  }

  ask_auth_args || {
    pause
    return
  }

  echo
  echo "------------------------------------------------------------"
  echo "Selected action: $label"
  echo "Playbook:        $playbook"

  if [ "${#LIMIT_ARGS[@]}" -gt 0 ]; then
    echo "Limit:           ${LIMIT_ARGS[*]}"
  else
    echo "Limit:           playbook default (usually all hosts in the playbook)"
  fi

  if [ "${#EXTRA_ARGS[@]}" -gt 0 ]; then
    echo "Extra options:   ${EXTRA_ARGS[*]}"
  else
    echo "Extra options:   none"
  fi
  echo "------------------------------------------------------------"
  echo

  if [ "$changing" = "yes" ]; then
    if ! confirm_run_action "$label" "$strong_confirm"; then
      echo "Cancelled."
      pause
      return
    fi
    echo
  fi

  cd "$PROJECT_ROOT"

  if [ -f "$RUN_WITH_LOGGING" ]; then
    echo "Output will be shown on screen and saved in reports/."
    echo
    if bash "$RUN_WITH_LOGGING" "$playbook" "${LIMIT_ARGS[@]}" "${EXTRA_ARGS[@]}"; then
      status=0
    else
      status=$?
    fi
  else
    echo "Logging helper is missing. Running without saved log."
    echo
    if ansible-playbook "$playbook" "${LIMIT_ARGS[@]}" "${EXTRA_ARGS[@]}"; then
      status=0
    else
      status=$?
    fi
  fi

  echo
  if [ "$status" -eq 0 ]; then
    echo "Action completed successfully."
  else
    echo "Action finished with errors."
    echo "Exit code: $status"
    echo "Check the output above and any saved report/log file."
  fi

  pause
}

show_menu() {
  print_header
  echo "Menu:"
  echo "  1. Run preflight check"
  echo "  2. Check connections"
  echo "  3. Collect lab status"
  echo "  4. Update systems"
  echo "  5. Install required software"
  echo "  6. Copy shared materials"
  echo "  7. Clean lab computers"
  echo "  8. Reboot if required"
  echo "  9. Exit"
  echo
}

main() {
  cd "$PROJECT_ROOT"

  while true; do
    show_menu

    if ! read -r -p "Enter a number (1-9), or q to exit: " choice; then
      echo
      echo "No input received. Exiting."
      exit 0
    fi

    choice="$(trim_input "$choice")"
    choice="${choice,,}"

    case "$choice" in
      1|01)
        run_playbook "Run preflight check" \
          "playbooks/00_preflight_check.yml" \
          "no" "no" "yes"
        ;;
      2|02)
        run_playbook "Check connections" \
          "playbooks/01_check_connection.yml" \
          "no" "no" "no"
        ;;
      3|03)
        run_playbook "Collect lab status" \
          "playbooks/02_collect_lab_status.yml" \
          "no" "no" "no"
        ;;
      4|04)
        run_playbook "Update systems" \
          "playbooks/03_update_system.yml" \
          "yes" "no" "no"
        ;;
      5|05)
        run_playbook "Install required software" \
          "playbooks/04_install_required_software.yml" \
          "yes" "no" "no"
        ;;
      6|06)
        run_playbook "Copy shared materials" \
          "playbooks/05_copy_shared_materials.yml" \
          "yes" "no" "no"
        ;;
      7|07)
        run_playbook "Clean lab computers" \
          "playbooks/06_clean_lab_computers.yml" \
          "yes" "no" "no"
        ;;
      8|08)
        run_playbook "Reboot if required" \
          "playbooks/07_reboot_if_required.yml" \
          "yes" "yes" "no"
        ;;
      9|09)
        echo "Goodbye."
        exit 0
        ;;
      q|quit|exit)
        echo "Goodbye."
        exit 0
        ;;
      "")
        ;;
      *)
        echo "Invalid option. Enter a number from 1 to 9, or q to exit."
        pause
        ;;
    esac
  done
}

main "$@"
