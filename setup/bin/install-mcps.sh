#!/bin/bash

# install-mcps.sh - Install MCP servers at PROJECT LEVEL for Claude Code
# Creates:
#   - .mcp.json (MCP server configs, version-controlled, team-shared)
#   - .claude/settings.json (auto-approves project MCP servers)
# Usage: ./install-mcps.sh [--disable server1,server2] [--only server1,server2] [--force]
# Uninstall: Use `/setup --uninstall` for smart surgical removal

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $1"; }

# Available MCP servers
SERVERS="exa sequential-thinking serena playwright context7 server-memory"

# Parse arguments
DISABLE_SERVERS=""
ONLY_SERVERS=""
FORCE_REINSTALL=false
DIAGNOSE_MODE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --disable)   DISABLE_SERVERS="$2"; shift 2 ;;
        --only)      ONLY_SERVERS="$2"; shift 2 ;;
        --force)     FORCE_REINSTALL=true; shift ;;
        --diagnose)  DIAGNOSE_MODE=true; shift ;;
        -h|--help)
            cat << 'EOF'
Usage: install-mcps.sh [OPTIONS]

Install MCP servers at PROJECT LEVEL for Claude Code.
Creates .mcp.json (version-controlled, team-shared) and
.claude/settings.json (auto-approves project MCP servers).

Options:
  -h, --help                   Show this help
  --disable server1,server2    Skip specific servers
  --only server1,server2       Install only specific servers
  --force                      Overwrite existing .mcp.json
  --diagnose                   Check system dependencies

Uninstall:
  Use `/setup --uninstall` for smart surgical removal that preserves user content.

Available servers:
  exa                 Web search, research, company info
  sequential-thinking Step-by-step problem solving for complex tasks
  serena              Semantic code retrieval and editing
  playwright          Browser automation (with debug session support)
  context7            Up-to-date library documentation
  server-memory       Persistent memory across sessions

Examples:
  ./install-mcps.sh                      # Install all servers
  ./install-mcps.sh --only exa,context7  # Install specific servers
  ./install-mcps.sh --disable serena     # Skip serena
  ./install-mcps.sh --force              # Overwrite existing config
  ./install-mcps.sh --uninstall          # Remove all MCP configs
EOF
            exit 0
            ;;
        *) log_error "Unknown option: $1"; exit 1 ;;
    esac
done

# Check if server should be installed
should_install() {
    local server="$1"
    if [[ -n "$ONLY_SERVERS" ]]; then
        [[ ",$ONLY_SERVERS," == *",$server,"* ]] && return 0 || return 1
    fi
    if [[ -n "$DISABLE_SERVERS" ]]; then
        [[ ",$DISABLE_SERVERS," == *",$server,"* ]] && return 1 || return 0
    fi
    return 0
}

# Run diagnostics
diagnose() {
    log_info "Checking dependencies..."

    if command -v node &> /dev/null; then
        log_success "Node.js: $(node --version)"
    else
        log_error "Node.js not installed"
        exit 1
    fi

    if command -v npx &> /dev/null; then
        log_success "npx: $(npx --version 2>/dev/null || echo 'available')"
    else
        log_error "npx not found"
        exit 1
    fi

    if command -v uvx &> /dev/null; then
        log_success "uvx: available (for serena)"
    else
        log_warning "uvx not found - serena will be skipped. Install with: pip install uv"
    fi

    if command -v jq &> /dev/null; then
        log_success "jq: available"
    else
        log_warning "jq not found - will use basic JSON generation"
    fi

    # Check API keys
    if [[ -n "$EXA_API_KEY" ]]; then
        log_success "EXA_API_KEY: set (${EXA_API_KEY:0:8}...)"
    else
        log_warning "EXA_API_KEY: not set (exa will be skipped)"
    fi

    echo ""
}

# Uninstall MCP configuration
uninstall() {
    local PROJECT_DIR="$(pwd)"
    local removed_count=0

    echo ""
    log_info "Uninstalling MCP configuration from: $PROJECT_DIR"
    log_warning "This performs FULL removal of files created by install-mcps.sh"
    log_info "For surgical removal (preserving user content), use: /setup --uninstall"
    echo ""

    # Remove .mcp.json
    if [[ -f "$PROJECT_DIR/.mcp.json" ]]; then
        rm "$PROJECT_DIR/.mcp.json"
        log_success "Removed: .mcp.json"
        ((removed_count++))
    else
        log_info "Skipped: .mcp.json (not found)"
    fi

    # Remove .claude/settings.json
    if [[ -f "$PROJECT_DIR/.claude/settings.json" ]]; then
        rm "$PROJECT_DIR/.claude/settings.json"
        log_success "Removed: .claude/settings.json"
        ((removed_count++))

        # Remove .claude/ directory if empty
        if [[ -d "$PROJECT_DIR/.claude" ]] && [[ -z "$(ls -A "$PROJECT_DIR/.claude")" ]]; then
            rmdir "$PROJECT_DIR/.claude"
            log_success "Removed: .claude/ (empty directory)"
        fi
    else
        log_info "Skipped: .claude/settings.json (not found)"
    fi

    # Remove .serena/ directory (created by serena indexing)
    if [[ -d "$PROJECT_DIR/.serena" ]]; then
        rm -rf "$PROJECT_DIR/.serena"
        log_success "Removed: .serena/ (serena index)"
        ((removed_count++))
    else
        log_info "Skipped: .serena/ (not found)"
    fi

    echo ""
    echo "===================================="
    if [[ $removed_count -gt 0 ]]; then
        log_success "Uninstall Complete! Removed $removed_count item(s)."
    else
        log_info "Nothing to uninstall."
    fi
    echo "===================================="
    echo ""
    log_info "Restart Claude Code to apply changes."
    echo ""
}

# Main
PROJECT_DIR="$(pwd)"
MCP_FILE="$PROJECT_DIR/.mcp.json"

# Handle uninstall mode
if [[ "$UNINSTALL_MODE" == true ]]; then
    uninstall
    exit 0
fi

log_info "Installing MCP servers for: $PROJECT_DIR"
log_info "Config file: .mcp.json (project-level, version-controlled)"
echo ""

# Run diagnostics if requested
if [[ "$DIAGNOSE_MODE" == true ]]; then
    diagnose
fi

# Check for existing config
if [[ -f "$MCP_FILE" ]] && [[ "$FORCE_REINSTALL" != true ]]; then
    log_warning ".mcp.json already exists. Use --force to overwrite."
    log_info "Current servers configured:"
    if command -v jq &> /dev/null; then
        jq -r '.mcpServers | keys[]' "$MCP_FILE" 2>/dev/null | while read server; do
            echo "  - $server"
        done
    else
        grep -o '"[^"]*":' "$MCP_FILE" | head -20 | tr -d '":' | while read server; do
            echo "  - $server"
        done
    fi
    exit 0
fi

# Install Playwright browsers if playwright is being installed
if should_install "playwright"; then
    log_info "Installing Playwright browsers (for browser automation)..."
    npx playwright install chromium > /dev/null 2>&1 || log_warning "Could not install Chromium"
fi

# Index project with Serena if being installed
if should_install "serena" && command -v uvx &> /dev/null; then
    log_info "Indexing project with Serena..."
    uvx --from git+https://github.com/oraios/serena serena project index 2>/dev/null || log_warning "Serena indexing failed"
fi

# Build the .mcp.json configuration
log_info "Generating .mcp.json..."

# Start building JSON
cat > "$MCP_FILE" << 'HEADER'
{
  "mcpServers": {
HEADER

FIRST=true

# Exa - Web search and research
if should_install "exa"; then
    if [[ -z "$EXA_API_KEY" ]]; then
        log_warning "Skipped: exa (EXA_API_KEY not set in environment)"
        log_info "  Set it with: export EXA_API_KEY='your-api-key'"
        log_info "  Or add to ~/.zshrc for persistence"
    else
        [[ "$FIRST" != true ]] && echo "," >> "$MCP_FILE"
        FIRST=false
        cat >> "$MCP_FILE" << 'EOF'
    "exa": {
      "command": "npx",
      "args": [
        "-y",
        "exa-mcp-server",
        "--tools=web_search_exa,research_paper_search,company_research,crawling,competitor_finder,linkedin_search,wikipedia_search_exa,github_search"
      ],
      "env": {
        "EXA_API_KEY": "${EXA_API_KEY}"
      }
    }
EOF
        log_success "Added: exa (web search, research)"
        log_info "  Using EXA_API_KEY from environment"
    fi
fi

# Sequential Thinking - Step-by-step problem solving
if should_install "sequential-thinking"; then
    [[ "$FIRST" != true ]] && echo "," >> "$MCP_FILE"
    FIRST=false
    cat >> "$MCP_FILE" << 'EOF'
    "sequential-thinking": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"]
    }
EOF
    log_success "Added: sequential-thinking"
fi

# Serena - Semantic code retrieval
if should_install "serena"; then
    if command -v uvx &> /dev/null; then
        [[ "$FIRST" != true ]] && echo "," >> "$MCP_FILE"
        FIRST=false
        cat >> "$MCP_FILE" << EOF
    "serena": {
      "command": "uvx",
      "args": [
        "--from", "git+https://github.com/oraios/serena",
        "serena", "start-mcp-server",
        "--context", "ide-assistant",
        "--project", "."
      ]
    }
EOF
        log_success "Added: serena (semantic code)"
    else
        log_warning "Skipped: serena (uvx not installed)"
    fi
fi

# Playwright - Browser automation with debug session support
if should_install "playwright"; then
    [[ "$FIRST" != true ]] && echo "," >> "$MCP_FILE"
    FIRST=false
    cat >> "$MCP_FILE" << 'EOF'
    "playwright": {
      "command": "npx",
      "args": ["-y", "@playwright/mcp@latest"],
      "env": {
        "PLAYWRIGHT_HEADLESS": "false",
        "PLAYWRIGHT_CONNECT_OVER_CDP": "true",
        "CDP_ENDPOINT": "http://localhost:9222"
      }
    }
EOF
    log_success "Added: playwright (browser automation)"
    log_info "  Playwright configured for Chrome debug sessions on port 9222"
    log_info "  Start Chrome with: chrome --remote-debugging-port=9222"
fi

# Context7 - Library documentation
if should_install "context7"; then
    [[ "$FIRST" != true ]] && echo "," >> "$MCP_FILE"
    FIRST=false
    cat >> "$MCP_FILE" << 'EOF'
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp@latest"]
    }
EOF
    log_success "Added: context7 (library docs)"
fi

# Server Memory - Persistent memory
if should_install "server-memory"; then
    [[ "$FIRST" != true ]] && echo "," >> "$MCP_FILE"
    FIRST=false
    cat >> "$MCP_FILE" << 'EOF'
    "server-memory": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory"]
    }
EOF
    log_success "Added: server-memory"
fi

# Close JSON
cat >> "$MCP_FILE" << 'FOOTER'
  }
}
FOOTER

# Create .claude/settings.json to auto-approve project MCP servers
SETTINGS_DIR="$PROJECT_DIR/.claude"
SETTINGS_FILE="$SETTINGS_DIR/settings.json"

if [[ ! -d "$SETTINGS_DIR" ]]; then
    mkdir -p "$SETTINGS_DIR"
    log_info "Created: .claude/"
fi

if [[ ! -f "$SETTINGS_FILE" ]]; then
    cat > "$SETTINGS_FILE" << 'SETTINGS'
{
  "enableAllProjectMcpServers": true
}
SETTINGS
    log_success "Created: .claude/settings.json (auto-approves MCP servers)"
else
    # Check if enableAllProjectMcpServers is already set
    if ! grep -q "enableAllProjectMcpServers" "$SETTINGS_FILE" 2>/dev/null; then
        log_warning ".claude/settings.json exists but missing enableAllProjectMcpServers"
        log_info "  Add manually: \"enableAllProjectMcpServers\": true"
    else
        log_info ".claude/settings.json already configured"
    fi
fi

echo ""
echo "===================================="
log_success "MCP Configuration Complete!"
echo "===================================="
echo ""
log_info "Created files:"
echo "  - .mcp.json (MCP server configs)"
echo "  - .claude/settings.json (auto-approval)"
echo ""

# Show summary
log_info "Configured servers:"
for server in $SERVERS; do
    if should_install "$server"; then
        if [[ "$server" == "serena" ]] && ! command -v uvx &> /dev/null; then
            echo -e "  ${YELLOW}✗${NC} $server (skipped - uvx not installed)"
        elif [[ "$server" == "exa" ]] && [[ -z "$EXA_API_KEY" ]]; then
            echo -e "  ${YELLOW}✗${NC} $server (skipped - EXA_API_KEY not set)"
        else
            echo -e "  ${GREEN}✓${NC} $server"
        fi
    else
        echo -e "  ${YELLOW}✗${NC} $server (disabled)"
    fi
done

echo ""
log_info "Next steps:"

# Only show API key instructions if not set
if [[ -z "$EXA_API_KEY" ]]; then
    echo "  1. Set EXA_API_KEY in your environment (add to ~/.zshrc):"
    echo "     export EXA_API_KEY='your-api-key'"
    echo "     Then re-run this script with --force"
    echo ""
fi

echo "  - For Playwright browser debugging, start Chrome with:"
echo "    chrome --remote-debugging-port=9222"
echo "    (Playwright will connect to existing session instead of launching new browser)"
echo ""
echo "  - Restart Claude Code to load the new MCP servers"
echo ""
echo "  - Optionally commit .mcp.json to share with your team:"
echo "    git add .mcp.json && git commit -m 'Add MCP server config'"
