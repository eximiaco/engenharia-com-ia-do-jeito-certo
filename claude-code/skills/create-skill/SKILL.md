---
name: create-skill
description: "Scaffold a new skill at .claude/skills/<name>/SKILL.md with best-practice frontmatter and structure, OR import and convert an existing slash command / workflow / Agent Skills SKILL.md from Cursor, Continue, Windsurf, OpenAI Codex, GitHub Copilot, Gemini CLI, Roo, Goose, Trae, Amp, or any Agent Skills standard source into a fully-featured Claude Code skill. Use proactively whenever the user asks to create, build, scaffold, design, import, port, or convert a skill, slash command, agent workflow, or reusable prompt — including PT-BR phrasings like 'criar uma skill', 'nova skill', 'fazer um slash command', 'comando customizado', 'skill para X', 'importar skill do Cursor', 'converter workflow do Windsurf', 'portar prompt do Continue'. Enforces concise body, English infrastructure (per Anthropic canon), pushy descriptions with bilingual triggers, correct invocation control (disable-model-invocation, user-invocable), Claude Code extensions (hooks, context: fork, allowed-tools, paths, model), and decides when supporting files apply."
allowed-tools: Read, Write, Glob, Grep, AskUserQuestion
disable-model-invocation: true
---

# Create Skill

Scaffolds `.claude/skills/<name>/SKILL.md` (plus optional supporting files) following Anthropic best practices and the PT-BR/EN language strategy. Operates in two modes:

- **Create mode** — design a skill from scratch from user's intent
- **Import mode** — convert an existing slash command, workflow, prompt, or Agent Skills `SKILL.md` from another tool (Cursor, Continue, Windsurf, Codex CLI, etc.) into a Claude Code skill with full feature parity

## Activation

Create mode (EN + PT-BR):
- "create a skill", "scaffold a skill", "new slash command", "make a /<name> command", "reusable workflow"
- "criar uma skill", "nova skill", "fazer um slash command", "comando customizado", "skill para X"

Import mode (EN + PT-BR):
- "import this Cursor command", "convert this workflow", "port this skill", "turn this into a Claude Code skill", "adapt this prompt"
- "importar skill do Cursor", "converter workflow do Windsurf", "portar prompt do Continue", "adaptar este SKILL.md", "transformar em skill do Claude Code"

## Required inputs — Create mode

Collect via `AskUserQuestion` if missing. Do not invent values.

1. **Purpose** — one-sentence what the skill does (drives `description`)
2. **Content type** — `reference` (knowledge Claude applies inline) or `task` (step-by-step procedure with side effects)
3. **Trigger phrases** — verbatim things user will say (drives auto-invocation matching)
4. **Invocation control:**
   - Default (both can invoke): omit both fields
   - User-only (`disable-model-invocation: true`): for ops with side effects (`/commit`, `/deploy`, `/send-message`)
   - Claude-only (`user-invocable: false`): for background knowledge (`legacy-system-context`)
5. **Tools needed** — drives `allowed-tools` (pre-approval allowlist, not restriction)
6. **Arguments** — does it take `$ARGUMENTS`? Named via `arguments:` frontmatter list?
7. **Dynamic context** — needs `` !\`<cmd>` `` injection (live data baked into prompt)?
8. **Subagent execution** — should it run in `context: fork` (isolated context) with a specific `agent:`?
9. **Hooks needed** — see "Hooks in skills" section below

## Required inputs — Import mode

1. **Source path or content** — path to existing file (`.cursor/commands/x.md`, `.windsurf/workflows/x.md`, `.continue/prompts/x.md`, `<n>/SKILL.md`) OR pasted content
2. **Source platform** (auto-detect if possible from path/frontmatter, else ask):
   - Agent Skills standard (any `SKILL.md` with `name` + `description`)
   - Cursor command (`.cursor/commands/`)
   - Cursor rule (`.cursor/rules/*.mdc`)
   - Continue prompt (`.prompt`/`.md` with `invokable: true`)
   - Windsurf skill (`.windsurf/skills/<n>/SKILL.md`) — Agent Skills compliant
   - Windsurf workflow (`.windsurf/workflows/<n>.md`)
   - Other (paste raw content + describe)
3. **Target name** — defaults to source filename minus extension; ask if collision
4. **Target scope** — `.claude/skills/` (project) or `~/.claude/skills/` (user)
5. **Add Claude Code extensions?** — offer optional upgrades:
   - `disable-model-invocation: true` (if side effects detected)
   - `allowed-tools` allowlist (always recommend; tighten if source is broad)
   - `hooks:` (if deterministic enforcement needed)
   - `context: fork` + `agent:` (if isolation desired)
   - `paths:` (if source had path-scope rule)
   - PT-BR trigger phrases in description (always recommend)

See [references/conversion-guide.md](references/conversion-guide.md) for the full field-mapping table per source platform.

## Frontmatter template

Only `description` is recommended. All others optional.

```yaml
---
name: <kebab-case-name>            # max 64 chars; defaults to dir name if omitted
description: "<One-line purpose. Use proactively when X. Trigger phrases including PT-BR variants 'criar X', 'novo Y'.>"
when_to_use: "<Optional. Extra trigger context. Appended to description. Combined cap: 1536 chars.>"
argument-hint: "[arg1] [arg2]"     # autocomplete hint, optional
arguments: [arg1, arg2]            # named positional args, optional
disable-model-invocation: true     # user-only invoke, optional
user-invocable: false              # Claude-only invoke, optional
allowed-tools: Read Grep Bash(git status *)   # pre-approve specific tools/scopes
model: <haiku|sonnet|opus|inherit> # session-scoped override, optional
effort: <low|medium|high|xhigh|max> # optional
context: fork                      # run in subagent context, optional
agent: Explore                     # subagent type for context: fork
paths: ["src/**/*.ts"]             # auto-load only when working with matching files
shell: powershell                  # for Windows !\`<cmd>` execution
hooks:                             # lifecycle hooks scoped to this skill
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./scripts/validate.sh"
---
```

## Body template — task content

```markdown
# <Skill Display Name>

<One paragraph: what this skill does, what it does NOT do.>

## Inputs

- `$ARGUMENTS` — <what user passes>
- `$0` / `$ARGUMENTS[0]` — <first positional>

## Dynamic context

Live data, injected at invocation time:

\`\`\`!
git status --short
git diff --stat
\`\`\`

## Steps

1. <Numbered, verifiable step.>
2. <Step.>

## Critical Rules

- <Hard constraint.>
- <Confirmation gate for destructive ops.>
```

## Body template — reference content

```markdown
# <Skill Display Name>

<Standing instructions — facts, conventions, patterns Claude applies inline.>

## Conventions

- <Rule 1.>
- <Rule 2.>

## Reference

- For X, see [reference.md](reference.md)
- For examples, see [examples/](examples/)
```

## Hooks in skills — when they fit

Skills can declare lifecycle hooks via the `hooks:` frontmatter field. Hooks fire only while the skill is active. Use them when prose instructions are insufficient and you need deterministic enforcement.

| Use case | Hook event | Hook type |
|---|---|---|
| Validate Bash command before run (e.g., block SQL writes) | `PreToolUse` matcher: `Bash` | `command` (shell script, exit 2 to block) |
| Auto-run linter after Edit/Write | `PostToolUse` matcher: `Edit\|Write` | `command` |
| Cleanup when skill task ends | `Stop` | `command` |
| Block prompt submission unless precondition met | `UserPromptSubmit` | `command` or `prompt` |

Hook types:
- `command` — shell script. Neutral to language. Best default.
- `prompt` — single-turn LLM call. Sensitive to language; write in English.
- `agent` — full subagent. Multiplies tokens 4-7×; rare.
- `http` — webhook. Neutral.

Skip hooks for: simple workflows, single-step skills, anything where prose suffices. Hooks add complexity and require maintenance of an external script.

## Best practices

1. **Concise body.** Skill content stays in context across turns once invoked. Every line is a recurring token cost. State what to do, not why.
2. **English frontmatter and body.** PT-BR infra costs 30-50% more tokens and degrades trigger matching (tokenizer is 38.8% EN, 3.7% all-other-languages). User chat stays PT-BR; SKILL.md stays EN.
3. **Bilingual triggers in `description`.** Description body itself stays EN, but include PT-BR trigger phrases verbatim so auto-invocation fires when user requests in Portuguese. Pattern: `"...including PT-BR phrasings like 'criar X', 'novo Y'."`
4. **Technical terms in English.** Even inside PT-BR triggers, keep `commit`, `hook`, `skill`, `subagent`, `API`, `CLI`, `JSON` in English. PT translations fragment tokenization.
5. **Pushy description.** Lead with use case + "Use proactively when...". Pack trigger keywords. Anthropic explicitly notes Claude under-triggers skills.
6. **Use case first.** `description` + `when_to_use` are truncated at 1536 chars in the listing. Lead with the canonical scenario.
7. **`disable-model-invocation: true` for side effects.** `/commit`, `/deploy`, `/send-message` — anything you want timing control over. Removes description from context until invoked.
8. **`allowed-tools` is pre-approval, not restriction.** Skips permission prompts when skill is active. Use scoped patterns: `Bash(git add *) Bash(git commit *)`.
9. **Move long reference content to supporting files.** Keep SKILL.md under ~500 lines. Use `[reference.md](reference.md)` and `[examples/](examples/)` so detail loads on demand.
10. **Dynamic context via `` !\`<cmd>` ``.** Runs at invocation, output replaces placeholder before Claude sees the prompt. Better than asking Claude to run the command itself.
11. **`context: fork` only when skill has a real task.** Reference-only skills in a fork return without output. Pair `context: fork` with `agent:` (e.g., `Explore` for read-only research).
12. **Argument substitutions.** `$ARGUMENTS` (full string), `$0`/`$1`/`$N` (positional), `$name` (named). Wrap multi-word values in quotes when invoking.
13. **Re-invoke after compaction.** Skills carry forward at first 5000 tokens / shared 25000 budget. Large or older skills can be dropped — re-invoke if behavior drifts.

## Anti-patterns — block these

- PT-BR description or body (PT-BR triggers inside an EN description are fine — full PT-BR is not)
- Translating technical terms to PT-BR (`habilidade`, `gancho`, `subagente`)
- Body padded with backstory, motivation, or "why" — state the rule, not the reason
- Generic description ("helps with code") — fails trigger matching
- Description without concrete trigger phrases
- `context: fork` on a reference-only skill (no task = no output)
- Invented `name` mismatching the directory name (causes confusion)
- Long inline reference content that should live in `reference.md`
- Hooks where prose would suffice
- `allowed-tools` with broad `Bash(*)` — narrow to specific scopes
- Emojis or decorative icons (colored circles, checkmarks, crosses, pictographs) in SKILL.md, templates, references, or prescribed outputs — use plain text labels (`**Critical**`, `[CRITICAL]`) instead. Exception: code blocks and verbatim-quoted external content.

## Workflow — Create mode

1. Glob `.claude/skills/*/` and `~/.claude/skills/*/` — check name collision. If clash, ask for new name.
2. Gather missing inputs via `AskUserQuestion`.
3. Decide structure:
   - Single-file skill: `<name>/SKILL.md`
   - With reference: add `<name>/reference.md`, link from SKILL.md
   - With examples: add `<name>/examples/<example>.md`, link from SKILL.md
   - With scripts: add `<name>/scripts/<script>.sh`, reference via `${CLAUDE_SKILL_DIR}/scripts/<script>.sh`
4. Write the files with the templates above.
5. Tell user: skill created. New top-level `.claude/skills/` directory needs a session restart to be watched. Edits to existing skills hot-reload within session.

## Workflow — Import mode

1. **Detect source format.** Read path/frontmatter:
   - `.cursor/commands/<name>.md` → Cursor command
   - `.cursor/rules/<name>.mdc` with `alwaysApply` / `globs` → Cursor rule
   - `<name>/SKILL.md` with `name` + `description` → Agent Skills standard (Windsurf, Codex CLI, Copilot, etc. all use this)
   - `.continue/prompts/<name>.md` or `.prompt` with `invokable: true` → Continue prompt
   - `.windsurf/workflows/<name>.md` → Windsurf workflow
   - Else → ask user
2. **Read source.** Read the file(s). For Agent Skills standard sources, also enumerate `scripts/`, `references/`, `assets/` siblings.
3. **Map fields.** Apply the rules in [references/conversion-guide.md](references/conversion-guide.md):
   - Direct passthrough fields (`name`, `description`, `allowed-tools`)
   - Dropped fields (`license`, `metadata`) → preserve where appropriate (LICENSE file, body note)
   - Renamed fields (Cursor `globs:` → Claude `paths:`)
   - Synthesized fields (Cursor command → add `disable-model-invocation: true`)
4. **Strengthen body:**
   - Rewrite description with pushy phrasing + EN + PT-BR triggers
   - Add `<example>` blocks if missing
   - Convert `@file` references to `` !\`cat <file>` `` injections where it improves token economy
   - Add confirmation gate if body has destructive ops
   - Tighten `allowed-tools` to scoped patterns
5. **Glob for collision** at target path. If clash, ask for new name.
6. **Write the new skill.** `.claude/skills/<name>/SKILL.md` plus any ported supporting files.
7. **Report mapping.** Show user a diff of what was renamed/dropped/added so they can verify.
8. **Tell user:** skill created. Restart session if `.claude/skills/` is new; otherwise hot-reloads.

## Supporting files

- [references/claude-code-skills-doc.md](references/claude-code-skills-doc.md) — condensed summary of the official Claude Code Skills doc. Read for exact frontmatter field semantics, string substitutions, content lifecycle, hooks integration, permission/visibility states.
- [references/conversion-guide.md](references/conversion-guide.md) — field-by-field mapping for importing from Agent Skills standard, Cursor commands/rules, Continue prompts, Windsurf workflows/skills, OpenAI Codex CLI, GitHub Copilot, Gemini CLI, Roo, Goose, Trae, Amp. Read in Import mode.
- [references/claude-code-language-strategy.md](references/claude-code-language-strategy.md) — EN/PT-BR language strategy for skill infrastructure vs user-facing content. Read when deciding what stays English.
- [references/skill-description-ptbr-triggers.md](references/skill-description-ptbr-triggers.md) — patterns and verbatim examples for embedding PT-BR trigger phrases in EN descriptions.
- [examples/commit.md](examples/commit.md) — fully-formed task skill demonstrating `disable-model-invocation`, scoped `allowed-tools`, `$ARGUMENTS`, and `` !\`<cmd>` `` dynamic context. Use as a copy-paste starting point.
