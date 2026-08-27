#!/usr/bin/env bash
set -euo pipefail

if repo_root=$(git rev-parse --show-toplevel 2>/dev/null); then
  :
else
  repo_root=$PWD
fi

work="$repo_root/.equiv"
active="$work/active"
archive="$work/archive"

mkdir -p "$archive"

has_active_content=false
if [[ -d "$active" ]]; then
  shopt -s nullglob
  for f in "$active"/*; do
    if [[ -f "$f" && -s "$f" ]]; then
      has_active_content=true
      break
    fi
  done
  shopt -u nullglob
fi

if [[ "$has_active_content" == true ]]; then
  stamp=$(date -u +%Y%m%dT%H%M%SZ)
  dest="$archive/$stamp"
  suffix=1
  while [[ -e "$dest" ]]; do
    dest="$archive/${stamp}-$suffix"
    suffix=$((suffix + 1))
  done
  mv "$active" "$dest"
fi

mkdir -p "$active"

cat > "$work/.gitignore" <<'EOG'
*
!.gitignore
EOG

for file in brief.md engineer.md observer.md issues.md result.md; do
  : > "$active/$file"
done

if [[ ! -e "$work/state.md" ]]; then
  cat > "$work/state.md" <<'EOSTATE'
# Project state

## Goal

## Current architecture

## Current implementation

## Known current issues

## Last verified
EOSTATE
fi

if [[ ! -e "$work/invariants.md" ]]; then
  cat > "$work/invariants.md" <<'EOINV'
# Invariants
EOINV
fi

printf '%s\n' "$active"
