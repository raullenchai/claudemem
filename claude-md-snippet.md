## Todo System
- User writes todos via shell command `td "idea"` directly to `.claude/todo.md`, bypassing CC conversation
- At session start, check `.claude/todo.md` — if it has content, proactively inform user of N pending todos
- When user says "check todo", read and process items one by one
- Remove completed items

## Memory System (per project)

Each project's memory structure under the auto-memory directory:

```
memory/
  MEMORY.md              # Index, < 100 lines, auto-loaded every session
  logs/                  # Session logs, auto-written by PreCompact hook
    2026-03-11.md
  knowledge/             # Distilled knowledge, manually triggered
    decisions.md         # Architecture decisions (why A over B)
    gotchas.md           # Non-obvious bugs and pitfalls
    patterns.md          # Code patterns and conventions
    dependencies.md      # External library/API key behaviors
    preferences.md       # User preferences and workflow style
```

### PreCompact (automatic)
- Hook auto-appends current session work summary to `memory/logs/YYYY-MM-DD.md`
- Logs only — no categorization or distillation

### Command: "record"
When user says "record", extract knowledge from the **current conversation** and write directly:
1. Review current conversation, identify knowledge points with long-term value
2. Write directly to the appropriate file under `memory/knowledge/` (decisions/gotchas/patterns/dependencies/preferences)
3. Entry format: `[YYYY-MM-DD] content`, newest first
4. Update MEMORY.md index
5. Briefly inform user what was recorded

### Command: "distill"
When user says "distill", batch-extract knowledge from **accumulated logs** and write directly:
1. Read all unmarked logs under `memory/logs/`
2. Extract knowledge points with long-term value, write directly to the appropriate file under `memory/knowledge/`
3. Mark processed logs with `<!-- distilled: YYYY-MM-DD -->`
4. Update MEMORY.md index
5. Briefly inform user what was extracted

### General Rules
- All memory operations are per project, no cross-project sharing
- Auto-split knowledge files when they exceed 200 lines
