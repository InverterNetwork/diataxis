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

check_goal() {
  if [ -f "GOAL.md" ]; then
    # Check if GOAL.md has user content (more than just the template)
    content=$(grep -v '^#\|^>\|^<\|^$\|^--' GOAL.md 2>/dev/null | tr -d '[:space:]')
    if [ -z "$content" ]; then
      echo "┌───────────────────────────────────────────────────┐"
      echo "│  GOAL.md needs your input!                        │"
      echo "│                                                   │"
      echo "│  What's the GOAL? What output do you need?        │"
      echo "│  Example: \"Build API docs for the auth module.\"  │"
      echo "└───────────────────────────────────────────────────┘"
      echo ""
      read -e -p "Enter your goal: " goal_input
      if [ -n "$goal_input" ]; then
        cat > GOAL.md << EOF
# Goal

> **For humans only.** The AI reads this but never modifies it.

$goal_input
EOF
        echo ""
        echo "Goal saved."
      fi
      echo ""
    else
      current_goal=$(head -n 20 GOAL.md | grep -v '^#\|^>\|^<\|^--' | tr '\n' ' ' | sed 's/^[[:space:]]*//' | cut -c1-60)
      echo "Goal: $current_goal..."
      echo ""
      read -p "Change goal? [y/N]: " edit_choice
      if [[ "$edit_choice" == "y" || "$edit_choice" == "Y" ]]; then
        read -e -p "Enter new goal: " goal_input
        if [ -n "$goal_input" ]; then
          cat > GOAL.md << EOF
# Goal

> **For humans only.** The AI reads this but never modifies it.

$goal_input
EOF
          echo "Goal updated."
        fi
        echo ""
      fi
    fi
  else
    echo "GOAL.md not found. Creating it..."
    echo ""
    read -e -p "Enter your goal: " goal_input
    if [ -n "$goal_input" ]; then
      cat > GOAL.md << EOF
# Goal

> **For humans only.** The AI reads this but never modifies it.

$goal_input
EOF
      echo "Goal saved."
    else
      cat > GOAL.md << 'EOF'
# Goal

> **For humans only.** The AI reads this but never modifies it.

EOF
    fi
    echo ""
  fi
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

reset_todo() {
  cat > .ralph/TODO.md << 'EOF'
# Ralph Agent Status

## Current Status

Idle - waiting for documents in refs/

## Processed Files

_None yet_

## Pending

_Check refs/ for new documents_
EOF
  echo "TODO reset."
}

reset_docs() {
  rm -rf docs/tutorials/* docs/how-to/* docs/explanation/* 2>/dev/null || true
  echo "docs/ cleared."
}

run_ralph() {
  echo ""
  read -p "Reset TODO? [y/N]: " reset_todo_choice
  if [[ "$reset_todo_choice" == "y" || "$reset_todo_choice" == "Y" ]]; then
    reset_todo
  fi
  read -p "Reset docs/? [y/N]: " reset_docs_choice
  if [[ "$reset_docs_choice" == "y" || "$reset_docs_choice" == "Y" ]]; then
    reset_docs
  fi
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
check_goal
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