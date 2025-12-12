# Playwright MCP - Browser Automation

## Purpose

Browser automation for external web interaction - scraping, form filling, E2E testing, multi-step workflows.

Uses Playwright's **accessibility tree** (not screenshots) - fast, lightweight, no vision models needed.

Discover available tools: run `/mcp` in Claude Code → navigate to playwright.

## When to Use

**Use for:**
- Web scraping from live websites
- Automated form filling
- E2E test generation
- Multi-step web workflows
- Security testing/reconnaissance

**Don't use for:**
- Reading your own codebase (use Read/Serena)
- Static web searches (use Exa)
- Library documentation (use Context7)
- Simple HTTP API calls (use curl/fetch)

## Core Workflow

```
# 1. Navigate
browser_navigate(url="https://example.com")

# 2. ALWAYS snapshot first (accessibility tree)
browser_snapshot()

# 3. Interact using refs from snapshot
browser_click(element="Login button", ref="a1b2c3")

# 4. Type into fields
browser_type(element="Email input", ref="d4e5f6", text="user@example.com")
```

**Key rule**: Always `browser_snapshot()` before interacting. Refs come from the snapshot.

## Key Tools

| Tool | Purpose |
|------|---------|
| `browser_navigate` | Go to URL |
| `browser_snapshot` | Get accessibility tree (**use first**) |
| `browser_click` | Click elements (supports `doubleClick`, `button`, `modifiers`) |
| `browser_type` | Type into fields |
| `browser_fill` | Fill input fields |
| `browser_select` | Choose dropdown options |
| `browser_hover` | Hover over elements |
| `browser_drag` | Drag between elements |
| `browser_press_key` | Keyboard input (Enter, Arrow keys, etc.) |
| `browser_evaluate` | Execute JavaScript |
| `browser_screenshot` | Visual capture |
| `browser_console_logs` | Get console output (filter by type) |
| `browser_go_back/forward` | Browser history navigation |
| `browser_close` | Clean up session |

## Command-Line Options

| Option | Purpose |
|--------|---------|
| `--browser <type>` | chrome, firefox, webkit, msedge |
| `--headless` | Run without visible window |
| `--device <name>` | Device emulation ("iPhone 15", "iPad Pro") |
| `--viewport-size <WxH>` | Dimensions (e.g., "1280x720") |
| `--user-data-dir <path>` | Persist profile/cookies |
| `--isolated` | In-memory profile (no persistence) |
| `--storage-state <file>` | Load cookies/auth from file |
| `--proxy-server <url>` | HTTP/SOCKS proxy |
| `--ignore-https-errors` | Skip HTTPS validation |

## Profile Persistence

**Default**: Sessions persist in platform-specific directories:
- macOS: `~/Library/Caches/ms-playwright/mcp-{browser}-profile`
- Linux: `~/.cache/ms-playwright/mcp-{browser}-profile`

**Isolated mode** (`--isolated`): In-memory, resets on close. Good for testing.

## Authentication Workflow

For sites requiring login:

1. Run in headed mode (default, no `--headless`)
2. Navigate to login page
3. **Log in manually** in the visible browser window
4. Cookies persist for the session (or use `--storage-state` to save)

## Chrome Debug Session (Alternative)

Connect to an existing Chrome instance instead of launching new:

```bash
# Check if debug session is running
curl -s http://localhost:9222/json/version && echo "ACTIVE" || echo "Not running"

# Launch Chrome with debug port (if needed)
/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome \
  --remote-debugging-port=9222 \
  --user-data-dir=/tmp/chrome-debug &
```

Benefits: Reuse existing logins, see actions in real-time, manual CAPTCHA/2FA handling.

## Best Practices

1. **Snapshot before interacting** - Never click/type without a snapshot first
2. **Let Claude pick tools** - Don't specify exact tool names in prompts
3. **Use `--storage-state`** - Avoid repeated logins for authenticated sites
4. **Headed mode for debugging** - See what's happening in real-time
5. **Close when done** - `browser_close()` to release resources

## Anti-Patterns

```
# BAD: Interact without snapshot
browser_navigate(...) → browser_click(...)  # No refs!

# GOOD: Snapshot first
browser_navigate(...) → browser_snapshot() → browser_click(ref="...")

# BAD: Screenshot for understanding
browser_screenshot()  # Wastes vision model

# GOOD: Snapshot for understanding
browser_snapshot()  # Structured accessibility tree
```

## Sources

- [Microsoft Playwright MCP](https://github.com/microsoft/playwright-mcp)
- [Using Playwright MCP with Claude Code](https://til.simonwillison.net/claude-code/playwright-mcp-claude-code)
