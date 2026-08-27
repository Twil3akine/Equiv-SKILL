#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOU'
Usage:
  ./install.sh --user
  ./install.sh --repo /path/to/project
EOU
}

root=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

case "${1:-}" in
  --user)
    if [[ $# -ne 1 ]]; then usage; exit 2; fi
    skill_dest="$HOME/.agents/skills/equiv"
    agent_dest="$HOME/.codex/agents"
    ;;
  --repo)
    if [[ $# -ne 2 ]]; then usage; exit 2; fi
    target=$(cd "$2" && pwd)
    skill_dest="$target/.agents/skills/equiv"
    agent_dest="$target/.codex/agents"
    ;;
  *)
    usage
    exit 2
    ;;
esac

mkdir -p "$(dirname "$skill_dest")" "$agent_dest"
rm -rf "$skill_dest"
cp -R "$root/skill/equiv" "$skill_dest"
cp "$root"/agents/equiv-*.toml "$agent_dest/"

printf 'Installed equiv skill: %s\n' "$skill_dest"
printf 'Installed equiv agents: %s\n' "$agent_dest"
printf 'Invoke in Codex with: $equiv <task>\n'
