# Claude Code Skills

Coleção de skills para Claude Code.

## Skills disponíveis

| Skill | Descrição |
|---|---|
| `/cc-audit` | Audita artifacts do Claude Code (skills, agents, hooks, settings) contra a documentação oficial e a estratégia de linguagem do projeto |
| `/create-skill` | Scaffolda uma nova skill em `.claude/skills/<name>/SKILL.md`, ou importa/converte skills de outras ferramentas (Cursor, Windsurf, Continue, etc.) |
| `/create-subagent` | Scaffolda um novo subagent em `.claude/agents/<name>.md` com frontmatter e estrutura de prompt corretos |
| `/tech-radar` | Analisa um repositório e gera um Tech Radar no estilo Thoughtworks (`.md`, `.csv`, `.html`) |

## Instalação

Requer [`gh` CLI](https://cli.github.com/) autenticado (`gh auth login`).

**Global** — disponível em todas as sessões do Claude Code:

```bash
gh api repos/eximiaco/ai-playbook/contents/claude-code/install.sh --jq '.content' | base64 -d | bash
```

**Project-local** — execute na raiz do projeto:

```bash
gh api repos/eximiaco/ai-playbook/contents/claude-code/install.sh --jq '.content' | base64 -d | bash -s .
```

Após instalar, rode `/reload-plugins` no Claude Code.

## Atualização

Rode o comando de instalação novamente — ele sobrescreve a versão anterior.
