# claude-plugins

A Claude Code plugin marketplace containing plugins for extending Claude Code functionality.

## Tech Stack

- Language: Bash, Markdown
- Configuration: JSON (plugin manifests)

## Project Structure

```
.claude-plugin/           # Marketplace configuration
setup/                    # Main plugin (project setup wizard)
  bin/                    # Executable scripts
  commands/               # Slash command definitions
  skills/                 # Skill definitions
  resources/              # Static resources (tool docs)
```

## MCP Tools

Consult these files for MCP server usage:
- @docs/tools/README.md - When to use which MCP tool
- @docs/tools/serena.md - Semantic code navigation
- @docs/tools/context7.md - Library documentation lookup
- @docs/tools/exa.md - Web search and research
- @docs/tools/playwright.md - Browser automation
- @docs/tools/sequential-thinking.md - Transparent reasoning

Also available: **server-memory** - Persistent memory across sessions

## File Headers

Every file MUST have a header comment with:
- What: Brief description of this file's purpose
- Why/How: Key responsibilities (2-3 bullets)
- Related files: Paths to files it interacts with

## Parallelization

Prioritize agent swarms for parallel execution:
- Multi-file changes: spawn agents per file
- Research + implementation: parallel agents
- Tests + code: write simultaneously
