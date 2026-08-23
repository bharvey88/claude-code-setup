---
name: wled-docs
description: Full workflow for contributing to the WLED wiki (wled/WLED-Docs, kno.wled.ge, mkdocs-material) - fixing issues, restructuring pages, handling CodeRabbit and maintainer review, verifying claims against WLED firmware source and live devices. Use for ANY WLED-Docs task; generic PR mechanics (show-before-submit, no Claude credit, commit -F file) stay in upstream-contrib.
---

# WLED-Docs Contributions

Contributing docs to wled/WLED-Docs (the WLED wiki). The hard gates from `upstream-contrib` all apply (show before submit, one logical change per PR, no Claude credit anywhere, commit messages via `-F <file>`). This skill is everything WLED-Docs-specific, learned across 12+ PRs.

## Repo setup

- Upstream `wled/WLED-Docs`, fork `bharvey88/WLED-Docs` (= `origin`), PRs target `main`. Merges to main auto-deploy to kno.wled.ge via GitHub Actions.
- Local: worktrees under `C:\tmp\WLED-Docs-*`; **the main clone is `C:\tmp\WLED-Docs-351`** (despite the name). One worktree per PR branch.
- Local tooling is untracked by design (`.claude/` and `capture_webui.py` are in the shared `.git/info/exclude`, so they're invisible in every worktree and can never ride into a PR):
  - **run-wled-docs driver** `C:\tmp\WLED-Docs-351\.claude\skills\run-wled-docs\driver.py`: `py -3.13 <driver> smoke|build|serve|shot|anchors|stop`, works on any worktree via `--dir`, one port per worktree. Use `anchors` on every page whose headings or links changed; it also catches the annotation-tooltip bug below. Pass page paths WITHOUT a leading slash from Git Bash (MSYS mangles `/x` into `C:/Program Files/Git/x`).
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

- **CodeRabbit is usually right here** (~90% valid over 5 PRs). Verify each finding against source, fix the valid ones, reply "Fixed in <sha>" in-thread, and resolve via GraphQL `resolveReviewThread`. It auto-resolves its own threads sometimes; when it says "couldn't resolve, please do it manually", that's your cue. Decline MD055 table-pipe findings when rows match the table's existing pipe-free style, citing the recorded learning from #292/#367 (a maintainer's rule: consistency within the table wins).
- **Maintainers squash-merge and also push `Merge branch 'main'` commits into PR branches.** Never force-push; `git fetch origin <branch>` and merge their commits in.
- **Follow-up PR touching a file an open PR also touches**: branch off that PR's head, note it in the body ("its commits show here until it merges"). The moment the parent squash-merges, merge `upstream/main` in, keep our side of the conflict (content identical, history isn't), and confirm `gh pr view --json files` collapsed to just the intended files. This conflict appears silently, GitHub doesn't notify.
- **Post-approval pushes** get a short courtesy comment saying what moved and why (pushes notify nobody).
- **Issue-closing PRs**: when they merge, post a thank-you to the community reporter on the issue (standing habit).

## Page structure taste (Brandon + repo)

- Long reference pages get an "I want to... / Go to" jump table at the top, with every anchor DOM-verified.
- Index tables whose description cells wrap badly become one section per item: linked heading, description paragraph, italic meta line (`_By [@author](profile). Platforms: x. License: SPDX._`). Contributor instructions then show the copy-paste block.
- No collapsible `???` sections on reference pages (tried, rejected: "click for more info" labels prove the collapse hides rather than organizes).
- **Annotations (Akemi) are paragraph-only.** In tables the marker renders but the tooltip opens ~1400px off-screen (positions against the wrong ancestor inside the table scrollwrap); headless DOM checks say "open", only a bounding-box check catches it. List items are also broken. Pattern: `(1)` at the end of a paragraph, `{ .annotate }` on the next line, numbered list after. Use them for option enumerations, conditional tails, and warnings; never for a row's core meaning.
- Don't open a page with an admonition.
- GIFs: Brandon records them himself (drops them in `Downloads`) and likes them quick; suggest pacing once, drop it if he declines. Inspect frames (PIL contact sheet) before wiring one in; check for clipped UI and whether what the text describes is actually visible in-frame (e.g. an effect that hides the palette list).

## Gotchas

- Big multi-PR sessions confuse `@{u}`: branches cut from `upstream/main` track it, so `git log @{u}..` lies about unpushed work. Judge push state with `git ls-remote origin <branch>` against the PR head.
- `mkdocs build` warnings: the "MkDocs 2 coming" banner is noise (suppress with `DISABLE_MKDOCS_2_WARNING=true`); pre-existing absolute-link INFO lines are not warnings. The driver's `build` already handles both.
- Playwright on this box: `py -3.13` only, and printing page text needs `PYTHONIOENCODING=utf-8` (cp1252 console).
