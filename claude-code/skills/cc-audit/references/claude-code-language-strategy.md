# Claude Code Language Strategy: PT-BR vs English

Technical guide for choosing the language of every artifact in a Claude Code setup. Follow these rules when authoring or auditing CLAUDE.md, SKILL.md, subagents, hooks, slash commands, code, and interactive output.

---

## Decision Table — Apply These Rules Verbatim

| Artifact | Required language | Notes |
|---|---|---|
| `CLAUDE.md` (global, project, component) | **English** | Body in English; include a single line requesting pt-BR responses (see template below) |
| `.claude/skills/*/SKILL.md` (full file, including YAML `description`) | **English** | Description must be "pushy" (see Skills rules) |
| `.claude/agents/*.md` (subagents — name, description, tools, system prompt) | **English** | All fields, including the system prompt body |
| `.claude/commands/*.md` (slash commands) | **English** | These are prompts; treat as infrastructure |
| Hooks of type `prompt` or `agent` | **English** | LLM-invoking hooks |
| Hooks of type `command` (shell) or `http` (webhook) | **Any language** | Language-neutral |
| Code identifiers, function names, variable names | **English** | Match ecosystem convention (PEP 8, JS standards) |
| Code comments and docstrings | **English** | Prevents code-switch drift on subsequent edits |
| Commit messages | **English** | Use Conventional Commits format |
| Technical terms inside pt-BR prose (auth, middleware, hook, subagent, skill, deploy) | **English** | Do not translate — preserves embedding-space matching |
| Interactive chat responses to the user | **pt-BR** | Configured via the CLAUDE.md request line |
| UI strings, error messages for end users | **pt-BR** | |
| Product `README.md` (not infra), wikis, business runbooks | **pt-BR** | |
| PR descriptions, issue messages aimed at the team | **pt-BR** | |

---

## CLAUDE.md Template (Drop-In)

Add to `~/.claude/CLAUDE.md` (global) or project-level `CLAUDE.md`:

```markdown
# Communication preferences
- Always respond to me in Brazilian Portuguese (pt-BR)
- Keep all code identifiers, comments, and docstrings in English
- Keep commit messages in English using Conventional Commits
- Use English for technical terms (auth, middleware, hook, subagent, skill, etc.)
  even when the prose is in pt-BR
```

This single block establishes the asymmetric mixed approach: English infrastructure, pt-BR output. Do not duplicate this block in every project CLAUDE.md if it already exists in `~/.claude/CLAUDE.md` — global takes effect everywhere.

For Claude Code 2.1+, the optional `response-language` setting in `settings.json` is the deterministic equivalent and overrides any CLAUDE.md prose. Prefer `settings.json` when consistency matters.

---

## Rules for SKILL.md Authoring

1. **Write the full file in English** — frontmatter, body, references, examples. No exceptions for the `description` field.
2. **Make the `description` "pushy".** Required pattern:
   ```
   description: <what the skill does>. Use this skill whenever the user mentions
   <trigger 1>, <trigger 2>, or <trigger 3>, even if they don't explicitly ask
   for <core concept>.
   ```
   Reason: Claude undertriggers skills by default. Anthropic explicitly recommends pushy framing.
3. **Discovery is LLM-based, not regex.** The full `name + description` of every skill is concatenated into the Skill tool's system prompt. The model decides via natural-language matching. pt-BR descriptions fragment more in the tokenizer and match less canonically against the embedding space — both effects increase undertriggering. Always English.
4. **Body length:** keep `SKILL.md` under 500 lines. Reference larger material from `references/`.
5. **For pt-BR end users who must read the skill manually**, keep `SKILL.md` in English and add `references/pt-br.md` with a translated explanation. Reference it from the body with: `For Portuguese-speaking team members, see references/pt-br.md.`

---

## Rules for Subagents (`.claude/agents/*.md`)

1. **All fields in English:** `name`, `description`, `tools`, and the entire system prompt body.
2. **Multi-agent workflows cost 4–7× the tokens of single-agent sessions.** Agent Teams cost ~15×. Writing subagent prompts in pt-BR multiplies overhead at the layer where it compounds the most.
3. **Auto-routing is imperfect** — Opus models in particular over-delegate to subagents. Do not rely on subagent invocation for tasks the main context can handle directly.
4. **Description follows the same pushy pattern** as Skills: state the role, then list trigger contexts.

---

## Rules for Hooks

Determine the handler type before deciding the language:

| Handler type | Language rule |
|---|---|
| `command` | Any language — shell scripts are neutral |
| `http` | Any language — webhook payloads are neutral |
| `prompt` | English — runs as a single-turn LLM call |
| `agent` | English — runs a full subagent |

Place language-related deterministic configuration (response language, formatting locale) in `settings.json`, not in CLAUDE.md prose. `settings.json` overrides advisory CLAUDE.md instructions.

---

## Code Authoring Rules

1. **Identifiers in English.** `calculateOrderTotal`, not `calcularTotalPedido`. pt-BR identifiers cause the model to code-switch on subsequent edits — partial English creeps in until the codebase is mixed.
2. **Comments and docstrings in English.** Same reason.
3. **Commit messages in English using Conventional Commits.** `feat:`, `fix:`, `refactor:`, etc.
4. **Technical terminology stays English even inside pt-BR prose.** Write "configurar o middleware de auth" — not "configurar o intermediário de autenticação". No stable Portuguese translations exist for these terms; forced translation reduces matching against the model's training distribution.

---

## When to Deviate

### Switch the affected artifact to pt-BR if:

- The `SKILL.md` or subagent prompt is meant for end users (Brazilian non-technical) who will read/edit it directly. In that case keep the artifact in pt-BR and accept the trade-off.
- Measured under-trigger rate exceeds 20% on English-described skills (count manual `/skill-name` invocations vs auto-triggers in real use). At that point, rewriting the description in pt-BR may help even if it costs tokens.
- A specific client contractually requires pt-BR documentation in `SKILL.md`.

### Keep everything in English (no pt-BR output) if:

- API cost is the binding constraint and the ~10% residual overhead from pt-BR responses is unacceptable.
- The configuration is being shared with international teams.
- Switching cost between EN and PT during development is hurting velocity.

### Re-evaluate the whole strategy at each major Claude release:

- New tokenizer compositions can rebalance the overhead.
- New multilingual benchmarks for **agentic instruction-following** (not just MMLU) may close or open the gap.

---

## Adoption Steps for an Existing Setup

Execute in order:

1. **Audit `~/.claude/CLAUDE.md`** — if missing, add the template block above. If present in pt-BR, translate the body to English and keep only the response-language preference line in pt-BR phrasing.
2. **Audit every `.claude/skills/*/SKILL.md`** — translate any pt-BR frontmatter or body to English. Rewrite descriptions in the pushy pattern.
3. **Audit every `.claude/agents/*.md`** — translate name, description, tools, and system prompt body to English.
4. **Audit `.claude/commands/*.md`** — translate to English.
5. **Audit hook handlers of type `prompt` or `agent`** — translate to English. Leave `command`/`http` handlers untouched.
6. **Configure prompt caching** for the English CLAUDE.md (cache reads cost 10% of input price — significant mitigation for repeated invocations).
7. **Verify with `POST /v1/messages/count_tokens`** — measure a representative prompt before and after the audit. Expect 25–45% input token reduction on infrastructure.

---

## Self-Check Before Committing Any Artifact

Run through this checklist when about to save a new or edited artifact:

- [ ] Is the YAML frontmatter (name, description) in English?
- [ ] Is the body of the file in English?
- [ ] Are code identifiers, comments, docstrings in English?
- [ ] Is the commit message in English with Conventional Commits format?
- [ ] If pt-BR text is present anywhere in the file, is it strictly in user-facing strings (UI labels, error messages shown to the end user)?
- [ ] If the artifact is a `SKILL.md`, does the description follow the pushy pattern (`Use this skill whenever...even if they don't explicitly ask...`)?

If any check fails, fix before committing.
