# Full inventory

Everything my Claude Code is wired with — the skills I wrote (in this repo) plus the
public plugins I install on top. The skills are the custom layer; the plugins are other
people's work that I lean on, linked to their source rather than copied here.

## My skills (in this repo)

These live in [`skills/`](skills/). Each is a single `SKILL.md` with YAML frontmatter —
a `name`, a `description` that tells Claude *when* to load it, and the workflow itself.

| Skill | What it does |
|-------|--------------|
| [apollo-docs](skills/apollo-docs/SKILL.md) | Full edit-and-publish workflow for a mkdocs-material wiki: branch, PR to `dev`, squash-merge, `dev`→`main` sync, verify the deploy is live. |
| [apollo-writing-style](skills/apollo-writing-style/SKILL.md) | Product-specific formatting and naming conventions — verbatim UI labels, app naming, sidebar structure — for anything user-facing. |
| [writing-voice](skills/writing-voice/SKILL.md) | General prose voice and anti-AI-tells rules for any writing: blog posts, wiki pages, issues/PRs, community replies, commit messages. |
| [blog](skills/blog/SKILL.md) | Turn a session or project into a published blog post — structure, voice, and the publish steps. |
| [ha-debug](skills/ha-debug/SKILL.md) | Debug Home Assistant behavior: a notification that fired (or didn't), an automation that didn't run, a sensor that went unavailable. |
| [upstream-contrib](skills/upstream-contrib/SKILL.md) | Workflow for filing issues and PRs to upstream/third-party repos — show-before-submit, one change per PR, per-destination attribution rules. |
| [close](skills/close/SKILL.md) | End-of-session wrap-up: square away memory, skills, and repo state before stopping. |
| [update-skills](skills/update-skills/SKILL.md) | Fold new corrections and preferences from a session back into the right `SKILL.md` files and memory. |

> Note: the Apollo-named skills reference public [Apollo Automation](https://github.com/ApolloAutomation)
> repos and are shared as real, working examples. Names of specific people were removed;
> the workflow mechanics are intact.

## The memory pattern

See [`memory-example/`](memory-example/) for a sanitized demo. Short version: memory is a
folder of one-fact-per-file Markdown notes with frontmatter, plus a `MEMORY.md` **index**
that loads into context every session. Facts are typed `user` / `feedback` / `project` /
`reference`, and notes cross-link with `[[name]]`. The index carries the hooks; the files
carry the detail. Full write-up in the [README](README.md#the-memory-pattern).

## Plugins I layer on (not in this repo — install from source)

These are public Claude Code plugins/skill packs. I don't republish them; install from their
own sources. This is the set I actually reach for.

### Process / workflow
- **superpowers** — the process-discipline backbone: brainstorming, writing-plans,
  test-driven-development, systematic-debugging, verification-before-completion,
  requesting/receiving-code-review, using-git-worktrees, and more.

### Code review
- **pr-review-toolkit** — `review-pr` plus specialized reviewer agents (silent-failure,
  type-design, test-coverage, comment-accuracy, simplifier).
- **coderabbit** / **qodo** — third-party AI review integrations.

### Web / research
- **firecrawl** — scrape, crawl, search, map, monitor, download, parse, and interactive
  browser sessions.
- **deep-research** — fan-out web search + adversarial verification + cited synthesis.

### Design / build
- **figma** — design-to-code, Code Connect, library/component generation, motion.
- **frontend-design** — aesthetic direction for new UI.
- **dataviz** / **artifact-design** — chart and artifact design systems.

### Home Assistant
- **home-assistant-best-practices** — native constructs over templates, `entity_id` over
  `device_id`, correct automation modes, dashboard/card guidance.

### Meta / tooling
- **plugin-dev** — scaffold plugins, skills, agents, commands, hooks.
- **hookify** — turn observed mistakes into preventive hooks.

## How to use this repo

1. Copy any skill folder from [`skills/`](skills/) into your own `~/.claude/skills/`.
2. Adapt the frontmatter `description` so it triggers on *your* work, and swap
   project-specific details (repo names, publish steps) for yours.
3. For the plugins above, install from their own sources — this repo only points at them.
4. Steal the [memory pattern](memory-example/) wholesale; it's project-agnostic.
