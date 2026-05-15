# Conversion Guide — Other Platforms → Claude Code Skill

How to import a slash command, workflow, prompt, or Agent Skills `SKILL.md` from another tool and rewrite it as a Claude Code skill with full feature parity.

## Source format detection

Detect by path or frontmatter:

| Source | Detection signal |
|---|---|
| Agent Skills standard | Folder containing `SKILL.md` with `name` + `description` frontmatter (case-sensitive filename) |
| Cursor command | `.cursor/commands/<name>.md` or `~/.cursor/commands/<name>.md` |
| Cursor rule | `.cursor/rules/<name>.mdc` (note `.mdc` extension) with `alwaysApply` / `globs` frontmatter |
| Continue prompt | `.prompt` or `.md` with `invokable: true` in frontmatter |
| Windsurf skill | `.windsurf/skills/<name>/SKILL.md` (Agent Skills compliant) |
| Windsurf workflow | `.windsurf/workflows/<name>.md` (single file, manual `/slash-command` only) |

## Target

Always: `.claude/skills/<name>/SKILL.md` (project) or `~/.claude/skills/<name>/SKILL.md` (user).

If supporting files exist, port them: `<name>/scripts/`, `<name>/references/`, `<name>/assets/` → Claude Code accepts the same dirs.

## Field mapping

### Agent Skills standard → Claude Code

Agent Skills fields are a strict subset. Direct passthrough; Claude Code adds optional extensions.

| Agent Skills field | Claude Code | Notes |
|---|---|---|
| `name` | `name` | Same constraints (lowercase, hyphens, max 64) |
| `description` | `description` | Agent Skills caps at 1024 chars; Claude Code caps `description` + `when_to_use` combined at 1536 |
| `license` | (drop) | No equivalent. Add a `LICENSE` file in skill dir if needed. |
| `compatibility` | (preserve in body) | Move human-readable compatibility note into SKILL.md body under "## Requirements". |
| `metadata` | (drop or preserve in body) | Claude Code has no `metadata` field. Inline values into body if relevant. |
| `allowed-tools` (experimental) | `allowed-tools` | Same field name. Claude Code is stable; tighten patterns to scoped form `Bash(git add *)`. |

Claude Code extensions to add post-import:
- `disable-model-invocation: true` if skill has side effects
- `user-invocable: false` if it's reference-only knowledge
- `model` / `effort` if you want to override session
- `context: fork` + `agent:` if the skill should run isolated
- `hooks:` for deterministic enforcement (PreToolUse, PostToolUse, Stop)
- `paths:` for file-glob auto-loading
- `argument-hint`, `arguments` for typed args
- `shell: powershell` on Windows for `` !`<cmd>` `` blocks

### Cursor command → Claude Code skill

Cursor commands are plain markdown prompts in `.cursor/commands/<name>.md`. No required frontmatter.

| Cursor element | Claude Code | Notes |
|---|---|---|
| Filename `<name>.md` | `name: <name>` | Drop `.md`, kebab-case |
| First-line heading or implicit description | `description` | Synthesize a pushy description with trigger phrases |
| Body markdown | SKILL.md body | Direct copy |
| `@file` references | Keep as-is | Claude Code agent reads files; references work |
| Side-effect commands (`/commit`, `/deploy`) | Add `disable-model-invocation: true` | Cursor treats commands as user-invoked; preserve that |
| No tool restriction in source | Add `allowed-tools` allowlist | Infer from body actions |

Convert pattern:

```markdown
# Cursor: .cursor/commands/commit.md
Act as a senior software engineer to commit changes...
```

→

```markdown
---
name: commit
description: "Stage and commit current changes with Conventional Commits format. Use when user says 'commit this', 'fazer commit', '/commit'."
disable-model-invocation: true
allowed-tools: Bash(git status *) Bash(git diff *) Bash(git add *) Bash(git commit *)
---

# Commit
Act as a senior software engineer to commit changes...
```

### Cursor rule → Claude Code

Cursor rules are auto-applied context, not invokable commands. Two destinations depending on activation:

| Cursor rule frontmatter | Claude Code target | Reason |
|---|---|---|
| `alwaysApply: true` | `CLAUDE.md` (project) or `~/.claude/CLAUDE.md` (global) | Always-loaded context belongs in CLAUDE.md, not a skill |
| `globs: [...]` | Skill with `paths: [...]` | Path-scoped auto-load equivalent |
| `description` only (model decides) | Reference skill (auto-trigger via description match) | `user-invocable: false` to prevent menu clutter |
| `manual` mode | Reference skill (default invocation) | User pulls when needed |

`.mdc` extension: Cursor's custom format. Body content is plain markdown; just rename to `.md` after porting (or to `SKILL.md`).

### Continue prompt → Claude Code skill

Continue prompts with `invokable: true` are equivalent to user-invocable Claude Code skills.

| Continue field | Claude Code | Notes |
|---|---|---|
| `name` | `name` | Same |
| `description` | `description` | Add pushy triggers + PT-BR variants |
| `invokable: true` | (default) | Both default to user+model invocable |
| `model` / model selection | `model` | Direct map |
| Body | SKILL.md body | Direct copy |
| `uses: org/prompt-name` (Continue Hub) | Inline content | Resolve and inline; Claude Code has no equivalent registry |
| Old `config.ts` `slashCommands` array | Single SKILL.md per command | Programmatic Continue commands → static Claude skills |

### Windsurf workflow → Claude Code skill

Windsurf workflows are manual-only (`/slash-command`).

| Windsurf workflow | Claude Code | Notes |
|---|---|---|
| `.windsurf/workflows/<name>.md` | `.claude/skills/<name>/SKILL.md` | Folder up one level |
| Manual-only invocation | `disable-model-invocation: true` | Preserve manual semantics |
| Title + description | `description` | Pushy rewrite |
| Numbered steps | SKILL.md body | Direct copy |

### Windsurf skill → Claude Code skill

Windsurf adopts Agent Skills standard verbatim. Direct copy. Add Claude Code extensions per "Agent Skills standard" mapping above.

## Body transformations to apply

After field mapping, normalize the body:

1. **Strengthen description with bilingual triggers.** Most source platforms have weak descriptions. Rewrite with: "Use proactively when X. Trigger phrases including PT-BR variants 'criar Y', 'novo Z'."
2. **Add `<example>` blocks** if missing — even one or two improves auto-trigger matching.
3. **Convert dynamic context.** Replace `@file.md` references (Cursor) with Claude Code `` !`<cmd>` `` injection where it makes sense (e.g., `@log.md` → `` !`cat log.md` ``).
4. **Add confirmation gate** if body has destructive ops without one (port from Claude Code anti-pattern checklist).
5. **Tighten `allowed-tools`** if missing or too broad. Use scoped patterns: `Bash(git add *)` not `Bash(*)`.
6. **Move long reference content** into `references/<name>.md` if SKILL.md exceeds ~300 lines.
7. **Translate technical-term-only PT-BR to EN** in frontmatter (`commit` not `envio`, `hook` not `gancho`). Keep PT-BR triggers verbatim inside an EN description.

## Side-by-side example: Cursor → Claude Code

Source — `.cursor/commands/code-review.md`:

```markdown
# Code Review

Review the current branch's diff for bugs, security issues, and code smells. Use @CONTRIBUTING.md as the style reference.

## Steps
1. Run git diff main...HEAD
2. Read each changed file
3. Report findings grouped by severity
```

Target — `.claude/skills/code-review/SKILL.md`:

```markdown
---
name: code-review
description: "Review current branch's diff for bugs, security issues, and code smells. Use proactively after the user finishes a code change. Trigger phrases including PT-BR: 'review my code', 'revisar codigo', 'code review', 'revisão de código'."
disable-model-invocation: true
allowed-tools: Bash(git diff *) Bash(git log *) Read Grep Glob
---

# Code Review

Review the current branch's diff for bugs, security issues, and code smells.

## Style reference
```!
cat CONTRIBUTING.md
```

## Steps
1. Run `git diff main...HEAD`
2. Read each changed file
3. Report findings grouped by severity: CRITICAL / WARNING / SUGGESTION
4. End with verdict: SHIP / FIX-FIRST / BLOCK
```

Changes applied:
- Synthesized pushy `description` with EN + PT-BR triggers
- Added `disable-model-invocation: true` (manual review, not auto)
- Tightened `allowed-tools` to scoped patterns
- Replaced `@CONTRIBUTING.md` reference with `` !`cat ...` `` dynamic injection
- Added severity buckets and verdict (Claude Code convention)

## Side-by-side example: Agent Skills → Claude Code

Source — `<some-skill>/SKILL.md`:

```markdown
---
name: pdf-extract
description: Extract text and tables from PDFs.
license: MIT
compatibility: Requires pdfplumber installed.
metadata:
  author: Jane Doe
  version: 1.2
---

# PDF Extract
Use pdfplumber to extract...
```

Target — `.claude/skills/pdf-extract/SKILL.md`:

```markdown
---
name: pdf-extract
description: "Extract text and tables from PDF files. Use when user mentions PDFs, forms, document extraction, or says 'extrair PDF', 'ler PDF', 'parse PDF'."
allowed-tools: Bash(python3 *) Read Write
---

# PDF Extract

Requires `pdfplumber` (pip install pdfplumber).

Use pdfplumber to extract...
```

Plus a `LICENSE` file in the skill folder for the MIT license.

Changes applied:
- Strengthened description with EN + PT-BR triggers
- Dropped `license` field, added a `LICENSE` file instead
- Inlined `compatibility` note as "Requires" line in body
- Dropped `metadata` (no Claude equivalent; record in body or git history)
- Added scoped `allowed-tools` for pdfplumber execution

## Caveats

- **Dynamic prompt logic** in Continue's `config.ts` `run: async function(sdk)` cannot be ported as-is. Claude Code skills are static markdown — rewrite procedural logic as `` !`<cmd>` `` injection or as a bundled script under `scripts/`.
- **Cursor `@file` references** load the file's content into the prompt. Claude Code equivalent is `` !`cat <file>` `` for explicit injection, OR mention the path and let Claude `Read` it on demand. The latter is cheaper if the file isn't always needed.
- **Cursor rules with `globs:`** map cleanly to Claude Code `paths:`, but the rule's "auto-applied context" model differs slightly: Claude Code skills with `paths:` get auto-loaded into the listing, but Claude still decides whether to invoke. For "always on for these files" behavior, put the content in a file-scoped CLAUDE.md instead.
- **Plugin / managed-settings** sources from Claude Code are read-only at conversion time — copy the file out to a project- or user-scoped skill dir before editing.
