#!/usr/bin/env bash
set -e

# Trap Ctrl+C and clean up
trap 'echo ""; echo "Ralph stopped."; exit 0' INT TERM

echo "Ralph starting..."
echo "Logs: .ralph/ralph.log"
echo "Press Ctrl+C to stop"
echo "─────────────────────────────────────────"

while :; do
  echo ""
  echo "[$(date '+%H:%M:%S')] Processing iteration..."
  
  # Run claude and show output (also log to file)
  cat .ralph/prompt.md | claude -p --dangerously-skip-permissions 2>&1 | tee -a .ralph/ralph.log
  
  EXIT_CODE=${PIPESTATUS[1]}
  
  echo "[$(date '+%H:%M:%S')] Iteration complete (exit: $EXIT_CODE)"
  
  # If claude exits cleanly and refs is empty, we're done
  if [ -z "$(ls -A refs/ 2>/dev/null | grep -v '.gitkeep' | grep -v '.processed')" ]; then
    echo "[$(date '+%H:%M:%S')] refs/ is empty. Ralph complete."
    exit 0
  fi
  
  sleep 2
done
