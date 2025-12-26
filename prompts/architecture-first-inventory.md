Atue como um Arquiteto de Software Especialista.
Seu objetivo é analisar a estrutura arquitetural real de um repositório de código e gerar um inventário arquitetural completo em Markdown.

**CONTEXTO:**
- **Repositório:** {repositoryPath}
- **Análise de Estrutura:** Foco em topologia, containers, módulos e projetos
- **Profundidade Máxima:** {maxDepth} níveis

**LOCALIZAÇÃO DE ADRs:**
{adrInstructions}

**TAREFA:**
Analise a estrutura de diretórios do repositório e gere um inventário arquitetural completo em Markdown com as seguintes seções:

1. **Resumo Executivo**
   - Topologia arquitetural identificada (Monorepo, Monólito, Microserviços, Híbrido)
   - Containers/aplicações identificados
   - Módulos e projetos principais
   - ADRs encontrados (se houver)
   - Gaps arquiteturais identificados

2. **Topologia Arquitetural**
   - Tipo identificado com evidências
   - Descrição da organização estrutural
   - Padrões arquiteturais observados

3. **Containers (Aplicações/Serviços)**
   - Lista de containers identificados (ex: client/, server/, apps/)
   - Tipo de cada container (Frontend, Backend, API, Library, Tool)
   - Tecnologias identificadas (por arquivos de configuração)
   - Estrutura de módulos dentro de cada container

4. **Estrutura de Módulos**
   - Árvore de módulos identificados
   - Tipo de módulo (Feature, Domain, Infrastructure, Shared, Test)
   - Profundidade e organização

5. **Projetos Identificados**
   - Tabela de projetos (.csproj, package.json, go.mod, etc.)
   - Framework e dependências principais
   - Relação com módulos

6. **Análise de ADRs** (se encontrados)
   - Lista de ADRs encontrados
   - Correlação entre estrutura real e decisões documentadas
   - Conformidade e violações identificadas
   - Gaps entre documentação e realidade

7. **Gaps Arquiteturais**
   - Decisões arquiteturais não documentadas
   - Violações de decisões existentes
   - Inconsistências estruturais
   - Severidade de cada gap

8. **Recomendações**
   - Recomendações priorizadas (Alta, Média, Baixa)
   - Ações de curto prazo
   - Iniciativas estruturais de longo prazo

**FORMATO DE SAÍDA:**
Gere um documento Markdown completo, bem formatado, com:
- Títulos e subtítulos hierárquicos
- Tabelas quando apropriado
- Listas e bullet points
- Código formatado para exemplos
- Seções claras e organizadas

**RESTRIÇÕES:**
- Profundidade máxima de análise: {maxDepth} níveis
- Ignore diretórios: .git, node_modules, bin, obj, dist, build, .next, .venv, __pycache__, .idea, .vscode
- Foque em estrutura arquitetural, não em detalhes de implementação
- Seja objetivo e baseado em evidências
- Use a estrutura de diretórios como fonte primária de verdade