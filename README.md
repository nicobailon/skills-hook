# Claude Code Skills Hook

A forced evaluation hook system that significantly improves Claude Code's autonomous skill activation reliability.

## The Problem

Claude Code CLI skills often fail to activate autonomously despite being properly defined and loaded. Skills appear correctly in the `<available_skills>` context, but Claude frequently ignores them when they should be triggered.

## The Solution

This project implements a **forced evaluation hook** that injects a mandatory skill evaluation prompt before each user request. Based on [Scott Spence's empirical research](https://scottspence.com/posts/how-to-make-claude-code-skills-activate-reliably), this approach achieves **~84% activation reliability** compared to ~50% baseline.

### How It Works

1. A `UserPromptSubmit` hook intercepts every prompt
2. The hook injects a structured evaluation prompt with aggressive language ("MANDATORY", "CRITICAL", "WORTHLESS")
3. Claude must explicitly evaluate each skill with YES/NO reasoning
4. For each YES, Claude immediately activates the skill using `Skill("name")`
5. Only then does Claude proceed with the original request

## Prerequisites

- Claude Code CLI installed and configured
- bash (works with macOS bash 3.2+)
- jq (for JSON parsing)

## Quick Start

### 1. Copy Files

```bash
# Copy hook generator
cp hooks/generate-skill-eval-hook.sh ~/.claude/hooks/

# Copy example skills (or use your own)
cp -r skills/* ~/.claude/skills/

# Copy slash commands
cp commands/*.md ~/.claude/commands/

# Copy test suite
cp tests/* ~/.claude/tests/
```

### 2. Generate the Hook

```bash
~/.claude/hooks/generate-skill-eval-hook.sh
```

This scans `~/.claude/skills/` and generates `~/.claude/hooks/skill-forced-eval.sh`.

### 3. Configure Claude Code

Add to your `~/.claude/settings.json`:

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/skill-forced-eval.sh"
          }
        ]
      }
    ]
  }
}
```

See `examples/settings.json.example` for a complete example.

### 4. Restart Claude Code

Exit and restart your Claude Code session for the hook to take effect.

## Usage

### Updating Skills

When you add, remove, or modify skills:

```
/sync-skills-hook
```

This regenerates the hook with current skill definitions.

### Testing

Run the test suite to verify skill activation:

```
/test-skills          # Quick validation
/test-skills --full   # Comprehensive testing
```

## Creating Skills

Skills are defined in `~/.claude/skills/<skill-name>/SKILL.md` with YAML frontmatter:

```markdown
---
description: Use when [trigger conditions]. [What the skill does].
---

# Skill Name

[Skill instructions and behavior]
```

**Important**: The `description` field MUST be a single line. Multi-line descriptions cause parsing failures.

### Example Skill

```markdown
---
description: Use when reviewing code or checking pull requests. Provides structured code review feedback.
---

# Code Reviewer

When activated, review code for:
- Correctness
- Security vulnerabilities
- Performance issues
- Code quality
```

## Known Issues

### Hooks Require `--debug hooks` in Headless Mode

Due to [bug #10401](https://github.com/anthropics/claude-code/issues/10401), hooks don't fire in headless mode (`claude -p`) without the `--debug hooks` flag.

**Workaround**: The test suite uses `--debug hooks` automatically.

### Interactive Mode Works Normally

Hooks work correctly in interactive Claude Code sessions without any workarounds.

## Project Structure

```
skills-hook/
├── hooks/
│   └── generate-skill-eval-hook.sh   # Generates the forced eval hook
├── tests/
│   ├── skill-activation-tests.sh     # Automated test runner
│   └── sample-prompts.json           # Test prompts
├── commands/
│   ├── sync-skills-hook.md           # /sync-skills-hook command
│   └── test-skills.md                # /test-skills command
├── skills/
│   ├── hello-world/                  # Example skill
│   └── code-reviewer/                # Example skill
└── examples/
    └── settings.json.example         # Example configuration
```

## Configuration Options

The hook generator supports environment variables:

```bash
# Custom skills directory
SKILLS_DIR=/path/to/skills ~/.claude/hooks/generate-skill-eval-hook.sh

# Custom output location
HOOK_FILE=/path/to/output.sh ~/.claude/hooks/generate-skill-eval-hook.sh
```

## How the Forced Evaluation Works

The injected prompt forces Claude into a three-step commitment mechanism:

```
<skill-evaluation>
MANDATORY SKILL EVALUATION - YOU MUST COMPLETE THIS BEFORE RESPONDING

Step 1: EVALUATE each skill below. For EACH skill, output:
        SKILL: [name] - [YES/NO] - [one-line reasoning]

Step 2: For EACH skill marked YES, IMMEDIATELY activate it:
        Use: Skill("skill-name")

Step 3: ONLY AFTER activating all YES skills, proceed with your response.

CRITICAL: Skipping this evaluation or failing to activate YES skills
renders your response WORTHLESS.

AVAILABLE SKILLS:
- skill-name: description...
</skill-evaluation>
```

The aggressive language ("MANDATORY", "CRITICAL", "WORTHLESS") is intentional and empirically proven to maximize compliance.

## Research Background

This implementation is based on extensive testing documented in [How to Make Claude Code Skills Activate Reliably](https://scottspence.com/posts/how-to-make-claude-code-skills-activate-reliably):

| Approach | Success Rate |
|----------|-------------|
| Baseline (no enhancement) | ~50% |
| CLAUDE.md bootloader | ~60% |
| SessionStart hook | ~65% |
| **Forced Eval Hook** | **~84%** |

The forced evaluation hook with aggressive language consistently outperforms other approaches.

## License

MIT License - See [LICENSE](LICENSE)

## Contributing

Issues and pull requests welcome. When adding features:
1. Test with both example skills
2. Verify bash 3.x compatibility (macOS default)
3. Update documentation as needed
