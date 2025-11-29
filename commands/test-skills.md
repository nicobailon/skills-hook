---
description: Run skill activation test suite (minimal or full)
allowed-tools:
  - Bash
argument-hint: "[--full]"
---

# Skill Activation Test Suite

This command runs the automated skill activation test suite to validate that the forced eval hook is working correctly.

Run the test suite:
```bash
~/.claude/tests/skill-activation-tests.sh $ARGUMENTS
```

**Usage:**
- `/test-skills` - Run minimal suite (~2-3 min)
- `/test-skills --full` - Run full suite (~15 min)

The test suite validates that:
1. Skills activate autonomously when requests match their triggers
2. Multi-skill scenarios activate complementary skills
3. Negative tests do NOT incorrectly activate skills

Target: >= 80% activation rate
