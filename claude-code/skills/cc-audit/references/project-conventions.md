# Project Conventions

Local conventions for this project's `.claude/` artifacts. Extends — does not replace — Anthropic's canonical Claude Code documentation.

## No emojis or decorative icons

Don't use emojis or decorative icons in any skill artifact: SKILL.md frontmatter and body, templates, reference files, prescribed output formats.

Use plain text labels (`**Critical**`, `**Warning**`, `**Suggestion**`) or bracketed tags (`[CRITICAL]`) instead of colored circles, checkmarks, crosses, or other Unicode pictographs.

**Scope:** applies to severity markers, status indicators, headings, list bullets, and callouts authored by the project.

**Exception:** code blocks and verbatim-quoted content from external sources (Anthropic docs fetched into `references/`, upstream changelogs, third-party tool output) are unaffected.

**How audits cite it:** `project-conventions.md` §"No emojis or decorative icons".
