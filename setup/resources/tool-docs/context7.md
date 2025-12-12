# Context7 MCP - Library Documentation

## Purpose

Prevents API hallucinations by providing up-to-date, version-specific library documentation directly in your prompts.

## Quick Usage

Just add "use context7" to any prompt:

```
Create a Next.js middleware that checks for JWT in cookies. use context7

How do I use React Query mutations? use context7
```

Context7 automatically resolves library IDs and fetches current docs.

## Tools

| Tool | Purpose |
|------|---------|
| `resolve-library-id` | Convert library name → Context7 ID (**call first**) |
| `get-library-docs` | Fetch documentation for a library |

## Workflow

```
# Step 1: Resolve library name to Context7 ID (REQUIRED)
resolve-library-id(libraryName="react query")
# Returns: /tanstack/query

# Step 2: Fetch documentation
get-library-docs(
    context7CompatibleLibraryID="/tanstack/query",
    topic="mutations",       # Optional: focus area
    tokens=5000              # Optional: limit response size
)
```

**Skip Step 1** if you already have the exact ID format like `/vercel/next.js`

## When to Use

**Use for:**
- Library API documentation
- Version-specific features
- Setup/configuration steps
- Avoiding hallucinated methods

**Don't use for:**
- Internal codebase understanding (use Serena)
- Real-world usage examples (use Exa)
- General web search (use Exa)

## Parameters for get-library-docs

| Parameter | Required | Description |
|-----------|----------|-------------|
| `context7CompatibleLibraryID` | Yes | From resolve-library-id |
| `topic` | No | Focus on specific topic (e.g., "hooks", "routing") |
| `tokens` | No | Limit response size (default varies) |

## Handling Large Responses

If responses are too large:

1. Add a `topic` to narrow focus
2. Reduce `tokens` parameter
3. Be more specific in your query

```
# Too broad
topic="routing"

# Better
topic="app router navigation"

# Best
topic="useRouter hook"
```

## Auto-Invocation (Optional)

Add this to your CLAUDE.md to auto-invoke Context7 for library questions:

```
When I need library documentation, API references, or setup steps,
automatically use Context7 MCP tools (resolve-library-id → get-library-docs).
```

## Sources

- [GitHub - upstash/context7](https://github.com/upstash/context7)
- [Context7 MCP Guide](https://claudelog.com/claude-code-mcps/context7-mcp/)
