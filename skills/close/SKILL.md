---
name: close
description: Use when Brandon says "/close", "close out the session", "wrap up", "end of session", or work is winding down and memory, skills, and repo state need squaring away before stopping. Not for closing files, windows, PRs, or GitHub issues.
---

# Session Close

Land what the session learned, verify what it claims, and end with an honest debrief. Phases 1-3 are tool work with brief status notes; phase 4 is the only substantial output.

## Phase 1: Inventory from evidence

Reconstruct what the session touched, grounded in tools, not recall:

- Per repo touched: `git status --short`, and `git log --oneline @{u}..` for unpushed commits. **Local work Brandon reviewed is not live until pushed**; say so explicitly if anything is unpushed.
- For repos that auto-deploy on push (wiki, classes, blog): `gh run list --limit 3` to confirm the deploy actually went green. Pushed but red is not shipped.
- List actions that were denied, blocked, or promised-but-skipped this session. These get reported in phase 4, never silently dropped.
- If a touched repo has a HANDOFF.md, update it before closing: dated state, decisions, next steps, then commit and push it. This is separate from any code commit the session already made; do it even if there is nothing else to commit.
- **Never commit handoffs or session notes to a public repo.** Check `gh repo view --json visibility` before pushing any HANDOFF, spec, plan or review. Public repos keep notes in their designated private place (Game Day firmware: the private `gameday-notes` repo, loaded via a gitignored `CLAUDE.local.md`), even if the public repo's own CLAUDE.md says otherwise. Brandon, 2026-09-26: "i dont want handoffs in the repo ever again this is a public repo".

## Phase 2: Memory and skill hygiene

- **REQUIRED SUB-SKILL:** run `update-skills` for corrections and workflow changes from this session.
- **Sync the public skills mirror.** After update-skills settles the edits, refresh `bharvey88/claude-code-setup` (clone at `C:\Users\bharv\development\claude-code-setup` on Windows, `~/development/claude-code-setup` on the Mac; clone it if absent). **Pull the mirror first and compare it with the live skills before syncing:** a machine whose live skills lag the mirror (the Mac sat two months behind until 2026-09-23) would overwrite newer mirror text with its stale copies. Install anything newer from the mirror into the live skills, then run the sync. Run `bash sync-skills.sh` from the repo root: it copies any drifted `SKILL.md` in and auto-scrubs known maintainer/coworker names to roles (the name map lives in the script). If it warns that an **unmapped** name slipped through, add that name to the script's map or hand-scrub it before committing; Brandon's own name, handles, and bot names stay. Then `git diff -- skills/`, commit + push to `main` (no Claude footer, ID-prefixed noreply email). It's a full sweep of all skills, so it also catches drift from earlier sessions where the sync was skipped. Nothing changed after scrub = skip cleanly, no commit. Judge sync state from the script's own output, never from a raw `diff` of live vs mirror: the scrub is permanent, so scrubbed lines always read as drift and always will. `IN SYNC` from the script is the only reliable signal.
- **The mirror is more than SKILL.md.** A clean `sync-skills.sh` run does not mean the repo is current. `README.md` and `INVENTORY.md` are hand-maintained and go stale from things the script never touches: plugins enabled or disabled, skills added or removed, settings changes. Check them whenever the session changed the setup, not just when it changed a skill.
- **Sync claude-vm too.** If the session changed global rules, skills or memory and `ssh claude-vm true` answers, run `bash ~/development/gameday-notes/vm/sync-claude-setup.sh`. The always-on VM works from a copy of this setup, and the PC is the source of truth. It skips personal/legal memory on purpose.
- Write memory files only for durable facts the repo itself doesn't record. A zero-note close is a valid close: never write a memory so the summary has content.
- Fix stale memories now: anything renamed, moved, finished, or contradicted this session gets its memory file and its MEMORY.md line updated (or deleted) before stopping. Don't leave a known-wrong note for the next session to trip on.

## Phase 3: Nothing pending

Before reporting, check: no unpushed work Brandon hasn't explicitly decided to hold, no community issue closed without its thank-you comment, no blocked action missing from the report, no stale MEMORY.md line left standing. Fix what a tool call can fix now.

## Phase 4: The close report

The final message, in this shape:

**Summary**: two or three sentences on what the session set out to do and what shipped.

**State**: per repo, pushed/live vs. local-only, plus every blocked or skipped action.

**Memory/skills**: one line per file written, edited, or deleted. "None needed" is a fine answer.

**Quiz** (only when the session changed behavior; skip for read-only sessions): before the debrief, ask two or three short questions whose answers would change what Brandon does next. "Which of these is live and which is local-only?" "What breaks if that deploy goes red overnight?" A wrong or hesitant answer means the handoff didn't land: fix the explanation now, don't just log it and move on.

**Debrief**, answered against evidence, not optimism:

- The biggest thing Brandon might be missing right now.
- Confidence (high/medium/low) and the single check that would raise it most.
- What's most likely to break later, and how it would show up.
- Follow-ups worth their own session.

Anything reported as a *current* problem carries the date range its evidence covers. "74 hook errors" is not a finding; "73 errors, all between 2026-06-15 and 06-17, none since" is, and the two point at opposite actions. Stale evidence presented as live is the specific failure this phase exists to catch.

A confident-sounding non-answer is worse than "I don't know." If the honest answer is uncomfortable, say it plainly.
