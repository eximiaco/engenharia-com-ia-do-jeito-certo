---
name: tech-radar
description: "Analyze a repository and produce a Thoughtworks-style Tech Radar: classify every language, tool, platform, and technique as Adopt/Trial/Assess/Caution based on file evidence, then emit tech_radar_[reponame].md, tech_radar_[reponame].csv, and tech_radar_[reponame].html (via radar-html CLI) to the repository root. Use proactively when the user asks to map technologies in this repo, build a tech radar, fingerprint the stack with rings, audit tech debt by ring, or generate a Build Your Own Radar CSV — including PT-BR phrasings like 'gerar tech radar', 'criar tech radar do repo', 'fazer um radar tecnológico', 'mapear tecnologias do projeto', 'radar de tecnologias', 'classificar stack em adopt trial', 'csv para o radar da thoughtworks', 'analisar repositório e gerar radar' — even if they don't explicitly say 'tech radar'. All output files include the repository name and are written to the repo root."
argument-hint: "[repo-path]"
arguments: [repo-path]
model: sonnet
allowed-tools: Read Glob Grep Write Bash(date +*) Bash(find *) Bash(git remote *) Bash(basename *) Bash(pwd) Bash(realpath *) Bash(radar-html --version) Bash(radar-html --clean *) AskUserQuestion
---

# Tech Radar

Scans a repository for every language, framework, tool, platform, and technique with concrete file evidence, classifies each as a blip in the Thoughtworks radar structure (4 quadrants × 4 rings), and emits two artifacts: a rich Markdown context document and a CSV ready for import at https://radar.thoughtworks.com.

## Inputs

- `$0` — `repo-path`: absolute or relative path to the repo root. **Optional** — defaults to `.` (current working directory) when omitted.

Resolve `$0`:
- If `$0` is empty/unset → set `$0 = .`.
- Accept `.` as a valid value referring to the current working directory.
- Validate `$0` exists and is a directory. Abort if not.

## Dynamic context

```!
date +%Y-%m-%d
```

```!
git remote get-url origin 2>/dev/null || echo "no-remote"
```

```!
basename "$(pwd)"
```

## Steps

### 1. Pre-flight

- Resolve and validate `$0`. Operate with `$0` as the working root for all file lookups.
- Capture `[reponame]` = `basename` of the resolved absolute path of `$0`.
- Output paths (all at `$0/`):
  - `$0/tech_radar_[reponame].md`
  - `$0/tech_radar_[reponame].csv`
  - `$0/tech_radar_[reponame].html` (generated in Step 6)
- If any output already exists → `AskUserQuestion`: `tech_radar_[reponame].* já existe em $0. Sobrescrever? [sim/não]`. Abort if no.

### 2. Phase 1 — Repository scan

Collect evidence file-by-file. Apply the vendored-dir skip list from Critical Rules to every traversal.

#### Languages & Frameworks

- Source-file extension sweep with the Critical Rules skip list applied: `find $0 -type f \( -name '*.php' -o -name '*.py' -o -name '*.ts' -o -name '*.tsx' -o -name '*.js' -o -name '*.jsx' -o -name '*.go' -o -name '*.rb' -o -name '*.java' -o -name '*.kt' -o -name '*.rs' -o -name '*.cs' -o -name '*.fs' -o -name '*.vb' -o -name '*.swift' -o -name '*.scala' -o -name '*.clj' -o -name '*.ex' -o -name '*.erl' -o -name '*.lua' -o -name '*.dart' -o -name '*.c' -o -name '*.cpp' -o -name '*.h' -o -name '*.hpp' \) -not -path '*/node_modules/*' -not -path '*/vendor/*' -not -path '*/bin/*' -not -path '*/obj/*' -not -path '*/.git/*' -not -path '*/dist/*' -not -path '*/build/*' -not -path '*/target/*' -not -path '*/.next/*' -not -path '*/.nuxt/*' | head -200`
- Manifest files for versions: `composer.json`, `package.json`, `Gemfile(.lock)`, `pyproject.toml`, `requirements.txt`, `pom.xml`, `build.gradle(.kts)`, `go.mod`, `Cargo.toml`, `*.csproj`, `*.fsproj`, `*.sln`, `Directory.Packages.props`, `mix.exs`, `Package.swift`, `pubspec.yaml`.
- Toolchain hints: `.tool-versions`, `.nvmrc`, `.ruby-version`, `.python-version`, `global.json`.
- Framework signals (read manifests, grep imports/configs):
  - JS/TS: `react`, `vue`, `svelte`, `next`, `nuxt`, `remix`, `astro`, `express`, `nestjs`, `fastify`, `koa`, `tanstack`, `zustand`, `redux`, `vite`, `webpack`, `tailwindcss`, `mui`, `echarts`, `tiptap`, `fullcalendar`.
  - .NET: `Microsoft.AspNetCore.*`, `Microsoft.EntityFrameworkCore.*`, `Yarp.*`, `Serilog.*`, `OpenTelemetry.*`, `Npgsql.*`.
  - Python: `django`, `flask`, `fastapi`, `pydantic`, `sqlalchemy`, `celery`.
  - Java/Kotlin: `spring-boot-starter-*`, `hibernate`, `quarkus`.
  - Ruby: `rails`, `sinatra`, `sidekiq`.
  - Go: `gin`, `echo`, `fiber`, `gorm`.
  - PHP: `laravel/framework`, `symfony/*`, `cakephp/*`.

#### Tools

- Static analysis & lint: `phpstan.neon`, `psalm.xml`, `.eslintrc*`, `eslint.config.*`, `.prettierrc*`, `.rubocop.yml`, `pyproject.toml [tool.ruff]`, `pylintrc`, `tsconfig.json (strict)`, `sonar-project.properties`, `.editorconfig`.
- Testing: `phpunit.xml`, `jest.config.*`, `vitest.config.*`, `pytest.ini`, `pyproject.toml [tool.pytest]`, `cypress.config.*`, `playwright.config.*`, `karma.conf.*`, `rspec`, `*.Tests.csproj`, `xunit*` / `nunit*` / `mstest*` in csproj.
- Build & bundling: `Makefile`, `vite.config.*`, `webpack.config.*`, `rollup.config.*`, `esbuild`, `tsc`, `gradle*`, `mvnw*`, `Rakefile`, `tox.ini`, `nx.json`, `turbo.json`, `pnpm-workspace.yaml`.
- CLIs referenced in scripts (`package.json scripts`, `composer scripts`, `Makefile` targets).
- Formatters & generators: `prettier`, `dotnet-ef`, `swagger-codegen`, `openapi-generator`, `protoc`, `nestjs/cli`.

#### Platforms

- Container: `Dockerfile`, `*.dockerfile`, `docker-compose*.yml`, `.dockerignore`, `compose.yaml`.
- Orchestration: Kubernetes manifests (`*.yaml`/`*.yml` containing `kind:` and `apiVersion:`), `Chart.yaml` (Helm), `kustomization.yaml`.
- CI/CD: `.github/workflows/*.yml`, `.gitlab-ci.yml`, `Jenkinsfile`, `azure-pipelines*.yml`, `bitbucket-pipelines.yml`, `.circleci/config.yml`, `.drone.yml`.
- IaC: `*.tf`, `*.tfvars`, `ansible/`, `playbook*.yml`, `inventory*`, `Pulumi.yaml`, `cdk.json`, `serverless.yml`, `template.yaml` (SAM).
- Cloud & SDKs: grep for `aws-sdk`, `@aws-sdk/*`, `boto3`, `Azure.*` packages, `google-cloud-*`, `firebase`, `Amazon.*` NuGet, `LocalStack` references.
- Databases: connection strings or driver packages — `postgres`/`pg`/`Npgsql`/`psycopg`, `mysql`/`pymysql`, `mongodb`/`mongoose`, `redis`/`ioredis`/`StackExchange.Redis`, `elasticsearch`, `Microsoft.EntityFrameworkCore.*`. Inspect EF migrations folders, `prisma/`, `alembic/`, `db/migrate`.
- Monitoring & observability: `prometheus.yml`, `grafana/`, `Sentry.*`/`@sentry/*`, `datadog`/`dd-trace`, `newrelic`, `Serilog.Sinks.*`, `OpenTelemetry.*`.
- Auth/identity: `aws-cognito`/`Amazon.Cognito*`, `auth0`, `keycloak`, `Identity.*`.

#### Techniques

Infer ONLY from observable evidence — directory structure, naming conventions, config flags, comments:

- Architecture: monorepo (`pnpm-workspace.yaml`, `nx.json`, `turbo.json`, multiple top-level project dirs with own manifests), microservices (multiple deployables with own Dockerfiles), monolith, hexagonal/clean (`Domain/`, `Application/`, `Infrastructure/`), DDD bounded contexts (e.g. `contexts/<n>/`), CQRS (`Commands/`, `Queries/`, MediatR), event-driven (Kafka/RabbitMQ/SQS in deps).
- API style: REST (controllers, route decorators), GraphQL (`*.graphql`, `apollo`, `graphql`), gRPC (`*.proto`), WebSockets (`socket.io`, `SignalR`), tRPC.
- Patterns: repositories (`*Repository.cs`/`*.repo.ts`), services (`*Service.*`), unit-of-work, mediator, factories.
- Security: secrets via `.env.example` (template-only), Vault references, dependency scanning (Dependabot, Renovate), SAST in CI.
- Documentation: OpenAPI/Swagger (`swagger`, `Swashbuckle.*`, `*.openapi.yaml`), ADRs (`docs/adr/`, `*.adr.md`), Storybook (`.storybook/`).
- Dependency management: lockfiles present (`package-lock.json`, `pnpm-lock.yaml`, `yarn.lock`, `Cargo.lock`, `Gemfile.lock`, `poetry.lock`) — pinned vs ranged.
- Testing strategy: presence of unit (`*.test.*`/`*Tests.cs`), integration (`*IntegrationTests*`/`tests/integration`), e2e (`cypress/`, `playwright/`, `e2e/`).

### 3. Phase 2 — Classify each finding

For every distinct technology/practice found, assign:

- **Quadrant** (exactly one):
  - `Languages & Frameworks` — programming languages, web frameworks, ORMs, UI libraries
  - `Tools` — dev tools, test frameworks, static analysis, build tools, CLIs
  - `Platforms` — infrastructure, CI/CD, cloud, databases, monitoring
  - `Techniques` — architecture patterns, practices, methodologies, conventions
- **Ring** (exactly one):
  - `Adopt` — referenced in 3+ critical files OR is the primary language/framework/platform; removing it breaks the system
  - `Trial` — referenced in 1–2 non-critical files OR recently introduced (CHANGELOG bumps, new manifest entries)
  - `Assess` — appears in commented-out code, experimental dirs, or TODO/FIXME comments
  - `Caution` — explicitly deprecated in comments/docs, known CVE in lockfile, conflicts with a newer pattern in the same repo, or duplicates an Adopt-ring alternative

Same-repo coexistence: if a legacy and a modern alternative both exist (e.g. CSS Modules + Tailwind, REST + GraphQL), list BOTH — one as `Caution` or `Assess`, the other as `Adopt`/`Trial`.

### 4. Phase 3 — Generate outputs

#### 4a. `tech_radar_[reponame].md` (repo root)

Use this exact structure. Substitute `[Repository Name]` with the basename from dynamic context; `[date]` with the `date +%Y-%m-%d` injection; `[repository URL]` with the `git remote get-url origin` injection (or "local repository" if `no-remote`).

```markdown
# Tech Radar — [Repository Name]

> Generated: [date]
> Repository: [repository URL]
> Summary: [2–3 sentence executive summary: what this codebase is and its technology profile.]

---

## Quadrant: Languages & Frameworks

### [Technology Name] · `Adopt`
- **Evidence**: [file(s) or pattern(s) found]
- **Version**: [version if determinable, otherwise "undetermined"]
- **Role**: [what this does in this project]
- **Classification rationale**: [1–2 sentences justifying the ring]

[repeat per blip]

---

## Quadrant: Tools

[same structure]

---

## Quadrant: Platforms

[same structure]

---

## Quadrant: Techniques

[same structure]

---

## Points of Attention

> Items classified as `Caution` with extended context.

### [Technology or Practice Name]
- **Problem**: [what is wrong or concerning]
- **Evidence**: [where it was found]
- **Recommendation**: [migrate, remove, replace, or document]

---

## Statistics

| Quadrant | Adopt | Trial | Assess | Caution | Total |
|---|---|---|---|---|---|
| Languages & Frameworks | N | N | N | N | N |
| Tools | N | N | N | N | N |
| Platforms | N | N | N | N | N |
| Techniques | N | N | N | N | N |
| **Total** | **N** | **N** | **N** | **N** | **N** |
```

If no `Caution` items exist, write `_No items in Caution ring._` under "Points of Attention" — do not omit the section.

#### 4b. `tech_radar_[reponame].csv` (repo root)

Exact format for https://radar.thoughtworks.com:

```csv
name,ring,quadrant,isNew,description
"Laravel","Adopt","Languages & Frameworks",TRUE,"Primary PHP framework. Found in composer.json and directory structure."
```

Rules — enforce strictly:
- Header line exactly: `name,ring,quadrant,isNew,description`
- `name`: concise, title case
- `ring`: exactly one of `Adopt`, `Trial`, `Assess`, `Caution`
- `quadrant`: exactly one of `Languages & Frameworks`, `Tools`, `Platforms`, `Techniques`
- `isNew`: always `TRUE` (unquoted)
- `description`: max 160 chars, one sentence stating what it is + key evidence
- All string values (name, ring, quadrant, description) wrapped in double quotes
- Escape any embedded `"` inside description as `""`
- No extra columns, no blank lines, no trailing newline beyond a single final LF, no BOM

### 5. Completion report

After both files are written, print exactly:

```
tech_radar_[reponame].md saved — [N] blips across 4 quadrants
tech_radar_[reponame].csv saved — ready for https://radar.thoughtworks.com
Points of Attention: [N] items in Caution ring
```

### 6. Generate HTML — `radar-html` CLI

1. Check if `radar-html` is available: `radar-html --version 2>/dev/null`.
   - If **exit code ≠ 0 or no output**: inform the user — `radar-html não instalado. Para instalar: npm install && npm run build:standalone && npm link (no diretório build-your-own-radar).` — then skip to end.
   - If **found**: inform the user — `radar-html v[version] instalado.`

2. Ask via `AskUserQuestion`:
   - Question: `Gerar tech_radar_[reponame].html agora?`
   - Options:
     - `Sim (Recomendado)` — executa `radar-html --clean` e gera o HTML no diretório raiz
     - `Não` — encerra aqui

3. If `Não`, stop.

4. If `Sim`, run:
   ```bash
   radar-html --clean "$(realpath "$0")/tech_radar_[reponame].csv" "$(realpath "$0")/tech_radar_[reponame].html"
   ```
   On success, print:
   ```
   tech_radar_[reponame].html gerado — abra no navegador.
   ```

## Critical Rules

- Every blip needs concrete file evidence. If you cannot cite a file or grep pattern, drop the blip.
- Do not include operating systems, hardware, or IDE preferences as blips.
- Do not duplicate a blip across quadrants — pick the best fit.
- If version is not determinable, write literally `undetermined` — never guess.
- Same `name` must not appear twice in the CSV.
- The CSV `description` field appears as a tooltip — make it self-contained.
- Do not write to anywhere outside `$0/tech_radar_[reponame].md`, `$0/tech_radar_[reponame].csv`, and `$0/tech_radar_[reponame].html`.
- Skip vendored directories during scanning: `node_modules/`, `vendor/`, `bin/`, `obj/`, `.git/`, `dist/`, `build/`, `target/`, `.next/`, `.nuxt/`.
- Step 6 (HTML rendering) is opt-in. Only runs if `radar-html` is installed and user confirms.
