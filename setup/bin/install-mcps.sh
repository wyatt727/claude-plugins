#!/bin/bash

# install-mcps.sh - Install MCP servers at PROJECT LEVEL for Claude Code
# Creates/updates .mcp.json at project root (version-controlled, team-shared)
# Usage: ./install-mcps.sh [--disable server1,server2] [--only server1,server2] [--force]

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
UNINSTALL_MODE=false
REMOVE_ALL_MODE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --disable)   DISABLE_SERVERS="$2"; shift 2 ;;
        --only)      ONLY_SERVERS="$2"; shift 2 ;;
        --force)     FORCE_REINSTALL=true; shift ;;
        --diagnose)  DIAGNOSE_MODE=true; shift ;;
        --uninstall) UNINSTALL_MODE=true; shift ;;
        --remove-all) REMOVE_ALL_MODE=true; shift ;;
        -h|--help)
            cat << 'EOF'
Usage: install-mcps.sh [OPTIONS]

Install MCP servers at PROJECT LEVEL (.mcp.json) for Claude Code.
This creates a version-controlled config that can be shared with your team.

Options:
  -h, --help                   Show this help
  --disable server1,server2    Skip specific servers
  --only server1,server2       Install only specific servers
  --force                      Overwrite existing .mcp.json
  --diagnose                   Check system dependencies
  --uninstall                  Remove servers from .mcp.json (use with --only to specify which)
  --remove-all                 Complete cleanup: remove .mcp.json and .claude/settings.json

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
  ./install-mcps.sh --uninstall --only exa,serena  # Remove specific servers
  ./install-mcps.sh --remove-all         # Complete cleanup
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

# Main
PROJECT_DIR="$(pwd)"
MCP_FILE="$PROJECT_DIR/.mcp.json"
SETTINGS_DIR="$PROJECT_DIR/.claude"
SETTINGS_FILE="$SETTINGS_DIR/settings.json"

# Handle --remove-all: complete cleanup
if [[ "$REMOVE_ALL_MODE" == true ]]; then
    log_info "Removing all MCP configuration from: $PROJECT_DIR"

    if [[ -f "$MCP_FILE" ]]; then
        rm "$MCP_FILE"
        log_success "Removed: .mcp.json"
    else
        log_info ".mcp.json not found"
    fi

    if [[ -f "$SETTINGS_FILE" ]]; then
        rm "$SETTINGS_FILE"
        log_success "Removed: .claude/settings.json"
        # Remove .claude dir if empty
        rmdir "$SETTINGS_DIR" 2>/dev/null && log_info "Removed empty .claude/ directory" || true
    else
        log_info ".claude/settings.json not found"
    fi

    # Remove Serena index if present
    if [[ -d "$PROJECT_DIR/.serena" ]]; then
        rm -rf "$PROJECT_DIR/.serena"
        log_success "Removed: .serena/ (Serena index)"
    fi

    echo ""
    log_success "Cleanup complete!"
    exit 0
fi

# Handle --uninstall: remove servers from .mcp.json
if [[ "$UNINSTALL_MODE" == true ]]; then
    log_info "Uninstalling MCP servers from: $PROJECT_DIR"

    if [[ ! -f "$MCP_FILE" ]]; then
        log_error ".mcp.json not found - nothing to uninstall"
        exit 1
    fi

    if ! command -v jq &> /dev/null; then
        log_error "jq is required for uninstall. Install with: brew install jq"
        exit 1
    fi

    # Determine which servers to remove
    if [[ -n "$ONLY_SERVERS" ]]; then
        # Remove only specified servers
        SERVERS_TO_REMOVE="$ONLY_SERVERS"
    else
        # Remove all our managed servers (default)
        SERVERS_TO_REMOVE="$SERVERS"
    fi

    # Remove each server
    REMOVED_COUNT=0
    for server in $(echo "$SERVERS_TO_REMOVE" | tr ',' ' '); do
        if jq -e ".mcpServers.\"$server\"" "$MCP_FILE" > /dev/null 2>&1; then
            jq "del(.mcpServers.\"$server\")" "$MCP_FILE" > "$MCP_FILE.tmp" && mv "$MCP_FILE.tmp" "$MCP_FILE"
            log_success "Removed: $server"
            ((REMOVED_COUNT++))
        else
            log_info "Server not found: $server"
        fi
    done

    # Update .claude/settings.json to remove enabled servers
    if [[ -f "$SETTINGS_FILE" ]]; then
        for server in $(echo "$SERVERS_TO_REMOVE" | tr ',' ' '); do
            if jq -e ".enabledMcpjsonServers | index(\"$server\")" "$SETTINGS_FILE" > /dev/null 2>&1; then
                jq ".enabledMcpjsonServers = (.enabledMcpjsonServers | map(select(. != \"$server\")))" "$SETTINGS_FILE" > "$SETTINGS_FILE.tmp" && mv "$SETTINGS_FILE.tmp" "$SETTINGS_FILE"
            fi
        done
        log_info "Updated .claude/settings.json"
    fi

    # Check if .mcp.json is now empty
    if [[ $(jq '.mcpServers | length' "$MCP_FILE") -eq 0 ]]; then
        log_warning ".mcp.json now has no servers. Consider using --remove-all to clean up completely."
    fi

    echo ""
    log_success "Uninstalled $REMOVED_COUNT server(s)"
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

# Generate .claude/settings.json to enable the MCP servers
log_info "Generating .claude/settings.json..."
mkdir -p "$SETTINGS_DIR"

# Build list of installed servers
INSTALLED_SERVERS=()
for server in $SERVERS; do
    if should_install "$server"; then
        if [[ "$server" == "serena" ]] && ! command -v uvx &> /dev/null; then
            continue
        elif [[ "$server" == "exa" ]] && [[ -z "$EXA_API_KEY" ]]; then
            continue
        fi
        INSTALLED_SERVERS+=("$server")
    fi
done

# Create settings.json with enabledMcpjsonServers
if [[ ${#INSTALLED_SERVERS[@]} -gt 0 ]]; then
    # Build JSON array of server names
    JSON_ARRAY=$(printf '"%s",' "${INSTALLED_SERVERS[@]}")
    JSON_ARRAY="[${JSON_ARRAY%,}]"  # Remove trailing comma and wrap in brackets

    if [[ -f "$SETTINGS_FILE" ]] && command -v jq &> /dev/null; then
        # Merge with existing settings.json
        jq --argjson servers "$JSON_ARRAY" '.enabledMcpjsonServers = $servers' "$SETTINGS_FILE" > "$SETTINGS_FILE.tmp" && mv "$SETTINGS_FILE.tmp" "$SETTINGS_FILE"
        log_success "Updated: .claude/settings.json (merged with existing)"
    else
        # Create new settings.json
        cat > "$SETTINGS_FILE" << EOF
{
  "enabledMcpjsonServers": $JSON_ARRAY
}
EOF
        log_success "Created: .claude/settings.json"
    fi
fi

echo ""
echo "===================================="
log_success "MCP Configuration Complete!"
echo "===================================="
echo ""
log_info "Created: .mcp.json"
log_info "Created: .claude/settings.json"
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
