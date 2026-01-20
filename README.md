# Diátaxis Docs Engine

AI-powered documentation engine. Add source material, get organized output.

```
refs/  ──AI reads──>  docs/
(your reference,      ├── tutorials/
 never modified)      ├── how-to/
                      └── explanation/
```

## Quick Start

```bash
# 1. Add your source material (these stay forever, AI never touches them)
cp ~/my-project/docs/* refs/

# 2. Run the CLI (prompts you to set your goal)
./cli.sh
```

The CLI prompts you to edit `GOAL.md` first—tell the AI what output you need.

Select your tool:
| Option | Description |
|--------|-------------|
| `claude` | Interactive processing via Claude Code CLI |
| `cursor` | Opens Cursor IDE with command ready |
| `ralph` | Autonomous mode (runs until done) |

## Commands

| Command | What it does |
|---------|--------------|
| `analyze refs` | Scan and propose categorization |
| `process refs` | Full workflow: analyze → refine → organize |
| `categorize [file]` | Classify a specific file |
| `refine [file] as [type]` | Transform for target quadrant |
| `what's missing` | Identify documentation gaps |

## The Quadrants

| Location | Purpose | Form |
|----------|---------|------|
| `refs/` | Reference material | Specs/tables (your source, already there) |
| `docs/tutorials/` | Teach beginners | Lessons |
| `docs/how-to/` | Solve problems | Steps |
| `docs/explanation/` | Explain context | Discussion |

## Ralph Mode (Optional)

Autonomous processing via [Claude Code in a loop](https://ghuntley.com/ralph/).

```bash
# Via CLI
./cli.sh  # Select "ralph"

# Or directly
.ralph/ralph.sh
```

**Requires:** [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code)

**What it does:**
1. Reads GOAL.md and rules from `.cursor/rules/diataxis.mdc`
2. Reads source material from `refs/` (never modifies it)
3. Creates refined docs in `docs/`
4. Commits after processing
5. Stops when AI outputs `<promise>COMPLETE</promise>` (all refs/ processed)

**Warning:** Runs with `--dangerously-skip-permissions`. Review commits regularly.

---

## Reference

### Directory Structure

```
├── GOAL.md               # YOUR goal (AI reads, never modifies)
├── refs/                 # REFERENCE: your source material (AI reads, never modifies)
├── docs/                 # OUTPUT: AI creates here
│   ├── tutorials/        # Learning-oriented
│   ├── how-to/           # Task-oriented
│   └── explanation/      # Understanding-oriented
├── .ralph/               # Autonomous mode scripts
├── .cursor/rules/        # Agent rules (canonical)
└── .claude/rules         # Points to cursor rules
```

### GOAL.md

Tell the AI your **goal**—what output do you need?

```markdown
# Examples:
"Build API reference for our Python SDK. Focus on the auth module first."
"Create onboarding tutorials for new developers joining the team."
"Document the deployment pipeline so DevOps can hand off."
"Explain our architecture decisions for the upcoming audit."
```

The CLI prompts you to edit this on startup. The AI reads it but **never modifies it**.

### Document Frontmatter

All processed docs include:

```yaml
---
title: "Document Title"
type: tutorial | how-to | reference | explanation
status: draft | review | published
created: 2025-01-20
updated: 2025-01-20
source: refs/original-file.ext
tags: [relevant, tags]
---
```

### Agent Rules

Both Cursor and Claude Code share the same ruleset at `.cursor/rules/diataxis.mdc`.

## Resources

- [Diátaxis Framework](https://diataxis.fr/)
- [Ralph / Geoff Huntley](https://ghuntley.com/ralph/)
