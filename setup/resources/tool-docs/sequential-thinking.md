# Sequential Thinking MCP - Transparent Reasoning

## Purpose

Provides step-by-step, **visible** reasoning that you can inspect, debug, and intervene in. Unlike Claude's built-in extended thinking (which works internally), sequential-thinking shows you the full thought process.

## When to Use Sequential Thinking

**Use for:**
- Complex architectural decisions where you want to see the reasoning
- Multi-step problems where you might need to correct course
- Debugging failed approaches - trace exactly where logic went wrong
- Collaborative problem-solving - intervene and guide the process
- Auditable decisions - need to explain "why" to stakeholders

**Don't use for:**
- Simple tasks where you just need an answer
- When you trust Claude's judgment and don't need visibility
- Speed-critical tasks (adds overhead)

## Sequential Thinking vs Extended Thinking

| Aspect | Extended Thinking | Sequential Thinking MCP |
|--------|-------------------|------------------------|
| **Visibility** | Internal (summary only) | Full transparency |
| **Intervention** | Cannot interrupt | Can correct mid-process |
| **Speed** | Faster | Slower (explicit steps) |
| **Best for** | "Just give me the answer" | "Show me your work" |

Think of it as:
- **Extended Thinking** = "quiet, internal genius"
- **Sequential Thinking** = "transparent, collaborative partner"

## How to Invoke

The MCP provides the `sequentialthinking` tool. Use it when you need visible, step-by-step reasoning:

```
mcp__sequential-thinking__sequentialthinking(
    thought="Analyzing the trade-offs between approach A and B...",
    nextThoughtNeeded=true
)
```

## Key Capabilities

- **Revision**: Can revise earlier thoughts as understanding deepens
- **Branching**: Explore alternative reasoning paths
- **Dynamic depth**: Adjust number of thoughts based on complexity

## Disable Logging

If thought logs are too verbose, set environment variable:
```bash
export DISABLE_THOUGHT_LOGGING=true
```

## Sources

- [Sequential Thinking MCP Server](https://github.com/modelcontextprotocol/servers/tree/main/src/sequentialthinking)
- [Sequential vs Extended Thinking Explained](https://www.arsturn.com/blog/sequential-vs-extended-thinking-in-claude-whats-the-difference)
- [Cline on Extended vs Sequential Thinking](https://x.com/cline/status/1928208680903921803)
