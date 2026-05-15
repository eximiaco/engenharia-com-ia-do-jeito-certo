---
name: create-subagent
description: "Scaffold a new custom subagent at .claude/agents/<name>.md with best-practice frontmatter and prompt structure. Use proactively whenever the user asks to create, build, scaffold, or design a custom agent, subagent, or specialized worker — including PT-BR phrasings like 'criar um agent', 'novo subagent', 'fazer um agente para X'. Enforces strict tool allowlist, English infrastructure (per Anthropic canon), pushy descriptions with verbatim <example> blocks, and confirmation gates for destructive ops."
allowed-tools: Read, Write, Glob, AskUserQuestion
disable-model-invocation: true
---

# Create Custom Subagent

Scaffolds `.claude/agents/<name>.md` following Anthropic best practices and the PT-BR/EN language strategy.

## Activation

Trigger phrases (EN + PT-BR):
- "create a subagent", "scaffold an agent", "new custom agent", "I need an agent for X"
- "criar um agent", "criar subagent", "novo agente", "agente para X", "fazer um subagent"

## Required inputs

Collect via `AskUserQuestion` if missing. Do not invent values.

1. **Purpose** — one-sentence what the agent does (drives `description`)
2. **Trigger phrases** — verbatim things user will say (drives `<example>` blocks)
3. **Tools** — minimum tool set for the body's actions
4. **Model** — `haiku` (cheap/simple), `sonnet` (default), `opus` (deep reasoning), `inherit`
5. **Memory scope** — `project` (default, version-controlled), `user` (cross-project), `local` (gitignored), or omit
6. **Destructive ops?** — if yes, body must require explicit chat confirmation

## Tool allowlist — strict

Grant ONLY tools the body actually calls. Bloated `tools:` is a documented antipattern.

| Task pattern | Tools |
|---|---|
| Read-only research | `Read, Grep, Glob` |
| File edits | `Read, Edit, Write, Glob` |
| Shell ops | `Bash` (+ Read/Glob if needed) |
| Code review | `Read, Grep, Glob, Bash` (no Edit/Write) |
| Translation | `Read, Write` |
| Cleanup/deletion | `Glob, Read, Bash` (no Write) |

Never list `disallowedTools` unless explicit "inherit-minus-N" requirement.

## Frontmatter template

```yaml
---
name: <kebab-case-name>
description: "<One-line purpose.>\n\n**Examples:**\n\n<example>\nContext: <scenario>\nuser: \"<verbatim request>\"\nassistant: \"I'll use the <name> agent to <action>.\"\n<commentary>\n<one-line why this agent fits>\n</commentary>\n</example>\n\n<example>\nContext: <different scenario>\nuser: \"<request>\"\nassistant: \"<ack>\"\n</example>"
tools: <comma-separated allowlist>
model: <haiku|sonnet|opus|inherit>
color: <red|blue|green|yellow|purple|orange|pink|cyan>
memory: <project|user|local>
---
```

## Body template

```markdown
# <Agent Display Name>

<One paragraph: what it does, what it does NOT do.>

## When to act

<Explicit trigger conditions. State if no-arg invocation is supported.>

## How to <verb>

1. <Numbered, verifiable step.>
2. <Step.>

## Critical Rules

- <Hard constraint: paths, regex, never-do conditions.>
- <Confirmation gate for destructive ops.>

## Memory

Save: <preferences, patterns, glossary>.
Do not save: <file paths, git history, ephemeral task state>.
```

## Best practices (enforce in every generated agent)

1. **Single focused task.** One agent = one job. Reject scope creep.
2. **English frontmatter and body.** PT-BR infra costs 30-50% more tokens and degrades trigger matching (tokenizer is 38.8% EN, 3.7% all-other-languages). User's chat stays PT-BR; agent file stays EN.
3. **Bilingual triggers in `description`.** Description body itself stays EN, but include PT-BR trigger phrases verbatim so auto-delegation fires when user requests in Portuguese. Pattern: `"...including PT-BR phrasings like 'criar X', 'novo Y', 'fazer Z'."` Same applies to `<example>` blocks — `user:` line copies real PT-BR phrasing; `assistant:` ack stays EN.
4. **Technical terms in English.** Even inside PT-BR triggers, keep `auth`, `middleware`, `hook`, `subagent`, `skill`, `commit`, `API`, `JSON`, `CLI`, etc. in English. PT translations ("habilidade", "gancho", "subagente") fragment tokenization and reduce match with the model's training corpus.
5. **Pushy description.** Claude under-triggers by default. Lead with "Use proactively when..." and pack the description with concrete trigger phrases.
6. **`<example>` blocks beat abstractions.** Verbatim user phrasing in `<example>` blocks improves auto-delegation more than prose.
7. **Verifiable steps.** Imperative numbered steps, each checkable. No "consider", "you might".
8. **Confirmation gates.** Destructive ops (rm, commit, push, write) wait for explicit user "yes/sim/apply/confirma" in chat before executing.
9. **Commit messages in English.** If the agent generates commits, default the commit message to English (Conventional Commits format). Aligns with ecosystem convention and stays cheap to tokenize.
10. **Memory discipline.** Save preferences, glossaries, recurring decisions. Never save file lists, git state, or per-task ephemera.
11. **Model match.** `haiku` for cleanup/format/translate. `sonnet` for default work. `opus` only for multi-step reasoning chains.

## Anti-patterns — block these

- Listing every tool "just in case"
- PT-BR description or system prompt body (PT-BR triggers inside an EN description are fine — full PT-BR is not)
- Translating technical terms to PT-BR (`habilidade`, `gancho`, `subagente`, `commit → "envio"`)
- Description without `<example>` blocks
- Soft phrasing ("consider X", "you might Y")
- Missing confirmation gate before destructive Bash ops
- Saving file paths or git history to memory
- `disallowedTools` when a strict `tools` allowlist suffices

## Workflow

1. Glob `.claude/agents/*.md` — check name collision. If clash, ask for new name.
2. Gather any missing inputs via `AskUserQuestion`.
3. Write `.claude/agents/<name>.md` with the templates above.
4. Tell user: agent created, **restart Claude Code session** to load it (manual file edits don't hot-reload; only the `/agents` UI does).

## Supporting files

- [reference.md](reference.md) — condensed summary of the official Custom Subagents doc. Read when you need exact frontmatter field semantics, permission-mode behavior, hook lifecycle, or scope precedence rules.
- [examples/code-reviewer.md](examples/code-reviewer.md) — fully-formed reference agent demonstrating every best practice (pushy description, `<example>` blocks, strict allowlist, memory section). Use as a copy-paste starting point.
