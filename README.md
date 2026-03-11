# claudemem

A structured memory system for Claude Code that prevents knowledge loss across sessions.

## Problem

When working on complex projects with Claude Code over hundreds or thousands of conversations, critical knowledge gets lost every time the context window compresses. Architecture decisions, hard-won debugging insights, established patterns — all gone.

## Solution

claudemem adds two layers of persistent memory to Claude Code:

- **Logs** (automatic): Raw session summaries, written automatically before context compaction
- **Knowledge** (manual): Distilled insights organized by category, triggered by you when ready

## Memory Structure (per project)

```
memory/
  MEMORY.md              # Index, < 100 lines, auto-loaded every session
  logs/                  # Auto-written by PreCompact hook
    2026-03-11.md        # Daily session logs
  knowledge/             # Written by "record" and "distill" commands
    decisions.md         # Architecture decisions (why A over B)
    gotchas.md           # Non-obvious bugs and pitfalls
    patterns.md          # Established code patterns and conventions
    dependencies.md      # External library/API key behaviors
    preferences.md       # User preferences and workflow style
```

## Commands

| You say | What happens |
|---------|-------------|
| **"record"** | Extract knowledge from the current conversation and save to `knowledge/` |
| **"distill"** | Batch-extract knowledge from accumulated `logs/` |

## How It Works

1. **PreCompact hook**: Before Claude Code compresses context, an agent automatically appends a session summary to `logs/YYYY-MM-DD.md`
2. **"record"**: You say "record" mid-conversation when something worth keeping comes up. CC extracts knowledge points and writes them to the appropriate category file under `knowledge/`
3. **"distill"**: After logs accumulate over days/weeks, you say "distill" and CC batch-processes all unprocessed logs into `knowledge/`
4. **MEMORY.md**: An index file that CC reads at every session start, pointing to relevant knowledge files

## Install

```bash
./install.sh
```

This will:
- Append memory system instructions to your `~/.claude/CLAUDE.md`
- Add the PreCompact hook to your `~/.claude/settings.json`
- Add `INBOX.md` to your global gitignore (so project inboxes are never committed)

## Uninstall

```bash
./uninstall.sh
```

Removes claudemem config from `~/.claude/CLAUDE.md` and the PreCompact hook from `~/.claude/settings.json`. Your memory files (logs, knowledge) are **not** deleted.

## Configuration Files

- `claude-md-snippet.md` — The instructions appended to `~/.claude/CLAUDE.md`
- `hook-config.json` — The PreCompact hook definition merged into `~/.claude/settings.json`

## Design Principles

- **Plain markdown** — No databases, no embeddings. Human-readable, version-controllable.
- **Per project** — Each project has its own memory. No cross-project pollution.
- **Two-tier** — Logs capture everything automatically. Knowledge is curated by you.
- **Minimal token cost** — Only MEMORY.md (the index) is loaded every session. Knowledge files are read on-demand.

## License

MIT
