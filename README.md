# Diátaxis Documentation Framework

AI-assisted documentation organization using the [Diátaxis framework](https://diataxis.fr/).

## How It Works

```
┌─────────────────┐         ┌─────────────────┐
│     refs/       │   AI    │     docs/       │
│  (dump here)    │ ──────> │  (organized)    │
│                 │         │                 │
│ - raw docs      │         │ - tutorials/    │
│ - notes         │         │ - how-to/       │
│ - exports       │         │ - reference/    │
│ - any format    │         │ - explanation/  │
└─────────────────┘         └─────────────────┘
```

1. **Dump** raw documentation into `refs/`
2. **Ask AI** to analyze and categorize
3. **Review** proposed organization
4. **AI refines** content for each quadrant

## Directory Structure

```
diataxis/
├── refs/               # INPUT: Raw docs, any structure
├── docs/
│   ├── tutorials/      # Learning-oriented
│   ├── how-to/         # Task-oriented
│   ├── reference/      # Information-oriented
│   └── explanation/    # Understanding-oriented
├── .cursor/rules       # Agent rules (canonical)
└── .claude/rules       # Points to cursor rules
```

## The Four Quadrants

|  | Tutorials | How-to | Reference | Explanation |
|--|-----------|--------|-----------|-------------|
| **Oriented to** | Learning | Tasks | Information | Understanding |
| **Purpose** | Teach beginners | Solve problems | Describe facts | Explain context |
| **Form** | Lessons | Steps | Specs/tables | Discussion |
| **Analogy** | Cooking class | Recipe | Encyclopedia | Food history |

### Quick Classification

Ask yourself:
- Teaching a newcomer? → `tutorials/`
- Solving a specific problem? → `how-to/`
- Describing technical facts? → `reference/`
- Explaining why/context? → `explanation/`

## Usage

### Dump Your Docs

Put anything in `refs/`:
```bash
cp ~/my-project/docs/* refs/
cp ~/notes/architecture.md refs/
# PDFs, markdown, text - anything
```

### Ask AI to Process

```
"analyze refs"
```
AI scans `refs/`, reports contents, proposes categorization.

```
"process refs"
```
Full workflow: analyze → categorize → refine → organize.

```
"what's missing"
```
Identify gaps in documentation coverage.

### Review & Approve

AI will propose where each piece goes. Review before it moves/transforms content.

## Agent Rules

Both Cursor and Claude Code use the same ruleset:

- **Canonical rules**: `.cursor/rules`
- **Claude pointer**: `.claude/rules` (reads from cursor)

This ensures consistent behavior regardless of which AI assistant you use.

## Frontmatter

All refined docs include:

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

## Resources

- [Diátaxis Official Site](https://diataxis.fr/)
- [Diátaxis in 5 Minutes](https://diataxis.fr/start-here/)
