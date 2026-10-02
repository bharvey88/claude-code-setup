# Full inventory

Everything my Claude Code is wired with: the skills I wrote, which live in this repo, plus the
public plugins I install on top. The skills are the custom layer. The plugins are other
people's work that I lean on, linked to their source rather than copied here.

## My skills (in this repo)

These live in [`skills/`](skills/). Each is a single `SKILL.md` with YAML frontmatter: a
`name`, a `description` that tells Claude when to load it, and the workflow itself.

| Skill | What it does |
|-------|--------------|
| [writing-voice](skills/writing-voice/SKILL.md) | General prose voice and anti-AI-tells rules for any writing, from blog posts to issues to commit messages. |
| [blog](skills/blog/SKILL.md) | Turn a session or project into a published blog post: structure, voice, and the publish steps. |
| [ha-debug](skills/ha-debug/SKILL.md) | Debug Home Assistant behavior. A notification that fired or didn't, an automation that never ran, a sensor gone unavailable. Carries the trap list that debugging sessions actually hit. |
| [ha-automations](skills/ha-automations/SKILL.md) | Author Home Assistant automations, scripts, and helpers with my conventions: aliases everywhere, the right mode, labels applied, near-duplicates consolidated, verified against traces. |
| [ha-dashboards](skills/ha-dashboards/SKILL.md) | Build and edit Lovelace dashboards: preview-then-swap for visual changes, compact card recipes, and the dashboard-tool gotchas. |
| [upstream-contrib](skills/upstream-contrib/SKILL.md) | File issues and PRs to upstream repos: show before submit, one change per PR, per-destination attribution rules. |
| [wled-docs](skills/wled-docs/SKILL.md) | Contribute to the WLED wiki: source-verified claims, live-device proofs, CodeRabbit triage, maintainer review dynamics, mkdocs page-structure rules. |
| [close](skills/close/SKILL.md) | End-of-session wrap-up. Square away memory, skills, and repo state before stopping. |
| [update-skills](skills/update-skills/SKILL.md) | Fold new corrections and preferences from a session back into the right `SKILL.md` files and memory. |

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
requesting and receiving code review, git worktrees, and more. ralph-wiggum runs a prompt
on a loop until the work is actually done, which suits long grinds like sweeping a fix
across a fleet of repos.

**Guardrails.** hookify turns observed mistakes into preventive hooks. security-guidance
screens risky commands before they run. Both fire constantly and I never think about them,
which is the point.

**Code review.** pr-review-toolkit gives me `review-pr` plus specialized reviewer agents for
silent failures, type design, test coverage, and comment accuracy. coderabbit adds its own
AI review pass on a diff or PR, a second opinion from a different model.

**Web.** firecrawl fetches and searches the web as clean markdown, including pages that need
JavaScript to render, for research and reading docs.

**Browser and UI.** playwright drives a real browser for verifying what actually rendered,
not what I assumed rendered. frontend-design sets aesthetic direction for new UI.

**Home Assistant.** home-assistant-best-practices pushes native constructs over templates,
`entity_id` over `device_id`, correct automation modes, and dashboard guidance.

**Home network.** unifi-network and unifi-protect are Ubiquiti's official plugins for the
UniFi Network controller and the Protect NVR: clients, firewall policies, Wi-Fi settings,
cameras, and detection events, read and changed from the session instead of the web UI.

I periodically audit which of these I actually invoke and turn off the ones I don't. A plugin
that sits unused still spends context on every session, so the list stays shorter than the
list of plugins that looked appealing at install time.

## How to use this repo

Copy any skill folder from [`skills/`](skills/) into your own `~/.claude/skills/`, then adapt
the frontmatter `description` so it triggers on your work and swap project-specific details
like repo names and publish steps for yours. For the plugins above, install from their own
sources, since this repo only points at them. The [memory pattern](memory-example/) you can
take wholesale, because it doesn't depend on any particular project.
