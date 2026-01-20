#!/usr/bin/env bash
set -e

LOG_FILE=".ralph/ralph.log"
TODO_FILE=".ralph/TODO.md"

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
  # Kill any background jobs
  jobs -p | xargs -r kill 2>/dev/null || true
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
  BEFORE_COUNT=$(count_refs)
  
  if [ "$BEFORE_COUNT" -eq 0 ]; then
    echo ""
    log "${GREEN}✓ Complete!${NC} All files processed in $ITERATION iterations."
    exit 0
  fi
  
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  log "Iteration $ITERATION — ${YELLOW}$BEFORE_COUNT${NC} files remaining"
  
  # Start background watcher to show file processing progress
  (
    LAST_COUNT=$BEFORE_COUNT
    while true; do
      sleep 5
      CURRENT=$(count_refs 2>/dev/null) || break
      if [ "$CURRENT" -lt "$LAST_COUNT" ]; then
        DIFF=$((LAST_COUNT - CURRENT))
        echo -e "  ${GREEN}→${NC} $DIFF file(s) moved ($CURRENT remaining)"
        echo "[$(date '+%H:%M:%S')] Progress: $DIFF file(s) moved ($CURRENT remaining)" >> "$LOG_FILE"
        LAST_COUNT=$CURRENT
      fi
      [ "$CURRENT" -eq 0 ] && break
    done
  ) &
  WATCHER_PID=$!
  
  log "Invoking claude..."
  
  # Run claude and capture output
  # Use a temp file to capture output, tee to log in real-time
  set +e
  cat .ralph/prompt.md | claude -p --dangerously-skip-permissions 2>&1 | tee -a "$LOG_FILE"
  EXIT_CODE=${PIPESTATUS[1]}
  set -e
  
  # Kill watcher
  kill $WATCHER_PID 2>/dev/null || true
  wait $WATCHER_PID 2>/dev/null || true
  
  # Results
  AFTER_COUNT=$(count_refs)
  PROCESSED=$((BEFORE_COUNT - AFTER_COUNT))
  
  echo ""
  if [ "$EXIT_CODE" -eq 0 ]; then
    log "Iteration $ITERATION complete — ${GREEN}$PROCESSED${NC} file(s) processed"
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
