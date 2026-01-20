# Diátaxis Docs Engine

AI-powered documentation engine. Dump raw docs, get organized output.

```
refs/  ──AI──>  docs/
(dump)          ├── tutorials/
                ├── how-to/
                ├── reference/
                └── explanation/
```

## Quick Start

```bash
# 1. Dump your docs
cp ~/my-project/docs/* refs/

# 2. Run the CLI
./cli.sh
```

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

## The Four Quadrants

| Quadrant | Purpose | Form | Ask yourself |
|----------|---------|------|--------------|
| `tutorials/` | Teach beginners | Lessons | Teaching a newcomer? |
| `how-to/` | Solve problems | Steps | Solving a specific task? |
| `reference/` | Describe facts | Specs/tables | Documenting technical details? |
| `explanation/` | Explain context | Discussion | Explaining why/background? |

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
1. Reads rules from `.cursor/rules/diataxis.mdc`
2. Processes each file in `refs/`
3. Commits after each file
4. Stops when `refs/` is empty

**Warning:** Runs with `--dangerously-skip-permissions`. Review commits regularly.

---

## Reference

### Directory Structure

```
├── refs/                 # INPUT: dump raw docs here
├── docs/
│   ├── tutorials/        # Learning-oriented
│   ├── how-to/           # Task-oriented
│   ├── reference/        # Information-oriented
│   └── explanation/      # Understanding-oriented
├── .ralph/               # Autonomous mode scripts
├── .cursor/rules/        # Agent rules (canonical)
└── .claude/rules         # Points to cursor rules
```

### Document Frontmatter

All processed docs include:

```yaml
---
title: "Document Title"
type: tutorial | how-to | reference | explanation
status: draft | review | published
created: 2025-01-20
updated: 2025-01-20
source: refs/original-file.md
tags: [relevant, tags]
---
```

### Agent Rules

Both Cursor and Claude Code share the same ruleset at `.cursor/rules/diataxis.mdc`.

## Resources

- [Diátaxis Framework](https://diataxis.fr/)
- [Ralph / Geoff Huntley](https://ghuntley.com/ralph/)
