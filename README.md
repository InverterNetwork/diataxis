# Diátaxis Documentation Framework

A structured approach to organizing protocol documentation using the [Diátaxis framework](https://diataxis.fr/).

## Why Diátaxis?

Documentation fails when it mixes different types of content. Diátaxis solves this by recognizing four distinct documentation needs:

```
                     PRACTICAL
                        │
         Tutorials      │      How-to Guides
         (Learning)     │      (Goals)
                        │
   STUDY ───────────────┼─────────────── WORK
                        │
         Explanation    │      Reference
         (Understanding)│      (Information)
                        │
                   THEORETICAL
```

## Directory Structure

```
diataxis/
├── docs/
│   ├── tutorials/      # Learning-oriented lessons
│   ├── how-to/         # Task-oriented guides
│   ├── reference/      # Technical descriptions
│   └── explanation/    # Conceptual discussions
├── scripts/
│   └── analyze-docs.sh # Documentation analysis pipeline
├── .cursor/
│   └── rules           # AI assistant rules for docs
└── README.md
```

## The Four Quadrants

### 1. Tutorials (`docs/tutorials/`)

**Purpose**: Teach newcomers through hands-on lessons

| Do | Don't |
|----|-------|
| Guide step-by-step | Assume prior knowledge |
| Ensure success | Overwhelm with options |
| Use concrete examples | Explain everything |
| Keep them moving | Let them get stuck |

**Example topics**:
- Getting started with the protocol
- Your first module deployment
- Building a simple integration

### 2. How-to Guides (`docs/how-to/`)

**Purpose**: Help users accomplish specific tasks

| Do | Don't |
|----|-------|
| Focus on the goal | Teach concepts |
| Assume competence | Over-explain basics |
| Be practical | Be theoretical |
| Show the solution | Explore alternatives |

**Example topics**:
- How to integrate the SDK
- How to deploy to mainnet
- How to handle errors

### 3. Reference (`docs/reference/`)

**Purpose**: Provide accurate technical information

| Do | Don't |
|----|-------|
| Be accurate and complete | Include tutorials |
| Structure for lookup | Add opinions |
| Match code structure | Explain "why" |
| Stay consistent | Mix with how-tos |

**Example topics**:
- SDK API reference
- Smart contract ABIs
- GraphQL schema
- Configuration options

### 4. Explanation (`docs/explanation/`)

**Purpose**: Provide context and understanding

| Do | Don't |
|----|-------|
| Explain "why" | Give instructions |
| Provide context | List facts |
| Discuss trade-offs | Be purely technical |
| Connect concepts | Be a reference |

**Example topics**:
- Architecture decisions
- Design philosophy
- How the module system works
- Security model

## Document Template

Every document requires frontmatter:

```yaml
---
title: "Your Document Title"
type: tutorial | how-to | reference | explanation
status: draft | review | published
created: 2025-01-20
updated: 2025-01-20
author: Your Name | AI
tags: [relevant, tags]
---

# Your Document Title

Content goes here...
```

## Analysis Pipeline

Run the analysis script to check documentation health:

```bash
chmod +x scripts/analyze-docs.sh
./scripts/analyze-docs.sh
```

This will:
- Count documents per quadrant
- Check for missing frontmatter
- Identify AI-generated content needing review
- Flag coverage gaps
- Generate `docs-analysis-report.md`

## Workflow for Analyzing Existing Docs

### Step 1: Import existing documentation
```bash
# Copy existing docs to a staging area
cp -r /path/to/existing/docs docs/_import/
```

### Step 2: Categorize each document
For each document, ask:
- Is it teaching a newcomer? → `tutorials/`
- Is it solving a specific problem? → `how-to/`
- Is it describing technical facts? → `reference/`
- Is it explaining concepts/rationale? → `explanation/`

### Step 3: Add frontmatter
Add required metadata to each document.

### Step 4: Run analysis
```bash
./scripts/analyze-docs.sh
```

### Step 5: Address gaps
Review the report and create missing documentation.

## AI-Generated Documentation

This repo supports mixed AI and human-generated content:

1. **Mark AI content**: Use `author: AI` in frontmatter
2. **Review required**: AI docs must be reviewed before `status: published`
3. **Focus review on**:
   - Technical accuracy
   - The "why" (AI often misses rationale)
   - Edge cases
   - Business context

## Quick Reference

| Question | Quadrant |
|----------|----------|
| "How do I learn this?" | Tutorial |
| "How do I do X?" | How-to |
| "What is X exactly?" | Reference |
| "Why does X work this way?" | Explanation |

## Resources

- [Diátaxis Official Site](https://diataxis.fr/)
- [Diátaxis in 5 Minutes](https://diataxis.fr/start-here/)
- [Docs as Code](https://www.writethedocs.org/guide/docs-as-code/)
