#!/usr/bin/env bash
# sync-skills.sh - refresh this public mirror from the live ~/.claude/skills.
#
# For each skill: copy the live SKILL.md in, then deterministically scrub known
# maintainer/coworker names to roles (the private skills may name people; this
# public repo must not). The scrub is idempotent, so an unchanged live skill
# always produces byte-identical output here and git stays clean. A grep
# backstop warns if any UNMAPPED name slipped through - add it to SCRUBS below.
#
# Does NOT commit or push. Review `git diff -- skills/`, then commit yourself.
# Usage: run from the repo root:  bash sync-skills.sh
set -euo pipefail

LIVE="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"
REPO_SKILLS="skills"

# Deterministic name -> role scrubs, applied in order. Longer/contextual forms
# first so a bare-name rule doesn't double-substitute (e.g. "maintainer bdraco"
# must resolve before standalone "bdraco").
scrub() {
  sed -E \
    -e 's/maintainer bdraco/a maintainer/g' \
    -e 's/bdraco/a maintainer/g' \
    -e 's/[Tt]revor/a colleague/g' \
    -e 's/[Jj]ustin/a colleague/g'
}
# Safety-net pattern: any of these surviving the scrub means a new variant.
LEFTOVER_RE='bdraco|[Tt]revor|[Jj]ustin'

[ -d "$REPO_SKILLS" ] || { echo "run from the repo root (no ./skills here)"; exit 1; }
[ -d "$LIVE" ] || { echo "live skills dir not found: $LIVE"; exit 1; }

changed=0
warned=0
for d in "$REPO_SKILLS"/*/; do
  name=$(basename "$d")
  src="$LIVE/$name/SKILL.md"
  dst="$d/SKILL.md"
  if [ ! -f "$src" ]; then
    echo "NO-LIVE   $name (in repo, not in live - skipped)"
    continue
  fi
  scrub < "$src" > "$dst.tmp"
  if cmp -s "$dst.tmp" "$dst"; then
    rm -f "$dst.tmp"
    echo "IN SYNC   $name"
  else
    mv "$dst.tmp" "$dst"
    echo "UPDATED   $name"
    changed=$((changed + 1))
  fi
  if grep -nEH "$LEFTOVER_RE" "$dst" >/dev/null 2>&1; then
    echo "  !! unmapped name survived scrub in $name - add it to SCRUBS:"
    grep -nEH "$LEFTOVER_RE" "$dst" | sed 's/^/     /'
    warned=1
  fi
done

echo
if [ "$warned" -eq 1 ]; then
  echo ">>> Fix the unmapped name(s) above before committing."
fi
if [ "$changed" -eq 0 ]; then
  echo "Nothing changed - mirror already current."
else
  echo "$changed file(s) updated. Review: git diff -- skills/"
  echo "Then commit + push to main (no Claude footer, ID-prefixed noreply email)."
fi
