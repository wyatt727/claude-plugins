# MCP Tool Usage Guide

Quick reference for when to use which MCP tool.

## Which Tool When?

| Need | Tool | Guide |
|------|------|-------|
| Understand code structure | Serena | [serena.md](serena.md) |
| Library documentation | Context7 | [context7.md](context7.md) |
| Web research & code examples | Exa | [exa.md](exa.md) |
| Browser automation | Playwright | [playwright.md](playwright.md) |
| Visible step-by-step reasoning | Sequential Thinking | [sequential-thinking.md](sequential-thinking.md) |

**Built-in tools** (no guide needed): Grep, Glob, Read, Edit, WebSearch

## Decision Tree

```
Need to find something?
├── Text in YOUR codebase → Grep/Glob (built-in)
├── Code structure/symbols → Serena
├── Library API docs → Context7
├── Web articles/research → Exa + WebSearch (parallel)
└── Live website interaction → Playwright

Need reasoning help?
├── Want to see the thought process → Sequential Thinking
└── Just need the answer → Extended thinking (built-in)
```

## Best Practices

1. **Parallel searches** - Run Exa + WebSearch together for research
2. **Right tool for the job** - Internal tools for your code, MCP for external
3. **Context7 for libraries** - Prevents hallucinated APIs
4. **Serena for large files** - Better than Read for files >2000 lines
