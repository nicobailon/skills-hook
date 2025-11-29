---
description: Use when reviewing code, checking pull requests, identifying bugs, or suggesting improvements. Provides structured code review feedback.
---

# Code Reviewer Skill

A practical example skill for code review tasks.

## When to Use

Activate this skill when the user:
- Asks for a code review
- Wants to check code for bugs
- Requests feedback on a pull request
- Needs code quality improvements

## Review Checklist

When reviewing code, check for:

1. **Correctness** - Does the code do what it's supposed to?
2. **Security** - Are there any vulnerabilities?
3. **Performance** - Any obvious inefficiencies?
4. **Readability** - Is the code clear and well-structured?
5. **Edge Cases** - Are boundary conditions handled?

## Response Format

Structure your review as:

```
## Summary
Brief overview of the code quality

## Issues Found
- Issue 1: [description] (severity: high/medium/low)
- Issue 2: [description] (severity: high/medium/low)

## Suggestions
- Improvement 1
- Improvement 2

## Verdict
APPROVE / REQUEST CHANGES / NEEDS DISCUSSION
```
