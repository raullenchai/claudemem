#!/bin/bash
set -e

CLAUDE_DIR="$HOME/.claude"
CLAUDE_MD="$CLAUDE_DIR/CLAUDE.md"
SETTINGS="$CLAUDE_DIR/settings.json"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Installing claudemem..."

# Ensure ~/.claude exists
mkdir -p "$CLAUDE_DIR"

# --- Append to CLAUDE.md ---
MARKER="## Memory System (per project)"

if [ -f "$CLAUDE_MD" ] && grep -qF "$MARKER" "$CLAUDE_MD"; then
    echo "CLAUDE.md already contains claudemem config, skipping."
else
    echo "" >> "$CLAUDE_MD"
    cat "$SCRIPT_DIR/claude-md-snippet.md" >> "$CLAUDE_MD"
    echo "Added memory system instructions to $CLAUDE_MD"
fi

# --- Merge hook into settings.json ---
if [ ! -f "$SETTINGS" ]; then
    echo '{}' > "$SETTINGS"
fi

if grep -q '"PreCompact"' "$SETTINGS"; then
    echo "settings.json already has PreCompact hook, skipping."
else
    if command -v jq &> /dev/null; then
        HOOK_CONFIG=$(cat "$SCRIPT_DIR/hook-config.json")
        jq --argjson hooks "$HOOK_CONFIG" '
            .hooks = ((.hooks // {}) + $hooks)
        ' "$SETTINGS" > "$SETTINGS.tmp" && mv "$SETTINGS.tmp" "$SETTINGS"
        echo "Added PreCompact hook to $SETTINGS"
    else
        echo ""
        echo "WARNING: jq is not installed. Please manually add the following to $SETTINGS under \"hooks\":"
        echo ""
        cat "$SCRIPT_DIR/hook-config.json"
        echo ""
        echo "Install jq with: brew install jq"
    fi
fi

# --- Add td() function to shell config ---
SHELL_RC="$HOME/.zshrc"
[ ! -f "$SHELL_RC" ] && SHELL_RC="$HOME/.bashrc"

TD_MARKER="# claudemem: quick todo capture"

if [ -f "$SHELL_RC" ] && grep -qF "$TD_MARKER" "$SHELL_RC"; then
    echo "td function already in $SHELL_RC, skipping."
else
    cat >> "$SHELL_RC" << 'SHELL_FUNC'

# claudemem: quick todo capture (bypasses CC conversation)
td() {
  local root=$(git rev-parse --show-toplevel 2>/dev/null)
  if [ -z "$root" ]; then
    echo "Not in a git project" >&2
    return 1
  fi
  local todo="$root/.claude/todo.md"
  mkdir -p "$root/.claude"
  [ ! -f "$todo" ] && echo "# Todo" > "$todo"
  if [ -n "$1" ]; then
    echo "- $(date '+%m-%d %H:%M') $*" >> "$todo"
  else
    echo "- $(date '+%m-%d %H:%M') " >> "$todo"
    ${EDITOR:-vim} "$todo"
    return
  fi
  echo "Added to $todo"
}
SHELL_FUNC
    echo "Added td function to $SHELL_RC"
fi

echo ""
echo "Done! claudemem is now active."
echo ""
echo "Usage:"
echo "  record          - Say to CC: save knowledge from current conversation"
echo "  distill         - Say to CC: extract knowledge from accumulated logs"
echo '  td "your idea"  - Shell: add todo without interrupting CC'
echo ""
echo "Logs are written automatically before context compaction."
echo ""
echo "Restart your shell or run: source $SHELL_RC"
