# Skill Description Triggering Across Languages (pt-BR Input → English Description)

Reference for authoring `SKILL.md` YAML `description` fields that trigger reliably when the developer prompts Claude Code in Brazilian Portuguese. The description stays in English (per the language strategy), but must be designed so pt-BR phrasing maps cleanly onto it.

---

## How Skill Triggering Works

Skill discovery is **LLM-based, not regex or embedding similarity**. Claude Code concatenates the `name + description` of every available skill into the Skill tool's system prompt. When the user sends a message, the model decides — using natural-language understanding — which skill (if any) to invoke.

This means:

- **Matching is semantic, not lexical.** The user's words do not need to literally appear in the description. The model maps intent → description.
- **pt-BR input matches English description fine for common concepts.** Claude operates in a shared cross-lingual conceptual space. "Criar uma apresentação" maps to a description mentioning "slide deck" without friction.
- **The model defaults to undertriggering.** Anthropic's own warning: skills fire less often than they should. Descriptions must be "pushy" to compensate.
- **Failure modes are not random.** They concentrate on (a) terms with no stable translation, (b) project-specific jargon, (c) low-frequency synonyms, (d) phrasings the model does not associate with the description's core verbs.

---

## When pt-BR Input Reliably Matches an English Description

These cases work without any pt-BR mention in the description:

| pt-BR phrasing | Matches English description containing |
|---|---|
| "cria uma tarefa", "adiciona um todo", "bota no todoist" | `tasks`, `todos`, `task management` |
| "faz uma apresentação sobre X" | `slide deck`, `presentation`, `pitch deck` |
| "abre um chamado no jira" | `issue tracking`, `tickets` |
| "lê esse pdf pra mim" | `read PDF`, `extract text from PDF` |
| "escreve um relatório em word" | `Word document`, `.docx`, `report` |
| "faz uma planilha com esses dados" | `spreadsheet`, `Excel`, `.xlsx` |
| "manda um email pro time" | `email`, `compose message`, `send email` |
| "agenda uma reunião amanhã" | `calendar event`, `schedule meeting` |

Rule of thumb: if the concept exists in mainstream English technical vocabulary and the Portuguese phrasing is a direct semantic equivalent, the English description triggers correctly.

---

## When pt-BR Input Can Fail to Match — and How to Fix It

Three failure modes require explicit mitigation in the description.

### Failure mode 1: Project-specific jargon

The team uses a verb or noun with a meaning that does not appear in the general English description.

**Example:** The team says "refinar tarefa" to mean a specific workflow (split into subtasks, add labels, set priority). A description saying `Use this skill to improve and structure tasks` may not trigger on "refina essa tarefa pra mim".

**Fix:** Quote the pt-BR term explicitly inside the English description.

```yaml
description: Manages tasks in the user's Todoist: create, refine, update, and
organize tasks and subtasks. Use this skill whenever the user mentions tasks,
todos, reminders, or pt-BR phrasings like "criar tarefa", "refinar tarefa",
"bota no todoist", "lembra de", "adiciona no inbox", even if they don't
explicitly ask.
```

### Failure mode 2: Terms with no stable English equivalent

A pt-BR term names something that has no widely-used English label.

**Example:** "NFS-e" (nota fiscal de serviço eletrônica) — the closest English term is "electronic service invoice", which does not appear naturally in the model's training distribution for that exact concept.

**Fix:** Use the pt-BR term as-is in the description. Do not force a translation.

```yaml
description: Issues and manages NFS-e (nota fiscal de serviço eletrônica) for
Brazilian service providers. Use this skill whenever the user mentions nota
fiscal, NFS-e, emitir nota, or invoice for services rendered in Brazil.
```

### Failure mode 3: Low-frequency synonyms or informal phrasing

The model knows the formal term but the user uses casual pt-BR phrasing.

**Example:** Description mentions "create presentation" — user says "monta uns slides pra mim". "Monta" is informal and not the canonical translation of "create".

**Fix:** Add a short list of informal pt-BR triggers covering the common phrasings.

```yaml
description: Creates and edits .pptx slide decks. Use this skill whenever the
user mentions slides, presentation, pitch deck, or pt-BR phrasings like
"apresentação", "monta uns slides", "faz um deck", "powerpoint", even if they
don't explicitly ask for a .pptx file.
```

---

## The Hybrid Description Pattern

Default template for any skill in a pt-BR-speaking environment:

```yaml
description: <core function in English>. Use this skill whenever the user
mentions <EN trigger 1>, <EN trigger 2>, <EN trigger 3>, or pt-BR equivalents
like "<termo pt-BR 1>", "<termo pt-BR 2>", "<termo pt-BR 3>", even if they
don't explicitly ask for <core concept>.
```

Anatomy:

1. **Sentence 1 — core function in English.** Describes what the skill does. Drives semantic matching for common concepts.
2. **Sentence 2 — pushy trigger list.** "Use this skill whenever..." is the canonical Anthropic-recommended pattern. List 3–5 English triggers, then 3–5 pt-BR triggers. Close with "even if they don't explicitly ask" to counteract undertriggering.

Length: stay under the 1024-character `description` limit. The pt-BR triggers are worth their token cost — they are loaded into the Skill tool's system prompt once per session, not per turn, and they buy directly improved trigger reliability for the dev's actual phrasing.

---

## Which pt-BR Terms to Include

Include a pt-BR trigger when **at least one** of these is true:

- The term is project- or team-specific jargon ("refinar tarefa", "exibir no planner", "fechar OS").
- The term names a concept with no stable English equivalent ("NFS-e", "DARF", "boleto").
- The user's natural phrasing is informal and unlikely to appear verbatim in English description prose ("bota no", "manda pro", "joga aí no").
- The English term is a calque the model may not associate with the pt-BR verb the user actually uses ("eproc" vs "judicial process management").

Do NOT include a pt-BR trigger when:

- The pt-BR phrasing is a direct, formal translation of the English term ("criar apresentação" ↔ "create presentation"). The model handles these natively.
- The skill is meant for international use and pt-BR triggers would pollute the description for non-pt-BR users.
- You are at the 1024-char limit and need to cut something — drop the most formal pt-BR synonyms first.

---

## Examples From Real Skill Descriptions

### Example A — Todoist task manager (jargon-heavy, pt-BR primary user)

```yaml
description: Gerencia tarefas no Todoist do usuário: criar, refinar, atualizar e
organizar tarefas e subtarefas. Use esta skill sempre que o usuário pedir para
adicionar, criar, atualizar, mover ou organizar tarefas no Todoist — mesmo que
use linguagem informal como "bota no todoist", "cria uma tarefa pra", "lembra
de", "adiciona no inbox", "coloca no projeto X". Também use quando o usuário
passar uma lista de itens para processar em lote, ou pedir para refinar/melhorar
tarefas existentes.
```

**Analysis:** This is the *fallback case* — entire description in pt-BR. Justified only because the skill is exclusively a single pt-BR user's tooling and the dev personally reads/edits the SKILL.md. For shared or team skills, prefer the hybrid pattern below.

### Example B — Same skill rewritten in the hybrid pattern (recommended default)

```yaml
description: Manages tasks in the user's Todoist: create, refine, update, and
organize tasks and subtasks. Use this skill whenever the user asks to add,
create, update, move, or organize tasks, todos, or reminders — including
pt-BR phrasings like "bota no todoist", "cria uma tarefa pra", "lembra de",
"adiciona no inbox", "refinar tarefa", or when the user pastes a list of items
to process in batch, even if they don't explicitly mention Todoist.
```

**Analysis:** English structure for tokenizer efficiency and canonical regime, pt-BR triggers quoted for project-specific jargon ("refinar", "bota no"), pushy closing phrase, and an additional trigger ("pastes a list of items") that captures intent without language dependency.

### Example C — Redmine issue manager

```yaml
description: Manages issues on the TJSP Redmine. Use when the user asks to
create, list, read, update, or delete Redmine issues — including pt-BR
phrasings like "cria uma issue", "abre um chamado no redmine", "atualiza a
issue #X", "fecha o chamado", or any mention of TJSP, eproc, or Redmine
issue numbers (e.g., #6001).
```

**Analysis:** Domain-specific (TJSP/eproc/Redmine), so includes the project nouns as triggers — issue numbers in the `#NNNN` range also act as implicit triggers when mentioned.

---

## Testing a Description Empirically

When unsure whether an English description triggers reliably on pt-BR input:

1. List 10–15 representative pt-BR phrasings the dev would naturally use.
2. For each phrasing, predict: will the model auto-trigger the skill, or require manual `/skill-name` invocation?
3. Run them in real Claude Code sessions. Count auto-triggers vs misses.
4. **Under-trigger threshold: >20% miss rate.** At that point, add the missed phrasings as explicit pt-BR triggers in the description and re-test.
5. Use Anthropic's `skill-creator` description optimizer (`scripts/run_loop.py`) if available — it iterates on description quality automatically against an eval set.

The official Anthropic guidance is to make descriptions "a little bit pushy" rather than minimal. Err on the side of including more triggers than feels natural.

---

## Self-Check Before Saving a Description

- [ ] Does sentence 1 state the skill's core function clearly in English?
- [ ] Does sentence 2 start with "Use this skill whenever..." or equivalent pushy phrasing?
- [ ] Does the trigger list include 3+ English triggers covering the core verbs/nouns?
- [ ] If any of the failure modes apply (project jargon, no-English-equivalent terms, informal phrasings), are 2–4 pt-BR triggers quoted explicitly?
- [ ] Does the description end with "even if they don't explicitly ask..." or similar undertriggering counter-phrase?
- [ ] Is the description under 1024 characters?

If any check fails, revise before committing.