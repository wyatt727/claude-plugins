---
name: CLAUDE.md Best Practices
description: This skill should be used when the user asks to "create a CLAUDE.md", "write a CLAUDE.md", "set up CLAUDE.md", "improve CLAUDE.md", "optimize CLAUDE.md", or mentions project onboarding, agent instructions, or codebase documentation for Claude Code. Provides guidance based on HumanLayer's research on effective CLAUDE.md files.
version: 1.0.0
---

# CLAUDE.md Best Practices

## Core Principle

LLMs operate as stateless functions—they don't learn over time and only know what's explicitly provided via tokens. Since CLAUDE.md appears in every conversation with Claude Code, it's the primary mechanism for onboarding agents into a codebase.

## Three Critical Implications

1. Agents begin each session with zero codebase knowledge
2. Essential information must be communicated each session
3. CLAUDE.md is the delivery method

## Essential Content Areas: WHAT, WHY, HOW

Structure CLAUDE.md around three core areas:

### WHAT - Technical Stack & Structure
- Programming languages and frameworks
- Project structure and architecture
- Monorepo organization (if applicable)
- Key directories and their purposes

### WHY - Project Purpose
- What the project does
- Functional role of different components
- Business context (if relevant)

### HOW - Workflow Details
- Package manager (bun, npm, yarn, pnpm)
- Build commands
- Test commands
- Verification methods
- Linting/formatting commands

## Critical Constraints

### Instruction Minimalism

Research shows frontier LLMs reliably follow approximately 150-200 instructions. Claude Code's system prompt already contains ~50 instructions, consuming roughly one-third of available capacity. Include only universally applicable instructions.

### File Length Targets

- **Target**: Fewer than 300 lines
- **Ideal**: Under 60 lines (like HumanLayer's)
- Only include universally applicable content
- Avoid task-specific guidance

### Claude May Ignore CLAUDE.md

Anthropic injects a system reminder stating the context "may or may not be relevant." Claude deprioritizes information deemed irrelevant to current tasks. Make everything universally applicable.

## Progressive Disclosure Strategy

Store detailed documentation in separate files:

```
docs/
├── tools/              # MCP tool usage guides
│   ├── README.md       # When to use which tool
│   ├── serena.md       # Semantic code navigation
│   ├── context7.md     # Library documentation
│   ├── exa.md          # Web search
│   └── playwright.md   # Browser automation
├── architecture.md     # System architecture (if needed)
└── conventions.md      # Code style (if needed)
```

Reference these in CLAUDE.md with @file pointers. Don't duplicate content - just point to the source.

### Why File References Beat Code Snippets

- Source files are authoritative
- Updates happen in one place
- CLAUDE.md stays lean
- Claude can read current content

## Never Use CLAUDE.md as a Linter

LLMs are expensive and slow compared to deterministic linters. Delegate style enforcement to tools:

- **Code style**: ESLint, Prettier, Biome, Black, etc.
- **Type checking**: TypeScript, mypy, etc.
- **Pre-commit hooks**: Husky, pre-commit

Use Claude Code hooks or slash commands to handle formatting separately from implementation.

## Avoid Auto-Generation

The `/init` feature and auto-generation tools produce suboptimal results. CLAUDE.md is the highest-leverage configuration point—every line deserves deliberate consideration.

## CLAUDE.md Template

```markdown
# Project Name

Brief description of what this project does.

## Tech Stack

- Language: [detected from codebase]
- Framework: [detected from codebase]
- Package Manager: [detected from codebase]

## Commands

[Include commands that exist in the project. Common ones:]
- Install dependencies
- Run dev server
- Run tests
- Build
- Lint/format

[For new projects, add commands as they're established]

## Project Structure

```
[key directories detected from codebase with 1-line descriptions]
```

## MCP Tools

Consult these files for MCP server usage:
- @docs/tools/README.md - When to use which MCP tool
- @docs/tools/serena.md - Semantic code navigation (large codebases)
- @docs/tools/context7.md - Library documentation lookup
- @docs/tools/exa.md - Web search and research
- @docs/tools/playwright.md - Browser automation (debug session setup)
- @docs/tools/sequential-thinking.md - Transparent reasoning (vs built-in extended thinking)

Also available (no docs needed):
- **server-memory** - Persistent memory across sessions
```

**Important**: Detect actual values from the codebase. If information isn't known yet, skip the section or leave it blank. Never hardcode example values like "pnpm" or "Next.js".

## Information Gathering Process

When creating CLAUDE.md for a project:

1. **Explore the codebase** - Use Explore agents to understand structure
2. **Identify tech stack** - Look for package.json, requirements.txt, Cargo.toml, etc.
3. **Find existing commands** - Check scripts in package.json, Makefile, etc.
4. **Ask clarifying questions** about:
   - Project purpose and goals
   - Team conventions
   - Key workflows
   - Important architectural decisions
5. **Keep it minimal** - Only include universally applicable information

## Additional Resources

For detailed guidance on CLAUDE.md best practices, consult:
- **`references/humanlayer-article.md`** - Full HumanLayer research article
