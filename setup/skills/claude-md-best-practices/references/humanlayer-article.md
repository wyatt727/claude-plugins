# Writing a Good CLAUDE.md File - Full Reference

Source: https://www.humanlayer.dev/blog/writing-a-good-claude-md

## Core Principle

LLMs operate as stateless functions—they don't learn over time and only know what's explicitly provided via tokens. Since `CLAUDE.md` appears in every conversation with Claude Code, it's the primary mechanism for onboarding agents into your codebase.

## Three Critical Implications

1. Agents begin each session with zero codebase knowledge
2. Essential information must be communicated each session
3. `CLAUDE.md` is the recommended delivery method

## Essential Content Areas (WHAT, WHY, HOW)

**WHAT:** Technical stack, project structure, and codebase architecture. This is especially crucial for monorepos—clearly identify applications, shared packages, and their purposes.

**WHY:** Project purpose and functional role of different components within the repository.

**HOW:** Workflow details including package managers (bun vs node), verification methods, and how to execute tests, typechecks, and compilation steps.

## Claude Often Ignores CLAUDE.md

Anthropic injects a system reminder: *"this context may or may not be relevant to your tasks. You should not respond to this context unless it is highly relevant."* Claude will deprioritize information deemed irrelevant to current tasks, making universal applicability critical.

## Key Recommendations

### Instruction Minimalism

Research shows frontier LLMs reliably follow approximately 150-200 instructions. Claude Code's system prompt already contains ~50 instructions, consuming roughly one-third of available capacity before any custom rules. Include only universally applicable instructions.

### File Length and Scope

- Target: fewer than 300 lines (HumanLayer's is under 60 lines)
- Only include universally applicable content
- Avoid task-specific guidance like database schema instructions

### Progressive Disclosure Strategy

Store task-specific documentation in separate markdown files:

```
agent_docs/
 |- building_the_project.md
 |- running_tests.md
 |- code_conventions.md
 |- service_architecture.md
 |- database_schema.md
 |- service_communication_patterns.md
```

Instruct Claude to evaluate relevance and read needed files. **Prefer file:line references over code snippets** to maintain authoritative source material.

### Never Use CLAUDE.md as a Linter Substitute

LLMs are expensive and slow compared to deterministic linters. Delegate style enforcement to tools like Biome. Consider using Claude Code Stop hooks or Slash Commands to handle formatting separately from implementation.

### Avoid Auto-Generation

The `/init` feature and auto-generation tools produce suboptimal results. `CLAUDE.md` is the highest-leverage configuration point—every line deserves deliberate consideration.

## Conclusion

Effective `CLAUDE.md` files balance comprehensive onboarding with disciplined constraint, defining project context while directing agents toward just-in-time information retrieval.

## Key Takeaways

1. **Under 300 lines** - Ideally under 60
2. **WHAT, WHY, HOW** - Cover all three
3. **Universally applicable** - Every instruction relevant to every task
4. **Progressive disclosure** - Split detailed docs into separate files
5. **File references** - Point to source files, don't embed snippets
6. **Not a linter** - Use proper tools for style enforcement
7. **Hand-crafted** - Don't auto-generate
