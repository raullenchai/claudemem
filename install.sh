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
MARKER="## Memory 系统（per project）"

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

# Check if PreCompact hook already exists
if grep -q '"PreCompact"' "$SETTINGS"; then
    echo "settings.json already has PreCompact hook, skipping."
else
    # Use a temporary file for safe JSON merge
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

# --- Global gitignore for INBOX.md ---
GLOBAL_GITIGNORE=$(git config --global core.excludesfile 2>/dev/null || echo "")
if [ -z "$GLOBAL_GITIGNORE" ]; then
    GLOBAL_GITIGNORE="$HOME/.gitignore_global"
    git config --global core.excludesfile "$GLOBAL_GITIGNORE"
fi

if [ -f "$GLOBAL_GITIGNORE" ] && grep -qF "INBOX.md" "$GLOBAL_GITIGNORE"; then
    echo "INBOX.md already in global gitignore, skipping."
else
    echo "INBOX.md" >> "$GLOBAL_GITIGNORE"
    echo "Added INBOX.md to global gitignore ($GLOBAL_GITIGNORE)"
fi

echo ""
echo "Done! claudemem is now active."
echo ""
echo "Usage:"
echo "  record   - Save knowledge from current conversation"
echo "  distill  - Extract knowledge from accumulated logs"
echo ""
echo "Logs are written automatically before context compaction."
