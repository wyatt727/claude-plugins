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
/setup --uninstall  # Uninstall MCP tools (interactive)
```

### Installing MCP Tools

The installer creates two files:
- `.mcp.json` - Server configurations (version-controlled, share with team)
- `.claude/settings.json` - Enables the servers for Claude Code

#### Direct Script Usage

```bash
# Install all servers
./bin/install-mcps.sh

# Install specific servers only
./bin/install-mcps.sh --only exa,context7

# Skip specific servers
./bin/install-mcps.sh --disable serena

# Overwrite existing config
./bin/install-mcps.sh --force

# Check dependencies first
./bin/install-mcps.sh --diagnose
```

#### Verifying Install

After installing, verify with:

```bash
# Check .mcp.json was created with servers
cat .mcp.json | jq '.mcpServers | keys'

# Check servers are enabled in settings
cat .claude/settings.json | jq '.enabledMcpjsonServers'

# Check what Claude sees (requires restart)
claude mcp list
```

**Important**: Restart Claude Code after installing for servers to load.

### Uninstalling MCP Tools

The `--uninstall` flag provides interactive options for removing MCP servers:

```bash
/setup --uninstall
```

You'll be asked what to uninstall:
- **Remove specific MCP servers** - Choose which servers to remove
- **Remove all MCP servers** - Removes all managed servers but keeps config files
- **Complete cleanup** - Removes `.mcp.json`, `.claude/settings.json`, and `.serena/`

#### Direct Script Usage

You can also run the install script directly for more control:

```bash
# Remove specific servers
./bin/install-mcps.sh --uninstall --only exa,serena

# Remove all managed servers (keeps config file structure)
./bin/install-mcps.sh --uninstall

# Complete cleanup (removes all config files)
./bin/install-mcps.sh --remove-all
```

#### Verifying Uninstall

After uninstalling, verify with:

```bash
# Check remaining servers in .mcp.json
cat .mcp.json

# Check enabled servers in settings
cat .claude/settings.json

# Check what Claude sees (requires restart)
claude mcp list
```

**Important**: Restart Claude Code after uninstalling for changes to take effect.

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
