---
name: wled-docs
description: Full workflow for contributing to the WLED wiki (wled/WLED-Docs, kno.wled.ge, mkdocs-material) - fixing issues, restructuring pages, handling CodeRabbit and maintainer review, verifying claims against WLED firmware source and live devices. Use for ANY WLED-Docs task; generic PR mechanics (show-before-submit, no Claude credit, commit -F file) stay in upstream-contrib.
---

# WLED-Docs Contributions

Contributing docs to wled/WLED-Docs (the WLED wiki). The hard gates from `upstream-contrib` all apply (show before submit, one logical change per PR, no Claude credit anywhere, commit messages via `-F <file>`). This skill is everything WLED-Docs-specific, learned across 12+ PRs.

## The repo's agent rules win here (AGENTS.md, since 2026-10-11)

Brandon chose on 2026-10-25 to follow the repo's "Agent Contributor Rules" on WLED-Docs, overriding the general no-Claude-credit rule for this repo only. Re-read that AGENTS.md section at the start of every session; it changes.

- **Replies go out in Brandon's voice, as a human, with no AI line** (his call, repeated 2026-10-25/26: "i want to reply as a human", "no ai bot comment tho"). Draft in his cadence: quote the line he's answering, lowercase, `..`, short, casual ("done thanks man!"). Read a few of his own recent comments on the PR first to match it. Post only when he says to ("go", "post it", "type my reply for me"); otherwise he pastes. AGENTS.md forbids agent-posted replies, he knows (told him 2026-10-26) and chose this anyway: don't re-raise it every reply. Resolve a thread only after the reply is up. Creating or updating PRs is allowed; the PR description needs a summary built from his own words (quote his PR comments).
- **Attribution lines follow the harness.** On 2026-10-26 the harness said no attribution in commits or PR bodies, so #373 (later commits), #374 and #391 have no `Co-authored-by` trailer and no `_You are interacting with an AI system_` line, while earlier #373/#388 commits do. If the harness allows it, AGENTS.md wants the trailer on commits and the AI line on PR bodies. On the PC, `~/.claude/hooks/block-coauthor.ps1` allows the trailer only when the cwd is a `C:\tmp\WLED-Docs-*` worktree; never work around the hook.

## Repo setup

- Upstream `wled/WLED-Docs`, fork `bharvey88/WLED-Docs` (= `origin`), PRs target `main`. Merges to main auto-deploy to kno.wled.ge via GitHub Actions.
- Local: worktrees under `C:\tmp\WLED-Docs-*`; **the main clone is `C:\tmp\WLED-Docs-351`** (despite the name).
- **One worktree per session, not per PR** (2026-10-25: two sessions shared the #373 folder and one nearly committed the other's half-done edit). Git won't check out a branch in two worktrees, so:
  - Make your own detached worktree at the PR head, named for the PR plus a short session tag: `git -C C:/tmp/WLED-Docs-351 worktree add --detach C:/tmp/WLED-Docs-373-homekit origin/<branch>`.
  - Before pushing, `git fetch origin <branch>` and merge it in (never force), then `git push origin HEAD:<branch>`.
  - Never edit or commit in a folder another session is using. A worktree with uncommitted changes you didn't make belongs to someone else: leave it and make your own.
- Local tooling is untracked by design (`.claude/` and `capture_webui.py` are in the shared `.git/info/exclude`, so they're invisible in every worktree and can never ride into a PR):
  - **run-wled-docs driver** `C:\tmp\WLED-Docs-351\.claude\skills\run-wled-docs\driver.py`: `py -3.13 <driver> smoke|build|serve|shot|anchors|stop`, works on any worktree via `--dir`, one port per worktree. Use `anchors` on every page whose headings or links changed. It does NOT reliably catch the table annotation-tooltip bug below (it reported 0 off-screen on 2026-10-25 while the open tooltip sat at y=-708): open the annotation with a real click, then read `.md-tooltip--active`'s bounding box. Screenshots never show open tooltips, so don't judge them by eye. Pass page paths WITHOUT a leading slash from Git Bash (MSYS mangles `/x` into `C:/Program Files/Git/x`).
  - **capture_webui.py** in `C:\tmp\WLED-Docs-webui`: reproducible Playwright capture of the Web UI / settings screenshots from a live device, including the `wledUiCfg` localStorage seeding the settings/ui page needs.
- Always `mkdocs serve` the change and give Brandon the localhost link before asking for approval; he reviews rendered pages, not diffs.

## Verification doctrine (the actual value of these PRs)

Every factual claim gets traced to evidence before it ships; three claims written from memory were wrong in one session and CodeRabbit caught them.

- **Firmware source**: wled/WLED at the release tag. Tags since 16.0 are `v16.x.y`; older are `v0.x.y`. Fetch files with `gh api repos/wled/WLED/contents/<path>?ref=<tag> --jq .content | base64 -d`. Defaults come from `wled.h`/source, never from a live device (devices show customized values).
- **Live devices** for behavior and screenshots: 200-LED WS2812B strip at 10.10.10.13 ("Brandon Bed"), 128x128 M-1 matrix at 10.10.10.242. Temporarily changing state over the JSON API is fine **if** the exact prior state is captured first and restored after (verify the restore; reads can race the transition). Staging a screenshot by filling a settings form WITHOUT saving is legitimate and preferred over changing config.
- **Empirical proofs in PR bodies**: curl result tables plus GitHub permalinks to the source lines (`.../blob/v16.0.1/wled00/file.cpp#L410-L465`). Maintainers merge these fast.
- **Before submitting**: run the two review passes from `upstream-contrib` (adversarial maintainer persona on the actual diff + an AGENTS.md compliance table). Both catch real errors here, same as esphome. A `fable` subagent per PR works well for the adversarial pass.

## AGENTS.md is the review bar

Reviewers hold PRs to the repo's AGENTS.md checklist. The ones that bite: Title Case headings (articles lowercase); no duplicate content, cross-link the existing page instead (check `docs/` for an existing page before writing about anything); root-relative internal links without `.md`; short sentences, no comma splices; informal tone, contractions welcome; calibrated claims. Verify every new in-page anchor against the rendered DOM, and remember slugs change when heading *text* changes, not when the level changes.

## Review dynamics

- **CodeRabbit is usually right here** (~90% valid over 5 PRs). Verify each finding against source, fix the valid ones, draft a short "Fixed in <sha>" reply for Brandon to post, and resolve via GraphQL `resolveReviewThread` once he has. It auto-resolves its own threads sometimes; when it says "couldn't resolve, please do it manually", that's your cue. Decline MD055 table-pipe findings when rows match the table's existing pipe-free style, citing the recorded learning from #292/#367 (a maintainer's rule: consistency within the table wins).
- **Maintainers squash-merge and also push `Merge branch 'main'` commits into PR branches.** Never force-push; `git fetch origin <branch>` and merge their commits in.
- **Follow-up PR touching a file an open PR also touches**: branch off that PR's head, note it in the body ("its commits show here until it merges"). The moment the parent squash-merges, merge `upstream/main` in, keep our side of the conflict (content identical, history isn't), and confirm `gh pr view --json files` collapsed to just the intended files. This conflict appears silently, GitHub doesn't notify.
- **Post-approval pushes** get a short courtesy comment saying what moved and why (pushes notify nobody). Draft it; Brandon posts it.
- **Issue-closing PRs**: when they merge, draft a thank-you to the community reporter for Brandon to post on the issue (standing habit).

## Page structure taste (Brandon + repo)

- Long reference pages get an "I want to... / Go to" jump table at the top, with every anchor DOM-verified.
- Index tables whose description cells wrap badly become one section per item: linked heading, description paragraph, italic meta line (`_By [@author](profile). Platforms: x. License: SPDX._`). Contributor instructions then show the copy-paste block.
- No collapsible `???` sections on reference pages (tried, rejected: "click for more info" labels prove the collapse hides rather than organizes).
- **Annotations (Akemi) are paragraph-only.** In tables the marker renders but the tooltip opens ~1400px off-screen (positions against the wrong ancestor inside the table scrollwrap); headless DOM checks say "open", only a bounding-box check catches it. List items are also broken. Pattern: `(1)` at the end of a paragraph, `{ .annotate }` on the next line, numbered list after. Use them for option enumerations, conditional tails, and warnings; never for a row's core meaning.
- Don't open a page with an admonition. Security warnings still go near the top: right after the intro paragraphs, before any setup steps.
- **Headings are plain nouns** (Requirements, Server Setup, Troubleshooting, Common Issues). Template headings like "What You Need", "Things to Know", "Check It's Working" read as AI tells; he rejected all three on #391.
- **No heading that only wraps an admonition.** Give the box a one-sentence summary title that states the risk (`!!! warning "Anyone who can reach the device can control it and read its private key"`), never a bare "Warning" or "Security".
- **Annotations hold background "why", never a key value.** Defaults, server names and other things people need to act stay inline (he called hiding the NTP default "weird").
- **Cut edge-case sentences** nobody asked about ("whether that checkbox is ticked doesn't matter"). If it needs a defence, it doesn't belong.
- **Troubleshooting = Mermaid flowchart + a "Common Issues" bullet list.** He rejected a status/meaning/fix table. Mermaid is enabled in `mkdocs.yml` (`pymdownx.superfences` custom fence); #391 is the first page using it. It renders client-side in a closed shadow root, so check it with a screenshot, not DOM queries.
- **Built-in usermods vs third-party:** Community Usermods (#372) is third-party only. A built-in usermod (in `wled/WLED/usermods/`) gets its own Advanced page, like Audio Reactive and PIR Sensors. There is no index of the 72 built-in usermods yet (proposed follow-up: float it with the maintainer first).
- GIFs: Brandon records them himself (drops them in `Downloads`) and likes them quick; suggest pacing once, drop it if he declines. Inspect frames (PIL contact sheet) before wiring one in; check for clipped UI and whether what the text describes is actually visible in-frame (e.g. an effect that hides the palette list).

## Gotchas

- Big multi-PR sessions confuse `@{u}`: branches cut from `upstream/main` track it, so `git log @{u}..` lies about unpushed work. Judge push state with `git ls-remote origin <branch>` against the PR head.
- **The driver's `serve` doesn't pick up edits** (seen 2026-10-26: Brandon kept seeing stale text). After every edit run `stop --port N` then `serve`, and curl for the new text before telling him to look. Port 8765 is usually another session's server; give each worktree its own port.
- **Stop every old `mkdocs serve` when done.** Six from earlier sessions were still running a day later and he asked for all of them gone. `Get-CimInstance Win32_Process | ? CommandLine -match 'mkdocs serve'` lists them with ports.
- **Annotation clicks need a real mouse click.** JS `.click()` on `.md-annotation__index` doesn't open the tooltip; use `computer left_click` on the marker, then read `.md-tooltip--active`'s bounding box.
- `mkdocs build` warnings: the "MkDocs 2 coming" banner is noise (suppress with `DISABLE_MKDOCS_2_WARNING=true`); pre-existing absolute-link INFO lines are not warnings. The driver's `build` already handles both.
- Playwright on this box: `py -3.13` only, and printing page text needs `PYTHONIOENCODING=utf-8` (cp1252 console).
