---
name: project-docs-site
description: "Ongoing docs-site rebuild: goals and constraints not derivable from the code"
metadata:
  type: project
---

Example project record. `type: project` memories hold ongoing-work context you can't reconstruct from the repo or git history, like goals, decisions, and constraints.

- Migrating the docs site to a new static generator; started 2026-06-01.
- Constraint: all edits go through a PR to `dev`; a maintainer merges `dev` → `main`.
- Convert relative dates to absolute when writing these, so they still make sense months later.
