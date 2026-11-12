#!/usr/bin/env bash
# Usage: ./install.sh <skill-name>
# Copies <skill>/SKILL.md into ~/.claude/skills/<skill>/ and any <skill>/bin/*
# helpers into ~/.claude/bin/.
set -euo pipefail
cd "$(dirname "$0")"
skill="${1:?usage: ./install.sh <skill-name>}"
[ -f "$skill/SKILL.md" ] || { echo "no such skill: $skill" >&2; exit 1; }

mkdir -p ~/.claude/skills/"$skill"
cp "$skill/SKILL.md" ~/.claude/skills/"$skill"/
if [ -d "$skill/bin" ]; then
  mkdir -p ~/.claude/bin
  for f in "$skill"/bin/*; do install -m 755 "$f" ~/.claude/bin/; done
fi
echo "Installed /$skill"
