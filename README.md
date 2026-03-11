# claudemem

A structured memory system for Claude Code that prevents knowledge loss across sessions.

## Problem

When working on complex projects with Claude Code over hundreds or thousands of conversations, critical knowledge gets lost every time the context window compresses. Architecture decisions, hard-won debugging insights, established patterns — all gone.

## Solution

claudemem adds three layers of persistent memory to Claude Code:

- **Logs** (automatic): Raw session summaries, written automatically before context compaction
- **Knowledge** (manual): Distilled insights organized by category, triggered by you when ready
- **Todo** (manual): Ideas and tasks you can inject anytime without interrupting CC

## Memory Structure (per project)

```
memory/
  MEMORY.md              # Index, < 100 lines, auto-loaded every session
  logs/                  # Auto-written by PreCompact hook
    2026-03-11.md        # Daily session logs
  knowledge/             # Auto-organized by domain
    <domain>.md          # Domains created automatically based on project content

.claude/
  todo.md                # Ideas and tasks injected from outside CC
```

Knowledge domains are **not predefined**. CC creates domain files automatically based on what you're working on. For example:

- Software project: `architecture.md`, `testing.md`, `deployment.md`, `api-design.md`, `gotchas.md`
- Finance/research project: `market-data.md`, `risk-models.md`, `strategies.md`, `regulatory.md`
- Any project: `preferences.md` (user workflow preferences)

## Commands

### Inside CC (say these to Claude Code)

| You say | What happens |
|---------|-------------|
| **"record"** | Extract knowledge from the current conversation and save to `knowledge/` |
| **"distill"** | Batch-extract knowledge from accumulated `logs/` |
| **"check todo"** | Review and process pending todo items |

### Outside CC (shell commands, won't interrupt CC)

```bash
# Add a todo while CC is busy — run in another terminal
td "refactor the auth module"
td "consider using Redis for caching"
```

The `td` command writes directly to `.claude/todo.md` in the current project. CC picks it up when you ask.

## How It Works

1. **PreCompact hook**: Before Claude Code compresses context, an agent automatically appends a session summary to `logs/YYYY-MM-DD.md`
2. **"record"**: You say "record" mid-conversation when something worth keeping comes up. CC extracts knowledge points and writes them to auto-determined domain files under `knowledge/`
3. **"distill"**: After logs accumulate over days/weeks, you say "distill" and CC batch-processes all unprocessed logs into `knowledge/`
4. **MEMORY.md**: An index file that CC reads at every session start, pointing to relevant knowledge files
5. **`td` command**: Write todos from any terminal without interrupting CC's current work

## Install

```bash
./install.sh
```

This will:
- Append memory system instructions to your `~/.claude/CLAUDE.md`
- Add the PreCompact hook to your `~/.claude/settings.json`
- Add the `td` shell function to your shell config (`~/.zshrc` or `~/.bashrc`)

## Uninstall

```bash
./uninstall.sh
```

Removes claudemem config from `~/.claude/CLAUDE.md`, the PreCompact hook from `~/.claude/settings.json`, and the `td` function from your shell config. Your memory files (logs, knowledge, todo) are **not** deleted.

## Configuration Files

- `claude-md-snippet.md` — The instructions appended to `~/.claude/CLAUDE.md`
- `hook-config.json` — The PreCompact hook definition merged into `~/.claude/settings.json`

## Design Principles

- **Plain markdown** — No databases, no embeddings. Human-readable, version-controllable.
- **Per project** — Each project has its own memory. No cross-project pollution.
- **Three-tier** — Logs capture everything automatically. Knowledge is curated by you. Todos are injected by you anytime.
- **Minimal token cost** — Only MEMORY.md (the index) is loaded every session. Knowledge files are read on-demand.

## License

MIT
