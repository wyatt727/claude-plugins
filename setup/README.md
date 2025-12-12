# Setup Plugin for Claude Code

A project initialization wizard that creates optimized CLAUDE.md files following best practices from HumanLayer's research.

## Installation

### From Marketplace (Recommended)

```bash
# Add the marketplace (one-time)
/plugin marketplace add wyatt727/claude-plugins

# Install the plugin
/plugin install setup@wyatt727
```

Or browse interactively:
```bash
/plugin
# Select "Browse Plugins" → choose "setup"
```

### Manual Install

```bash
# Clone directly to plugins directory
git clone https://github.com/wyatt727/claude-plugins.git ~/.claude/plugins/wyatt727
```

### Local Development

```bash
# Clone anywhere and symlink
git clone https://github.com/wyatt727/claude-plugins.git ~/projects/claude-plugins
ln -s ~/projects/claude-plugins ~/.claude/plugins/wyatt727
```

After installation, restart Claude Code to load the plugin.

### Prerequisites (for MCP tools)

If you want MCP tools installed via `/setup`:

```bash
# Required
node --version  # v18+ required

# Optional (for Serena semantic code)
pip install uv  # provides uvx command

# Optional (for Exa web search)
export EXA_API_KEY='your-api-key'  # add to ~/.zshrc
```

## What It Does

The `/setup` command:

1. **Checks for existing CLAUDE.md** - Asks before overwriting
2. **Installs MCP tools** - Runs `install-mcps.sh` if needed (optional)
3. **Explores your codebase** - Uses Explore agent to understand project structure
4. **Gathers project info** - Asks clarifying questions about purpose and conventions
5. **Creates documentation structure** - Sets up `docs/tools/` with MCP usage guides
6. **Generates CLAUDE.md** - Creates an optimized file following best practices

## Usage

```bash
/setup              # Full interactive setup
/setup --skip-mcps  # Skip MCP tools installation
/setup --force      # Overwrite existing CLAUDE.md without asking
```

## What Gets Created

### CLAUDE.md

A lean, optimized project documentation file (target: under 60 lines):

- Tech stack overview
- Essential commands
- Project structure
- References to detailed docs

### docs/tools/ (if MCP tools installed)

MCP tool documentation for progressive disclosure:

```
docs/tools/
├── README.md              # When to use which tool
├── serena.md              # Semantic code navigation
├── context7.md            # Library documentation
├── exa.md                 # Web search and research
├── playwright.md          # Browser automation
└── sequential-thinking.md # Transparent reasoning
```

## Best Practices Applied

Based on [HumanLayer's research](https://www.humanlayer.dev/blog/writing-a-good-claude-md):

1. **Instruction Minimalism** - Under 300 lines, ideally under 60
2. **Progressive Disclosure** - Detailed docs in separate files
3. **Universal Applicability** - Only content relevant to all tasks
4. **File References** - Use `@docs/` instead of embedding content

## Plugin Structure

```
setup/
├── .claude-plugin/
│   └── plugin.json
├── bin/
│   └── install-mcps.sh        # MCP tools installer
├── commands/
│   └── setup.md               # /setup command
├── skills/
│   └── claude-md-best-practices/
│       ├── SKILL.md
│       └── references/
│           └── humanlayer-article.md
├── resources/
│   └── tool-docs/             # Pre-built MCP documentation
│       ├── README.md
│       ├── serena.md
│       ├── context7.md
│       ├── exa.md
│       ├── playwright.md
│       └── sequential-thinking.md
└── README.md
```

## Customization

After running `/setup`:

1. **Edit CLAUDE.md** - Add project-specific conventions
2. **Add to docs/** - Create additional documentation as needed

The generated files are starting points - customize for your project.
