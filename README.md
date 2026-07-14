# claude-code-setup

How I've wired [Claude Code](https://claude.com/claude-code) for real work: shipping
firmware, publishing docs, debugging Home Assistant, and writing. This repo is the custom
layer I've built on top of it, shared so you can lift the parts that fit your own work.

Two things live here:

1. **[`skills/`](skills/)** — eight skills I wrote. Each one is a workflow Claude loads
   automatically when the task matches, so I don't have to re-explain how I like things done.
2. **[`memory-example/`](memory-example/)** — a sanitized demo of my file-based memory
   pattern, which is the part most people haven't seen before.

The [full inventory](INVENTORY.md) also catalogs the public plugins I layer on top
(superpowers, firecrawl, figma, and the rest), with links to install them.

## What a skill is

A skill is a folder with one `SKILL.md` file. The frontmatter has a `name`, a
`description` that tells Claude *when* to reach for it, and then the body is the actual
workflow. That's it. When a task matches the description, Claude loads the skill and follows
it. It's the difference between explaining "here's how we publish the wiki" every single
time versus writing it down once.

The ones in this repo:

- **apollo-docs** — the whole publish chain for a mkdocs-material wiki, from branch to
  live deploy verification.
- **apollo-writing-style** — naming and formatting conventions so product-facing text stays
  consistent.
- **writing-voice** — general prose voice and the anti-AI-tells rules I use on everything
  public.
- **blog** — turning a session into a finished blog post.
- **ha-debug** — working backward from a Home Assistant symptom to the cause.
- **upstream-contrib** — how I file issues and PRs to other people's repos without being
  the annoying contributor.
- **close** — end-of-session cleanup.
- **update-skills** — teaching the setup something new after it gets a correction.

The Apollo-named ones reference public [Apollo Automation](https://github.com/ApolloAutomation)
repos and are shared as working examples. I stripped out coworkers' names; the mechanics are
untouched.

## The memory pattern

This is the piece I'd steal first if I were you.

Claude Code can keep a persistent memory, but instead of one giant file I use a folder of
small notes, **one fact per file**, each with frontmatter:

```markdown
---
name: prefers-native-constructs
description: Prefer built-in constructs over custom templating when both exist
metadata:
  type: feedback
---

When both a native construct and a hand-rolled template solve the same problem,
use the native one.

**Why:** ...
**How to apply:** ...
```

A single **`MEMORY.md` index** sits alongside those files and loads into context at the
start of every session. It's one line per note: a title, a link, and a hook. The index tells
Claude what exists; the individual files hold the detail and only get pulled in when relevant.

Four types of fact:

- **`user`** — who I am: handles, commit identity, standing preferences.
- **`feedback`** — corrections and confirmed approaches, always with the *why*.
- **`project`** — ongoing work and constraints you can't reconstruct from the code.
- **`reference`** — durable pointers to external docs, dashboards, tickets.

Notes cross-link with `[[other-note-name]]`, so related facts find each other. When something
turns out wrong, you delete the file instead of editing around it. See
[`memory-example/`](memory-example/) for a runnable version with one note of each type.

Why bother? A flat memory file rots. A per-fact folder with a loaded index stays scannable,
stays current, and lets Claude pull in exactly the facts a task needs without dragging the
rest along.

## Using this

- Copy any folder from [`skills/`](skills/) into your `~/.claude/skills/`, then edit the
  frontmatter `description` so it fires on *your* work and swap the project details for yours.
- Take the [memory pattern](memory-example/) as-is; it's project-agnostic.
- For the plugins in the [inventory](INVENTORY.md), install from their own sources — I only
  point at them here.

## License

[MIT](LICENSE). Take what's useful.
