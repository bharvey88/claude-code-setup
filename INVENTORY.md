# Full inventory

Everything my Claude Code is wired with: the skills I wrote, which live in this repo, plus the
public plugins I install on top. The skills are the custom layer. The plugins are other
people's work that I lean on, linked to their source rather than copied here.

## My skills (in this repo)

These live in [`skills/`](skills/). Each is a single `SKILL.md` with YAML frontmatter: a
`name`, a `description` that tells Claude when to load it, and the workflow itself.

| Skill | What it does |
|-------|--------------|
| [apollo-docs](skills/apollo-docs/SKILL.md) | Full edit-and-publish workflow for a mkdocs-material wiki: branch, PR to `dev`, squash-merge, sync `dev` into `main`, verify the deploy went live. |
| [apollo-writing-style](skills/apollo-writing-style/SKILL.md) | Product-specific formatting and naming: verbatim UI labels, app naming, sidebar structure, for anything user-facing. |
| [writing-voice](skills/writing-voice/SKILL.md) | General prose voice and anti-AI-tells rules for any writing, from blog posts to issues to commit messages. |
| [blog](skills/blog/SKILL.md) | Turn a session or project into a published blog post: structure, voice, and the publish steps. |
| [ha-debug](skills/ha-debug/SKILL.md) | Debug Home Assistant behavior. A notification that fired or didn't, an automation that never ran, a sensor gone unavailable. |
| [apollo-yaml](skills/apollo-yaml/SKILL.md) | Walk an ESPHome firmware YAML change through an Apollo device repo: which file to edit, the traps that redden CI, version bump, local validation. |
| [upstream-contrib](skills/upstream-contrib/SKILL.md) | File issues and PRs to upstream repos: show before submit, one change per PR, per-destination attribution rules. |
| [close](skills/close/SKILL.md) | End-of-session wrap-up. Square away memory, skills, and repo state before stopping. |
| [update-skills](skills/update-skills/SKILL.md) | Fold new corrections and preferences from a session back into the right `SKILL.md` files and memory. |

The Apollo-named skills reference public [Apollo Automation](https://github.com/ApolloAutomation)
repos and are shared as real, working examples. Names of specific people were removed. The
workflow mechanics are intact.

## The memory pattern

See [`memory-example/`](memory-example/) for a sanitized demo. Short version: memory is a
folder of one-fact-per-file Markdown notes with frontmatter, plus a `MEMORY.md` index that
loads into context every session. Facts are typed `user`, `feedback`, `project`, or
`reference`, and notes cross-link with `[[name]]`. The index carries the hooks. The files
carry the detail. Full write-up in the [README](README.md#the-memory-pattern).

## Plugins I layer on

These are public Claude Code plugins and skill packs. I don't republish them, so install from
their own sources. This is the set I actually reach for.

**Process and workflow.** superpowers is the backbone here: brainstorming, writing-plans,
test-driven-development, systematic-debugging, verification-before-completion,
requesting and receiving code review, git worktrees, and more.

**Code review.** pr-review-toolkit gives me `review-pr` plus specialized reviewer agents for
silent failures, type design, test coverage, and comment accuracy. coderabbit and qodo cover
third-party AI review.

**Web and research.** firecrawl handles scrape, crawl, search, map, monitor, download, parse,
and interactive browser sessions. deep-research does fan-out web search with adversarial
verification and cited synthesis.

**Design and build.** figma covers design-to-code, Code Connect, and library generation.
frontend-design sets aesthetic direction for new UI. dataviz and artifact-design are the
chart and artifact design systems.

**Home Assistant.** home-assistant-best-practices pushes native constructs over templates,
`entity_id` over `device_id`, correct automation modes, and dashboard guidance.

**Meta and tooling.** plugin-dev scaffolds plugins, skills, agents, commands, and hooks.
hookify turns observed mistakes into preventive hooks.

## How to use this repo

Copy any skill folder from [`skills/`](skills/) into your own `~/.claude/skills/`, then adapt
the frontmatter `description` so it triggers on your work and swap project-specific details
like repo names and publish steps for yours. For the plugins above, install from their own
sources, since this repo only points at them. The [memory pattern](memory-example/) you can
take wholesale, because it doesn't depend on any particular project.
