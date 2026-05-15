---
name: cc-audit
description: "Audit Claude Code artifacts (skills, agents, hooks, slash commands, settings.json) against Anthropic's canonical documentation and the project's language strategy. Detects frontmatter issues, body language drift, weak or unpushy descriptions, anti-patterns, broad tool scopes, contradictions, and inconsistencies inside `.claude/`. Use proactively when the user wants to review or audit their Claude Code config, validate a skill/agent/hook before committing, check conformance with the official docs, fingerprint setup quality, or compare an artifact against best practices — including PT-BR phrasings like 'audita minhas skills', 'verifica meus hooks', 'meu agent tá conforme', 'revisar .claude', 'auditar config do claude code', 'analisar essa skill', 'isso aqui está correto?', 'review my .claude folder' — even if they don't explicitly ask for an audit. Writes versioned report under ./cc-audits/ at workspace root with findings ranked by severity and cites the reference + section that justifies each finding."
argument-hint: "<path-or-artifact>"
arguments: [target]
model: opus
allowed-tools: Read Glob Grep Write Bash(date +*) Bash(find . *) Bash(wc -l *) Bash(mkdir *) AskUserQuestion
---

# CC Audit

Audits artifacts inside `.claude/` against Anthropic's canonical Claude Code docs and the EN/PT-BR language strategy. For each artifact: classify type → load the relevant reference → emit findings ranked by severity, each citing the reference section that justifies it.

## Inputs

- `$0` — `target`: path to a single artifact file, a `.claude/` subdirectory, or `.claude/` itself.

If missing, abort: `target required. Usage: /cc-audit <path>`.

## Dynamic context

```!
date +%Y-%m-%d
```

## Steps

### 1. Validate and resolve output filename

- Validate `$0` exists. Abort if not.
- **Derive slug from `$0`:**
  - Strip trailing slash and `SKILL.md` if present.
  - Take the basename. If the basename is empty or starts with `.`, fall back to the parent dir name.
  - Lowercase, replace non-alphanumerics with `-`, collapse repeats. Examples:
    - `.claude/skills/target-version-profile` → `target-version-profile`
    - `.claude/skills/stack-profile/SKILL.md` → `stack-profile`
    - `.claude/skills` → `skills`
    - `.claude` → `claude`
- **Ensure output dir:** `Bash(mkdir -p ./cc-audits)`.
- **Compute version `N`:** Glob `./cc-audits/cc-audit-report-<slug>-v*.md`. Parse the numeric suffix from each match, take the max, set `N = max + 1`. If no match, `N = 1`.
- **Output filename:** `./cc-audits/cc-audit-report-<slug>-v<N>.md`. Never overwrites — every run produces a new versioned file.

### 2. Discover artifacts

Resolve `$0` into a list of artifacts to audit. Classification rules:

| Path pattern | Type | Primary reference |
|---|---|---|
| `<dir>/SKILL.md` | skill | `references/claude-code-skills-doc.md` |
| `.claude/agents/<name>.md` | agent | `references/claude-code-customagents-doc.md` |
| `.claude/commands/<name>.md` | legacy command | `references/claude-code-skills-doc.md` + `references/conversion-guide.md` |
| `.claude/settings.json` `hooks` key | hooks config | `references/claude-code-hooks.md` |
| Frontmatter `hooks:` inside a SKILL.md or agent | skill-scoped hooks | `references/claude-code-hooks.md` |

If `$0` is a directory: Glob recursively for all of the above. If a single file: classify and proceed.

### 3. Audit each artifact

For every artifact, load the primary reference plus `references/claude-code-language-strategy.md` (always), `references/project-conventions.md` (always), and `references/skill-description-ptbr-triggers.md` (for skills/agents with descriptions). Apply the dimensions below.

**Universal dimensions**

- **Frontmatter validity** — required fields present, allowed values, no invented fields. Cite reference section for each rule.
- **Language strategy** — body in EN; identifiers/comments EN; technical terms (auth, middleware, hook, subagent, skill) untranslated even inside PT-BR prose. Exception only if the artifact is explicitly user-facing (e.g., a template).
- **Anti-patterns** — full PT-BR description or body, translated technical terms, broad `Bash(*)` patterns, redundant rules duplicated between body and Critical Rules, padded backstory, decorative emojis or icons in any authored content (cite `project-conventions.md` §"No emojis or decorative icons"; external/quoted content excepted).
- **Tool scoping** — `allowed-tools` narrowed to actual usage; no unjustified wildcards.
- **Internal consistency** — referenced supporting files exist (Glob to verify); links resolve; `name` matches directory name.

**Type-specific dimensions**

| Type | Extra checks |
|---|---|
| skill | Description follows pushy pattern (EN + PT-BR triggers + `"even if they don't explicitly ask..."` closer); `description + when_to_use` ≤ 1536 chars; body < 500 lines; `disable-model-invocation: true` does not coexist with heavy auto-invoke triggers (contradiction); `context: fork` paired with `agent:`; `arguments` declared if body uses `$N`/`$name`. |
| agent | Name/description/tools/system prompt all EN; pushy description; no over-delegation patterns; system prompt concise. |
| hook | Handler `type` (`command`/`http`/`prompt`/`agent`) matches language rule (prompt/agent → EN); event + matcher valid per docs; exit codes documented for `command` hooks; no shell hooks bypassing safety (e.g., `--no-verify` without justification). |
| legacy command | Flag opportunity to migrate to a skill (`.claude/commands/<n>.md` → `.claude/skills/<n>/SKILL.md`) with conversion-guide field mapping. |

### 4. Rank findings

Each finding gets a severity:

- **Critical** — violates an explicit rule from the canonical docs or the language strategy. Will misfire, under-trigger, or break.
- **Warning** — best-practice deviation. Works but suboptimal (token waste, weak triggers, redundant prose).
- **Suggestion** — polish (naming, structure, missing examples folder).

Every finding cites: `<reference-file>.md` + section/anchor that justifies it, and the exact line(s) or field(s) in the artifact.

### 5. Write report

Write to the versioned filename computed in Step 1 (`./cc-audits/cc-audit-report-<slug>-v<N>.md`). Structure:

```
# CC Audit — <date>

## Summary
- Artifacts audited: <n>
- Critical: <n>  Warning: <n>  Suggestion: <n>

## <artifact path>
**Type:** <skill|agent|hook|command>

### Critical
- **<short title>** — <description>. Cite: `<reference>.md` §<section>. Location: <file>:<line> or field.

### Warning
- ...

### Suggestion
- ...

## Prioritized action list
1. ...
2. ...
```

Omit empty severity buckets. Adapt structure as the audit demands — this is a guide, not rigid.

### 6. Report to chat

Print: total artifacts audited, count per severity, the top 3 critical findings with one-line summaries, and the versioned report path (`./cc-audits/cc-audit-report-<slug>-v<N>.md`).

## Critical Rules

- **Every finding cites a reference + section.** No bare assertions — without a citation it does not appear.
- **No false positives from missing context.** If a rule has a documented exception (e.g., user-facing template can be PT-BR), check the exception before flagging.
- **No invention.** A rule that is not in the references is not a finding. Skill-author opinions belong elsewhere.
- **Severity is rule-driven, not vibes.** Critical = explicit doc rule violated. Demote to Warning if the violation is best-practice only.
- **Workspace boundaries.** Never edit the artifacts being audited. Output goes only to `./cc-audits/cc-audit-report-<slug>-v<N>.md` (workspace root). Never modify files inside `references/`.
- **No cross-artifact prescription.** Report findings per artifact. Refactor recommendations are suggestions, not edits.
- **Body language: EN.** This skill follows the canon it audits.

## Supporting files

- [references/claude-code-skills-doc.md](references/claude-code-skills-doc.md) — official Claude Code Skills documentation. Source-of-truth for skill frontmatter, content lifecycle, hooks integration, invocation control.
- [references/claude-code-customagents-doc.md](references/claude-code-customagents-doc.md) — official Custom Agents documentation. Source-of-truth for agent frontmatter and system-prompt conventions.
- [references/claude-code-hooks.md](references/claude-code-hooks.md) — official Hooks documentation. Source-of-truth for events, matchers, handler types, exit-code semantics.
- [references/claude-code-language-strategy.md](references/claude-code-language-strategy.md) — EN/PT-BR language strategy. Applies to every artifact audited.
- [references/skill-description-ptbr-triggers.md](references/skill-description-ptbr-triggers.md) — pushy description pattern with bilingual triggers. Applies to skills and agents.
- [references/conversion-guide.md](references/conversion-guide.md) — field mapping for migrating legacy `.claude/commands/` files into skills, plus imports from other tools.
- [references/project-conventions.md](references/project-conventions.md) — project-local conventions that extend the Anthropic canon (currently: no emojis/icons in authored artifacts).
