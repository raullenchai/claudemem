#!/bin/bash
set -e

CLAUDE_DIR="$HOME/.claude"
CLAUDE_MD="$CLAUDE_DIR/CLAUDE.md"
SETTINGS="$CLAUDE_DIR/settings.json"

echo "Uninstalling claudemem..."

# --- Remove Todo and Memory sections from CLAUDE.md ---
if [ -f "$CLAUDE_MD" ]; then
    CHANGED=false
    for MARKER in "## Todo 系统" "## Memory 系统（per project）"; do
        if grep -qF "$MARKER" "$CLAUDE_MD"; then
            awk -v marker="$MARKER" '
                BEGIN { skip=0 }
                $0 ~ marker { skip=1; next }
                skip && /^## / { skip=0 }
                !skip { print }
            ' "$CLAUDE_MD" > "$CLAUDE_MD.tmp" && mv "$CLAUDE_MD.tmp" "$CLAUDE_MD"
            CHANGED=true
        fi
    done
    if [ "$CHANGED" = true ]; then
        echo "Removed claudemem instructions from $CLAUDE_MD"
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

# --- Remove td() function from shell config ---
SHELL_RC="$HOME/.zshrc"
[ ! -f "$SHELL_RC" ] && SHELL_RC="$HOME/.bashrc"

TD_MARKER="# claudemem: quick todo capture"
if [ -f "$SHELL_RC" ] && grep -qF "$TD_MARKER" "$SHELL_RC"; then
    awk -v marker="$TD_MARKER" '
        BEGIN { skip=0 }
        $0 ~ marker { skip=1; next }
        skip && /^}$/ { skip=0; next }
        !skip { print }
    ' "$SHELL_RC" > "$SHELL_RC.tmp" && mv "$SHELL_RC.tmp" "$SHELL_RC"
    echo "Removed td function from $SHELL_RC"
fi

echo ""
echo "Done! claudemem config removed."
echo "Your memory files (logs/, knowledge/, todo) were NOT deleted."
echo ""
echo "Restart your shell or run: source $SHELL_RC"
