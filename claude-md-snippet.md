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
  knowledge/             # Distilled knowledge, auto-organized by domain
    <domain>.md          # Domains emerge naturally from project content
```

Knowledge domains are NOT predefined. CC creates domain files automatically based on the project's nature. Examples:

- Software project: `architecture.md`, `testing.md`, `deployment.md`, `api-design.md`, `gotchas.md`
- Finance/research project: `market-data.md`, `risk-models.md`, `strategies.md`, `regulatory.md`
- Any project: `preferences.md` (user workflow preferences, always applicable)

When recording knowledge, either append to an existing domain file or create a new one if no existing file fits. Keep domain names short, lowercase, hyphenated.

### PreCompact (automatic)
- Hook auto-appends current session work summary to `memory/logs/YYYY-MM-DD.md`
- Logs only — no categorization or distillation

### Command: "record"
When user says "record", extract knowledge from the **current conversation** and write directly:
1. Review current conversation, identify knowledge points with long-term value
2. Determine which domain each point belongs to — use existing domain files when possible, create new ones when needed
3. Write to the appropriate file under `memory/knowledge/<domain>.md`
4. Entry format: `[YYYY-MM-DD] content`, newest first
5. Update MEMORY.md index (add new domain if created)
6. Briefly inform user what was recorded and to which domains

### Command: "distill"
When user says "distill", batch-extract knowledge from **accumulated logs** and write directly:
1. Read all unmarked logs under `memory/logs/`
2. Extract knowledge points with long-term value, categorize by domain
3. Write to the appropriate files under `memory/knowledge/`
4. Mark processed logs with `<!-- distilled: YYYY-MM-DD -->`
5. Update MEMORY.md index
6. Briefly inform user what was extracted

### General Rules
- All memory operations are per project, no cross-project sharing
- Auto-split knowledge files when they exceed 200 lines
- Domain files are created organically — do not force a fixed taxonomy
