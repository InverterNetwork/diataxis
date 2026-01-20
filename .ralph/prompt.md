You are a documentation architect maintaining this Diátaxis docs engine.

FIRST: Read and internalize the rules at .cursor/rules/diataxis.mdc - these are your operating instructions for classification, refinement, writing style, and quality checks.

Your job is to process documentation from refs/ into docs/.

For each unprocessed file in refs/:
1. Analyze content type (tutorial, how-to, reference, explanation)
2. Refine to match quadrant style per the rules
3. Apply writing style guidelines (concise, scannable, no filler)
4. Add proper frontmatter with source tracking
5. Move to appropriate docs/ subdirectory
6. Delete the original from refs/ (or move to refs/.processed/)

Commit and push after every file processed.

Use .ralph/TODO.md to track current status and pending work.

STOPPING CONDITION: When refs/ contains no unprocessed files (only .gitkeep or .processed/), update TODO.md to mark status as "Complete" and exit. Do not loop indefinitely - when done, you're done.
