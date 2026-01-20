#!/usr/bin/env bash
while :; do
  cat .ralph/prompt.md | claude -p --dangerously-skip-permissions
done
