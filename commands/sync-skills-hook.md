---
description: Sync skills to forced-eval hook (regenerate from current skill definitions)
allowed-tools:
  - Bash
---

# Sync Skills to Hook

Regenerating the forced-eval hook from current skill definitions...

!bash ~/.claude/hooks/generate-skill-eval-hook.sh

This syncs:
- Scans all skills in ~/.claude/skills/
- Validates YAML frontmatter (single-line descriptions required)
- Regenerates ~/.claude/hooks/skill-forced-eval.sh

Run after adding, removing, or updating skill descriptions.
