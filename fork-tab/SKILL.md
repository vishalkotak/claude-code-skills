---
name: fork-tab
description: Fork this conversation into a new Ghostty tab (t, default), split (d) or window (w)
argument-hint: "[t|d|w]"
disable-model-invocation: true
allowed-tools: Bash(~/.claude/bin/fork-tab:*)
---
!`~/.claude/bin/fork-tab ${CLAUDE_SESSION_ID} "$PWD" $ARGUMENTS`

Report the line above to the user in one sentence. Do nothing else.
