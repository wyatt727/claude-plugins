---
description: Initialize project with MCP tools and create optimized CLAUDE.md
argument-hint: [--skip-mcps] [--force] [--uninstall]
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, Task, AskUserQuestion, WebFetch, TodoWrite
---

# Project Setup Wizard

Initialize this project with an optimized CLAUDE.md file following HumanLayer's research on effective agent onboarding.

**Track state throughout**: Remember what was detected/installed in each phase to inform later phases.

## Phase 0: Check for Uninstall Mode

If user passed `--uninstall` OR user's message contains uninstall intent (e.g., "uninstall", "remove mcps", "undo setup", "clean up"):

1. **Scan for setup artifacts** - Check each item exists AND was created by setup:

   | File | Exists? | Created by setup if... |
   |------|---------|------------------------|
   | `.mcp.json` | Check | Contains any of: `exa`, `serena`, `playwright`, `context7`, `sequential-thinking`, `server-memory` |
   | `.claude/settings.json` | Check | Contains `enableAllProjectMcpServers` |
   | `.serena/` | Check | Directory exists (always created by serena indexing) |
   | `docs/tools/` | Check | Contains files matching plugin's `resources/tool-docs/` (e.g., `serena.md`, `context7.md`) |
   | `CLAUDE.md` | Check | Contains "MCP Tools" section OR references `@docs/tools/` |

2. **Build findings list** with details:
   - For each item, note what was found (e.g., ".mcp.json with 6 MCP servers configured")
   - For `.mcp.json`, list which servers are configured
   - For `docs/tools/`, list which guide files exist

3. **If nothing found**: Report "No setup artifacts found. Nothing to uninstall." and exit.

4. **Present findings** using AskUserQuestion:
   - "Found these setup artifacts:"
   - Show detailed findings from step 2
   - "Select what to remove:"
   - Use `multiSelect: true` so user can choose specific items
   - Include "All of the above" as first option if multiple items found

5. **Remove selected items**:
   - For `.mcp.json`, `.claude/settings.json`, `.serena/`: Run `"${CLAUDE_PLUGIN_ROOT}/bin/install-mcps.sh" --uninstall`
   - For `docs/tools/`: `rm -rf docs/tools` (and `rmdir docs` if empty)
   - For `CLAUDE.md`: `rm CLAUDE.md`

6. **Report** what was removed and exit.

**Do not continue to other phases if uninstalling.**

## Phase 1: Check for Existing CLAUDE.md

If CLAUDE.md already exists and user didn't pass `--force`:
- Use AskUserQuestion: "CLAUDE.md already exists. What would you like to do?"
  - "Overwrite it" - Continue with setup
  - "Review and improve it" - Read existing file, suggest improvements based on best practices
  - "Cancel" - Stop

## Phase 2: MCP Tools (skip if --skip-mcps)

Check if MCP tools are configured:
```bash
claude mcp list 2>/dev/null | grep -E "^(serena|playwright|context7|exa):" && echo "MCP_CONFIGURED" || echo "MCP_NOT_CONFIGURED"
```

If "MCP_NOT_CONFIGURED", use AskUserQuestion:
- "Yes, install MCP tools (Recommended)" → Run `"${CLAUDE_PLUGIN_ROOT}/bin/install-mcps.sh"`
- "No, skip MCP setup" → Continue without MCP tools

**Track which MCP tools are installed** - this affects Phase 5.

## Phase 3: Explore the Codebase

Use Task tool with subagent_type="Explore":

```
Explore this codebase thoroughly. Identify:
1. Programming languages (check file extensions, package managers)
2. Project structure and key directories
3. Build/test/lint commands (package.json scripts, Makefile, etc.)
4. Existing documentation
5. Frameworks and libraries
6. Whether this is a monorepo

Return a structured summary. If the project is empty/new, say so explicitly.
```

## Phase 4: Gather Missing Information

**If project is empty/new**, ask:
1. "What type of project?" (Web app, API, CLI, Library, etc.)
2. "What tech stack?" (Language, framework, etc.)
3. "Brief description of what it will do?"

**If project has code**, confirm detected info and fill gaps:
1. "What is the purpose of this project? (1-2 sentences)"
2. Confirm detected commands or ask: "What commands do developers need?" (install, dev, test, build, lint)
3. "Any conventions Claude should always follow?" (Only ask if user might have strong preferences)

**Keep questions minimal** - only ask what's needed for a lean CLAUDE.md.

## Phase 5: Create Documentation Structure (only if MCP tools installed)

Only create docs/tools/ if MCP tools were installed in Phase 2:

```bash
mkdir -p docs/tools
```

Copy from `${CLAUDE_PLUGIN_ROOT}/resources/tool-docs/` to `docs/tools/`:
- README.md (always)
- Only copy docs for tools that were actually installed

## Phase 6: Create CLAUDE.md

Refer to the **claude-md-best-practices** skill for guidance. Key principles:

- **Target under 60 lines** (max 300)
- **Structure: WHAT → WHY → HOW**
- **Only universally applicable content**
- **Skip sections with no information** - don't use placeholders

Build CLAUDE.md dynamically from gathered information:

```markdown
# [Project Name]

[1-line description from Phase 4]

## Tech Stack

[Only include what was detected/confirmed - skip if unknown]

## Commands

[Only include commands that exist or were specified]

## Project Structure

[Key directories with 1-line descriptions - skip if empty project]

## MCP Tools

[Only include if MCP tools were installed in Phase 2]
Consult @docs/tools/README.md for MCP tool usage guides.

## File Headers

Every file MUST have a header comment with:
- What: Brief description of this file's purpose
- Why/How: Key responsibilities (2-3 bullets)
- Related files: Paths to files it interacts with

## Parallelization

Prioritize agent swarms for parallel execution:
- Multi-file changes → spawn agents per file
- Research + implementation → parallel agents
- Tests + code → write simultaneously

Maximum parallelization = maximum speed.

[Any project-specific conventions from Phase 4 - keep brief]
```

**Do NOT include**:
- Editing guidelines (Claude already knows this)
- Sections with placeholder values

## Phase 7: Verify and Report

1. Read back CLAUDE.md and count lines
2. Verify it follows best practices (lean, no placeholders, universally applicable)
3. Report what was created:
   - CLAUDE.md (X lines)
   - docs/tools/ files (if created)
   - MCP tools installed (if any)

4. Remind user:
   - "Add project-specific conventions as you discover them"
   - "Keep CLAUDE.md lean - use docs/ for detailed guidance"
