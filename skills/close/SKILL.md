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

## Phase 2: Memory and skill hygiene

- **REQUIRED SUB-SKILL:** run `update-skills` for corrections and workflow changes from this session.
- Write memory files only for durable facts the repo itself doesn't record. A zero-note close is a valid close: never write a memory so the summary has content.
- Fix stale memories now: anything renamed, moved, finished, or contradicted this session gets its memory file and its MEMORY.md line updated (or deleted) before stopping. Don't leave a known-wrong note for the next session to trip on.

## Phase 3: Nothing pending

Before reporting, check: no unpushed work Brandon hasn't explicitly decided to hold, no community issue closed without its thank-you comment, no blocked action missing from the report, no stale MEMORY.md line left standing. Fix what a tool call can fix now.

## Phase 4: The close report

The final message, in this shape:

**Summary**: two or three sentences on what the session set out to do and what shipped.

**State**: per repo, pushed/live vs. local-only, plus every blocked or skipped action.

**Memory/skills**: one line per file written, edited, or deleted. "None needed" is a fine answer.

**Debrief**, answered against evidence, not optimism:

- The biggest thing Brandon might be missing right now.
- Confidence (high/medium/low) and the single check that would raise it most.
- What's most likely to break later, and how it would show up.
- Follow-ups worth their own session.

A confident-sounding non-answer is worse than "I don't know." If the honest answer is uncomfortable, say it plainly.
