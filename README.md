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
# 1. Add your source material (never modified by AI)
cp ~/my-project/docs/* refs/

# 2. Run the CLI
./cli.sh
```

The CLI prompts you to set your goal, then select a service:

| Option | Description |
|--------|-------------|
| `claude` | Interactive processing via Claude Code CLI |
| `ralph` | Autonomous mode (cralph loop) |
| `cursor` | Opens Cursor IDE with command ready |

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

## Ralph Mode

Autonomous processing via [cralph](https://github.com/mguleryuz/cralph) (Claude in a loop).

```bash
# Via CLI
./cli.sh  # Select "ralph"

# Or directly
cralph
```

**Requires:** [Bun](https://bun.sh) + [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code)

```bash
bun add -g cralph
```

**What it does:**
1. Reads `GOAL.md` and rules from `.ralph/rule.md`
2. Reads source material from `refs/` (never modifies it)
3. Creates refined docs in `docs/`
4. Updates `.ralph/TODO.md` with progress
5. Stops when AI outputs `<promise>COMPLETE</promise>`

**Warning:** Runs with `--dangerously-skip-permissions`. Review output regularly.

---

## Reference

### Directory Structure

```
├── cli.sh                # Interactive launcher
├── GOAL.md               # YOUR goal (AI reads, never modifies)
├── refs/                 # REFERENCE: your source material (AI reads, never modifies)
├── docs/                 # OUTPUT: AI creates here
│   ├── tutorials/        # Learning-oriented
│   ├── how-to/           # Task-oriented
│   └── explanation/      # Understanding-oriented
├── .ralph/               # cralph config
│   ├── paths.json        # References, rule, output paths
│   ├── rule.md           # Agent instructions
│   └── TODO.md           # Task tracking (updated by AI)
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

Edit this before running. The AI reads it but **never modifies it**.

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

- **Cursor/Claude:** `.cursor/rules/diataxis.mdc` (full framework rules)
- **cralph:** `.ralph/rule.md` (loop-specific instructions)

## Resources

- [Diátaxis Framework](https://diataxis.fr/)
- [cralph](https://github.com/mguleryuz/cralph) - Claude in a loop CLI
- [Ralph / Geoff Huntley](https://ghuntley.com/ralph/) - The technique
