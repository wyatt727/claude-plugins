# Claude Plugins

Personal workspace for developing and testing Claude Code plugins.

## Tech Stack

- Bash (scripts)
- Markdown (commands, skills, documentation)
- YAML/JSON (plugin manifests, configuration)

## Project Structure

```
setup/                  # Main setup plugin
  bin/                  # Shell scripts (install-mcps.sh)
  commands/             # Slash command definitions
  skills/               # Skill definitions
  resources/            # Static resources (tool docs)
docs/tools/             # MCP tool usage guides
.claude-plugin/         # Marketplace metadata
```

## Commands

```bash
# Test a plugin locally
claude --plugin ./setup

# Run the setup command
/setup
```

## MCP Tools

Consult @docs/tools/README.md for MCP tool usage guides.

Available tools: serena, playwright, context7, exa, sequential-thinking, server-memory

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
