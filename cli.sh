#!/usr/bin/env bash
set -e

# Diátaxis Docs Engine CLI
# Interactive launcher for documentation processing

COMMANDS=(
  "analyze refs"
  "process refs"
  "categorize [file]"
  "refine [file] as [type]"
  "what's missing"
)

print_header() {
  echo ""
  echo "╔═══════════════════════════════════════╗"
  echo "║       Diátaxis Docs Engine CLI        ║"
  echo "╚═══════════════════════════════════════╝"
  echo ""
}

select_service() {
  echo "Select service:"
  echo ""
  echo "  1) claude  - Claude Code CLI (interactive)"
  echo "  2) ralph   - Autonomous mode (runs until done)"
  echo "  3) cursor  - Open in Cursor IDE"
  echo ""
  read -p "Enter choice [1-3]: " choice
  
  case $choice in
    1) SERVICE="claude" ;;
    2) SERVICE="ralph" ;;
    3) SERVICE="cursor" ;;
    *) echo "Invalid choice"; exit 1 ;;
  esac
}

select_command() {
  echo ""
  echo "Select command:"
  echo ""
  for i in "${!COMMANDS[@]}"; do
    echo "  $((i+1))) ${COMMANDS[$i]}"
  done
  echo ""
  echo "  c) Custom prompt"
  echo ""
  read -p "Enter choice [1-${#COMMANDS[@]}/c]: " cmd_choice
  
  if [[ "$cmd_choice" == "c" ]]; then
    read -p "Enter custom prompt: " COMMAND
  elif [[ "$cmd_choice" =~ ^[0-9]+$ ]] && [ "$cmd_choice" -ge 1 ] && [ "$cmd_choice" -le "${#COMMANDS[@]}" ]; then
    COMMAND="${COMMANDS[$((cmd_choice-1))]}"
  else
    echo "Invalid choice"
    exit 1
  fi
}

run_claude() {
  echo ""
  echo "Running: claude \"$COMMAND\""
  echo "─────────────────────────────────────────"
  echo "$COMMAND" | claude
}

run_ralph() {
  echo ""
  # Pass through to ralph.sh which handles its own output and signals
  exec .ralph/ralph.sh
}

run_cursor() {
  echo ""
  echo "Opening Cursor with command copied to clipboard..."
  echo "$COMMAND" | pbcopy 2>/dev/null || echo "$COMMAND" | xclip -selection clipboard 2>/dev/null || true
  echo "Command: $COMMAND"
  echo ""
  echo "Paste into Cursor chat (Cmd+V / Ctrl+V)"
  
  # Try to open Cursor
  if command -v cursor &> /dev/null; then
    cursor .
  elif [ -d "/Applications/Cursor.app" ]; then
    open -a "Cursor" .
  else
    echo "Cursor not found in PATH. Open manually."
  fi
}

# Main
print_header
select_service

if [[ "$SERVICE" == "ralph" ]]; then
  run_ralph
else
  select_command
  
  if [[ "$SERVICE" == "claude" ]]; then
    run_claude
  elif [[ "$SERVICE" == "cursor" ]]; then
    run_cursor
  fi
fi
