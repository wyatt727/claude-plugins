# Exa MCP - Web Research & Code Search

## Purpose

Exa provides **specialized** search capabilities beyond Claude's built-in WebSearch: semantic web search, academic papers, code examples, company research, and LinkedIn.

## Use in Parallel with Built-in WebSearch

**Run both tools in parallel** for comprehensive research:
- **WebSearch** (built-in): Fast, general web queries
- **Exa**: Specialized searches (code, papers, companies, competitors)

For research tasks, invoke both simultaneously and combine results.

## Available Tools

| Tool | Purpose | Default |
|------|---------|---------|
| `web_search_exa` | Semantic web search with content extraction | ✅ |
| `get_code_context_exa` | Code snippets, examples, API patterns from GitHub/docs | ✅ |
| `deep_search_exa` | Query expansion with high-quality summaries | ❌ |
| `research_paper_search` | Search 100M+ academic papers | ❌ |
| `github_search` | Find GitHub repositories | ❌ |
| `company_research` | Crawl company websites | ❌ |
| `competitor_finder` | Find competing companies | ❌ |
| `crawling` | Extract content from specific URLs | ❌ |
| `linkedin_search` | Search LinkedIn company pages | ❌ |
| `wikipedia_search_exa` | Search Wikipedia | ❌ |

Note: Only `web_search_exa` and `get_code_context_exa` are enabled by default.

## When to Use Exa vs Built-in WebSearch

| Use Case | Tool |
|----------|------|
| Quick general web query | WebSearch (built-in) |
| Code examples & API patterns | `get_code_context_exa` |
| Academic/research papers | `research_paper_search` |
| Company analysis | `company_research` |
| Finding competitors | `competitor_finder` |
| Semantic search with summaries | `deep_search_exa` |
| Extract specific URL content | `crawling` |

## Common Usage Patterns

```python
# Code search (best for finding examples)
mcp__exa__get_code_context_exa(
    query="python async rate limiter implementation",
    numResults=5
)

# Web search with content
mcp__exa__web_search_exa(
    query="LLM prompt engineering 2025",
    numResults=5
)

# Deep search with summaries
mcp__exa__deep_search_exa(
    query="kubernetes security best practices",
    numResults=5
)

# Research papers
mcp__exa__research_paper_search(
    query="transformer architecture attention",
    numResults=5,
    maxCharacters=3000
)

# Company research
mcp__exa__company_research(
    query="anthropic.com",
    subpageTarget=["about", "research"],
    subpages=10
)

# Extract URL content
mcp__exa__crawling(url="https://example.com/article")
```

## Handling Errors

**"Too Many Characters" errors:**
1. Reduce `numResults` (try 3-5)
2. Reduce `maxCharacters` for research papers
3. Use narrower, more specific queries
4. Reduce `subpages` for company research

**Rate limits:** Exa has API rate limits. Check your plan if you hit limits.

## Don't Use Exa For

- Internal codebase search → use **Serena**
- Official library documentation → use **Context7**
- Pattern matching in your files → use **Grep**

## Sources

- [Exa MCP Documentation](https://docs.exa.ai/reference/exa-mcp)
- [Exa MCP Server GitHub](https://github.com/exa-labs/exa-mcp-server)
- [Integrating MCP Servers for Web Search](https://intuitionlabs.ai/articles/mcp-servers-claude-code-internet-search)
