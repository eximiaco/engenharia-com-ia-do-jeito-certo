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

**Global** — disponível em todas as sessões do Claude Code:

```bash
curl -fsSL https://raw.githubusercontent.com/eximiaco/engenharia-com-ia-do-jeito-certo/main/claude-code/install.sh | bash
```

**Project-local** — execute na raiz do projeto:

```bash
curl -fsSL https://raw.githubusercontent.com/eximiaco/engenharia-com-ia-do-jeito-certo/main/claude-code/install.sh | bash -s .
```

Após instalar, rode `/reload-plugins` no Claude Code.

## Atualização

Rode o comando de instalação novamente — ele sobrescreve a versão anterior.
