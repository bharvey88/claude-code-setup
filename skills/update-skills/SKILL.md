---
name: update-skills
description: End-of-session habit - review this conversation for new corrections, preferences, or workflow changes from Brandon and fold them into the right SKILL.md files and memory. Use when Brandon says "update your skills", "learn from this", "remember this for next time", or at the end of a session where he corrected you on something new.
---

# Update Skills From This Session

Skills are the durable home for Brandon's workflow rules; memory files point to them. When he gives standing feedback, it belongs in a skill, not just in your head for this session.

## Process

1. Scan this conversation for:
   - Corrections he made more than once, or stated as a standing rule ("never...", "always...", "from now on...").
   - A workflow step that differed from what a skill currently says.
   - New facts that change existing rules (policy changes, new accounts, renamed things).
2. For each finding, decide where it lives:
   - Matches an existing skill's domain → **edit that SKILL.md** (`C:\Users\bharv\.claude\skills\`). Check the directory for the current list rather than trusting a hardcoded one. Plugin-provided skills (e.g. `home-assistant-best-practices`) are read-only - they're overwritten on plugin updates, so their durable additions go in the matching personal skill instead.
   - Truly global rule (applies in every folder, every repo) → `C:\Users\bharv\.claude\CLAUDE.md`, but only with Brandon's explicit yes - he approves each global rule individually.
   - Standing rule with no skill home → memory `feedback` file (with Why / How to apply), or propose a new skill if it's a whole workflow.
   - One-off detail for an ongoing project → memory `project` file. Note memory is per-project-dir (the store that loads depends on where the session started); skills and CLAUDE.md are global.
3. When a skill and a memory file overlap, the skill is canonical - update both, keep the memory file as a short pointer.
4. If a new rule contradicts an existing skill/memory line, fix the old text - don't leave both versions.
5. Show Brandon a short list of what you changed (one line per edit). Don't paste full file contents unless he asks.

## Guardrails

- Don't record one-off, task-specific instructions as standing rules (Brandon flagged "never ESK" being wrongly generalized - when unsure whether something is standing or one-off, ask).
- Preview-vs-no-preview, ask-vs-act preferences are per-task for him - don't encode either extreme as a blanket rule.
- Mechanically enforceable rules (banned strings in commands, protected files) may deserve a hook in `~/.claude/hooks/` + settings.json instead of prose - suggest it when it fits.
