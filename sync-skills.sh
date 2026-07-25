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

# --- plugin-inventory drift check -----------------------------------------
# INVENTORY.md names the plugins by hand, so it goes stale whenever one is
# enabled or disabled - a change this script otherwise never sees, because it
# only copies SKILL.md files. Compare the enabled set in settings.json against
# the names INVENTORY.md mentions, and warn in both directions. Warning only:
# never edit INVENTORY.md from here, the prose around each name is hand-written.
SETTINGS="${CLAUDE_SETTINGS:-$HOME/.claude/settings.json}"
INVENTORY="INVENTORY.md"

# Plugin directory name -> the name INVENTORY.md uses, where they differ.
# Add a line here when a plugin is written up under its skill's name instead.
alias_for() {
  case "$1" in
    home-assistant-skills) echo "home-assistant-best-practices" ;;
    *)                     echo "$1" ;;
  esac
}

# Bare plugin names from the enabledPlugins block, by boolean value.
# Keys are "<plugin>@<marketplace>"; the same plugin can appear under two
# marketplaces, so dedupe on the bare name.
plugins_where() {
  sed -n '/"enabledPlugins"/,/}/p' "$SETTINGS" 2>/dev/null \
    | grep -oE "\"[^\"]+@[^\"]+\"[[:space:]]*:[[:space:]]*$1" \
    | sed -E 's/^"([^@"]+)@.*/\1/' | sort -u || true
}

# Case-insensitive fixed-string match. Deliberately NOT `grep -iF`: that flag
# pair aborts (SIGABRT, exit 134) in GNU grep 3.0 under MSYS/git-bash, with or
# without -q and in any locale. Lowercasing both sides keeps -F, so a plugin
# name containing regex metacharacters still matches literally.
lc() { tr '[:upper:]' '[:lower:]'; }
mentioned_in_inventory() {
  printf '%s' "$inventory_lc" | grep -qF -- "$(printf '%s' "$1" | lc)"
}

inventory_drift=0
if [ -f "$SETTINGS" ] && [ -f "$INVENTORY" ]; then
  # Search ONLY the plugin section, not the whole file: prose elsewhere
  # contains substrings that collide with plugin names (a github.com link
  # matches 'github'), which would report drift that isn't there.
  inventory_lc=$(sed -n '/^## Plugins I layer on/,/^## /p' "$INVENTORY" | lc)
  if [ -z "$inventory_lc" ]; then
    echo "  !! could not find the '## Plugins I layer on' section in $INVENTORY"
    inventory_drift=1
  fi
  # Space-delimited on one line, so the membership test below can match
  # ' name ' - sort -u returns newline-separated, which never would.
  enabled=$(plugins_where true | tr '\n' ' ')
  # Enabled but unlisted: INVENTORY claims to be the set actually in use.
  for p in $enabled; do
    if ! mentioned_in_inventory "$(alias_for "$p")"; then
      echo "  !! '$p' is enabled but INVENTORY.md never mentions it"
      inventory_drift=1
    fi
  done
  # Listed but switched off. A plugin enabled under one marketplace and
  # disabled under another is still in use, so skip anything in $enabled.
  for p in $(plugins_where false); do
    case " $enabled " in *" $p "*) continue ;; esac
    if mentioned_in_inventory "$(alias_for "$p")"; then
      echo "  !! '$p' is disabled but INVENTORY.md still lists it"
      inventory_drift=1
    fi
  done
else
  echo "  (skipped plugin-inventory check: settings.json or INVENTORY.md not found)"
fi

echo
if [ "$warned" -eq 1 ]; then
  echo ">>> Fix the unmapped name(s) above before committing."
fi
if [ "$inventory_drift" -eq 1 ]; then
  echo ">>> INVENTORY.md disagrees with your enabled plugins - reconcile before committing."
fi
if [ "$changed" -eq 0 ]; then
  echo "Nothing changed - mirror already current."
else
  echo "$changed file(s) updated. Review: git diff -- skills/"
  echo "Then commit + push to main (no Claude footer, ID-prefixed noreply email)."
fi
