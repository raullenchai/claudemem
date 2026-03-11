#!/bin/bash
set -e

CLAUDE_DIR="$HOME/.claude"
CLAUDE_MD="$CLAUDE_DIR/CLAUDE.md"
SETTINGS="$CLAUDE_DIR/settings.json"

echo "Uninstalling claudemem..."

# --- Remove from CLAUDE.md ---
if [ -f "$CLAUDE_MD" ]; then
    # Remove everything between the marker and the next top-level heading (or EOF)
    START_MARKER="## Memory 系统（per project）"
    if grep -qF "$START_MARKER" "$CLAUDE_MD"; then
        # Use awk to remove the claudemem section
        awk -v marker="$START_MARKER" '
            BEGIN { skip=0 }
            $0 ~ marker { skip=1; next }
            skip && /^## / { skip=0 }
            !skip { print }
        ' "$CLAUDE_MD" > "$CLAUDE_MD.tmp" && mv "$CLAUDE_MD.tmp" "$CLAUDE_MD"
        echo "Removed memory system instructions from $CLAUDE_MD"
    else
        echo "No claudemem config found in $CLAUDE_MD"
    fi
fi

# --- Remove PreCompact hook from settings.json ---
if [ -f "$SETTINGS" ] && grep -q '"PreCompact"' "$SETTINGS"; then
    if command -v jq &> /dev/null; then
        jq 'del(.hooks.PreCompact)' "$SETTINGS" > "$SETTINGS.tmp" && mv "$SETTINGS.tmp" "$SETTINGS"
        echo "Removed PreCompact hook from $SETTINGS"
    else
        echo "WARNING: jq not installed. Please manually remove the PreCompact hook from $SETTINGS"
    fi
else
    echo "No PreCompact hook found in $SETTINGS"
fi

echo ""
echo "Done! claudemem config removed."
echo "Your memory files (logs/, knowledge/) were NOT deleted."
