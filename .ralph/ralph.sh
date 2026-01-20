#!/usr/bin/env bash
set -e

LOG_FILE=".ralph/ralph.log"
TODO_FILE=".ralph/TODO.md"
TEMP_OUTPUT=$(mktemp)

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
DIM='\033[2m'
NC='\033[0m'

log() {
  local timestamp=$(date '+%H:%M:%S')
  echo -e "${DIM}[$timestamp]${NC} $1"
  echo "[$timestamp] $(echo -e "$1" | sed 's/\x1b\[[0-9;]*m//g')" >> "$LOG_FILE"
}

count_refs() {
  ls -A refs/ 2>/dev/null | grep -v '.gitkeep' | grep -v '.processed' | wc -l | tr -d ' '
}

list_refs() {
  ls -A refs/ 2>/dev/null | grep -v '.gitkeep' | grep -v '.processed' || true
}

cleanup() {
  echo ""
  log "Stopped by user."
  rm -f "$TEMP_OUTPUT" 2>/dev/null || true
  exit 0
}
trap cleanup INT TERM

# Initialize log
{
  echo "═══════════════════════════════════════"
  echo "Ralph Session: $(date '+%Y-%m-%d %H:%M:%S')"
  echo "═══════════════════════════════════════"
} > "$LOG_FILE"

echo -e "${GREEN}Ralph starting...${NC}"
echo -e "Log: ${DIM}$LOG_FILE${NC} | TODO: ${DIM}$TODO_FILE${NC}"
echo "Press Ctrl+C to stop"
echo ""

# Initial state
INITIAL_COUNT=$(count_refs)
log "Found ${YELLOW}$INITIAL_COUNT${NC} files to process"
list_refs | while read -r file; do
  echo -e "  ${DIM}•${NC} $file"
done
echo ""

ITERATION=0

while :; do
  ITERATION=$((ITERATION + 1))
  REF_COUNT=$(count_refs)
  
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  log "Iteration $ITERATION — ${YELLOW}$REF_COUNT${NC} ref files"
  
  log "Invoking claude..."
  
  # Run claude and capture output to temp file + log
  set +e
  cat .ralph/prompt.md | claude -p --dangerously-skip-permissions 2>&1 | tee "$TEMP_OUTPUT" | tee -a "$LOG_FILE"
  EXIT_CODE=${PIPESTATUS[1]}
  set -e
  
  echo ""
  
  # Check for completion signal
  if grep -q "<promise>COMPLETE</promise>" "$TEMP_OUTPUT"; then
    log "${GREEN}✓ Complete!${NC} All files processed in $ITERATION iteration(s)."
    rm -f "$TEMP_OUTPUT"
    exit 0
  fi
  
  if [ "$EXIT_CODE" -eq 0 ]; then
    log "Iteration $ITERATION complete"
  else
    log "${RED}⚠${NC} Iteration $ITERATION exited with code $EXIT_CODE"
  fi
  
  # Show latest git commit
  if git rev-parse --git-dir > /dev/null 2>&1; then
    LAST_COMMIT=$(git log -1 --oneline 2>/dev/null || echo "none")
    log "Last commit: ${DIM}$LAST_COMMIT${NC}"
  fi
  
  echo ""
  sleep 2
done
