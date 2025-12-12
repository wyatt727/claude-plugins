# Serena MCP - Semantic Code Understanding

## When to Use Serena

Use Serena ONLY for files >2000 lines where you need specific symbols, or when you need semantic understanding of code structure.

## Core Tools

### get_symbols_overview
Get high-level understanding of symbols in a file. Use this FIRST when exploring a new file.

```
mcp__serena__get_symbols_overview(
    relative_path="src/large-app.js",
    depth=1  # 0 for top-level only, 1 for children
)
```

### find_symbol
Find specific symbols by name path pattern:

```
mcp__serena__find_symbol(
    name_path="handleError",        # Can be "class/method" format
    relative_path="src/app.js",     # Optional: restrict to file/dir
    include_body=True,              # Get actual code
    depth=1                         # Get children too
)
```

### find_referencing_symbols
Find all references to a symbol:

```
mcp__serena__find_referencing_symbols(
    name_path="MyClass/myMethod",
    relative_path="src/myclass.js"
)
```

### search_for_pattern
Flexible regex search across codebase:

```
mcp__serena__search_for_pattern(
    substring_pattern="TODO|FIXME",
    relative_path="src/",
    restrict_search_to_code_files=True
)
```

## Editing with Serena

### replace_symbol_body
Replace entire symbol definition:

```
mcp__serena__replace_symbol_body(
    name_path="MyClass/myMethod",
    relative_path="src/myclass.js",
    body="function myMethod() { ... }"
)
```

### insert_after_symbol / insert_before_symbol
Add code relative to existing symbols:

```
mcp__serena__insert_after_symbol(
    name_path="MyClass",
    relative_path="src/myclass.js",
    body="\n\nfunction newFunction() { ... }"
)
```

## Best Practices

1. Use `include_body=False` first, then selectively read bodies
2. Always specify `relative_path` to speed up searches
3. Use `depth` parameter to control how much info you get
4. Prefer symbolic tools over grep for code navigation
