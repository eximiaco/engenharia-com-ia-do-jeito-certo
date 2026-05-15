---
name: commit
description: "Stage and commit current changes with a Conventional Commits message. Use when the user says 'commit this', 'salvar commit', 'fazer commit', '/commit'. Manual invocation only — never auto-commit."
argument-hint: "[optional commit message]"
disable-model-invocation: true
allowed-tools: Bash(git status *) Bash(git diff *) Bash(git add *) Bash(git commit *)
---

# Commit

Stage and commit the current working tree changes. User-invocable only — Claude must not auto-trigger this.

## Live context

```!
git status --short
git diff --stat
```

## Steps

1. If `$ARGUMENTS` is non-empty, treat it as the commit subject. Otherwise read the diff above and draft a Conventional Commits message:
   - `feat:` new feature
   - `fix:` bug fix
   - `chore:` tooling/config
   - `docs:` documentation
   - `refactor:` no behavior change
2. Subject ≤ 50 chars. Body only when "why" isn't obvious from the diff.
3. Show the proposed message to user. STOP.
4. Wait for explicit confirmation in chat ("yes" / "sim" / "ok" / "confirma"). On any other response, abort and let the user edit.
5. Stage and commit:
   - `git add -A`
   - `git commit -m "<subject>"` (or HEREDOC for multi-line body)
6. Run `git status` to confirm and report the new HEAD.

## Critical Rules

- NEVER commit without explicit chat confirmation.
- NEVER push. Push is a separate user action.
- NEVER skip pre-commit hooks (no `--no-verify`).
- If pre-commit hook fails, do NOT amend — fix the issue, re-stage, create a new commit.
- Commit message stays in English (Conventional Commits convention).
- Do not stage files that look like secrets (`.env`, `credentials.json`, `*.pem`). Warn user instead.
