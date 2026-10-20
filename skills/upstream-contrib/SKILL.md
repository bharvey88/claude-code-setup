---
name: upstream-contrib
description: Workflow for filing GitHub issues and PRs to upstream/third-party repos (esphome, esphome.io docs, device-builder, ring-keypad, etc.). Use whenever drafting or submitting any GitHub issue or pull request for Brandon.
---

# Upstream Issues and PRs

## Hard gates (Brandon has corrected these many times)

1. **Show before submit.** Always show the complete, final issue/PR title and body verbatim and get explicit approval before `gh issue create` / `gh pr create`. No exceptions, even for small issues. Put the draft text in the chat message itself, before the question: a draft written only to a file never reaches him (the app's next-step box ends the turn, and Remote Control shows no files), and he then approves text he hasn't seen (2026-10-19, three times on tinkerologie/unraid-management-agent).
2. **One logical change per issue/PR.** ESPHome maintainers reject mashed-together PRs. If the work contains multiple independent changes, split into separate atomic issues/PRs and say so up front.
3. **Attribution:**
   - **Everywhere (esphome, bharvey88 repos, third-party)**: no Claude footer AND no co-author trailer. No Claude credit of any kind.
   - Commit identity is always Brandon Harvey, `8107750+bharvey88@users.noreply.github.com`.
4. **De-AI the prose.** Terse, factual, minimal. Prove claims with logs/links instead of adjectives. No headers-for-everything bulk in small issues.
5. **Issues report, they don't fix.** No speculation about causes, no unrequested workarounds or "vibe coded" patches - just enough evidence to prove the issue ("dont add the workaround just post the issue lol"). Share a snippet only if it proves the point.
6. **Port exactly what was asked.** When duplicating a feature across repos ("do the same thing the other repo does"), port precisely that logic - no adjacent improvements, no bundled extras. If extra work seems warranted, ask first. Scope creep here has cost real trust.

## Process

1. Verify the correct target repo (backend vs frontend, e.g. device-builder vs esphome) before drafting.
2. Read the repo's `CONTRIBUTING.md` / `agents.md` / PR template and follow it. **Keep every PR template header, checkbox, and prompt - fill them in, never delete them.**
3. Work from Brandon's fork (`bharvey88`). Force-push (`--force-with-lease`, fork remote only) is fine **before review starts**. **Once anyone has begun reviewing a PR, never force-push it.** A force-push makes a reviewer re-figure-out what changed, so the PR gets set aside in favor of the hundreds that didn't. To bring an out-of-date branch current or fix a build break mid-review, **merge the base branch in** (`git merge origin/dev`) or **add a commit on top** — a merge/normal commit shows the diff clearly. Rebase-and-force only on a branch no one is reviewing yet.
4. For screenshots/GIFs: leave a placeholder like `<!-- Brandon: drop image here -->` - he uploads media manually after posting. There is no CLI/API path to PR-body attachments; do NOT work around it by pushing the media to a fork branch and embedding the raw URL - Brandon rejected that (2026-07-26, WLED-Docs #347): the file outlives on his fork and breaks if the branch goes. Placeholder + his drag-and-drop, always.
5. After submitting, babysit follow-ups when asked: bring a stale branch current with a merge commit (not a rebase-force — see step 3), CI failures via `gh run view --log-failed`.
6. Fixing someone ELSE's open PR (no push perms as outside contributor, even with allow-edits): post a review comment with a ```suggestion``` block via `gh api repos/OWNER/REPO/pulls/N/comments --input body.json` (fields: body, commit_id = PR head sha, path, side: RIGHT, line). Author or any maintainer commits it with one click. Get the line number from the head-ref file content, not the diff hunk.
7. Feature-enable PRs to docs repos: Brandon splits capability from adoption - one PR enables the feature (config/CSS only, zero content pages), a follow-up PR changes the docs to use it ("i dont want to bundle it with any added annotations", WLED-Docs #347/#348). Offer this split whenever a docs PR would mix a new mechanism with content that uses it.

### Commit mechanics from the Bash tool (learned 2026-08-22/23)

- **Never chain `push` unconditionally after a validation step.** `validate; commit; push` shipped a broken commit to a public branch when validation failed (2026-09-05, hub75-studio) because the chain ran regardless. Gate it: `if ($code -eq 0) { commit; push } else { show errors }`.
- **Single-branch clones (`git clone -b X`) only fetch-track X**, so `--force-with-lease` on any other branch fails with "stale info" (no lease baseline). Verify the remote tip yourself (`git fetch origin <branch>` + `git log FETCH_HEAD`), then push with an explicit baseline: `--force-with-lease=<branch>:<sha>`.

- `git commit -F <(printf ...)` does NOT work from the Bash tool: git dies with `could not read log file '/proc/<pid>/fd/63'` and nothing is committed, while `; echo OK` afterwards still prints. Write the message to a real file in the scratchpad and `-F` that, then confirm with `git log -1`. This is the mechanism behind the CLAUDE.md "plain ASCII temp file" rule, not just a PowerShell quirk.

### gh CLI on Windows PowerShell 5.1 (bit us 3x, 2026-07)

- `--jq` expressions containing spaces get split into multiple args by PS native-arg passing ("accepts 1 arg(s), received N"), and embedded double quotes inside single-quoted args get eaten (jq parse errors). Don't fight the quoting: pipe `gh api ... | ConvertFrom-Json` and filter in PowerShell.
- POST/PUT bodies: build a hashtable, `ConvertTo-Json`, write it with `[IO.File]::WriteAllText(path, $json, (New-Object Text.UTF8Encoding($false)))`, then `gh api --input path`. `Out-File -Encoding utf8` writes a BOM in PS 5.1 and GitHub rejects the JSON (HTTP 400 "Problems parsing JSON").

### Per-repo notes (read the one for the repo you're working on)

- esphome/esphome, including hardware-testing someone else's PR and API/protocol changes: `references/esphome.md`
- Home Assistant core (WSL test env): `references/ha-core.md`
- esphome.io docs: `references/esphome-docs.md`

### tinkerologie/unraid-management-agent (Go Unraid plugin behind the HA integration)

- Issue first (bug form), wait for CodeRabbit's Coding Plan on it, follow the plan, open the PR as `--draft`, mark ready after governance passes. The first PR's CI waits for maintainer approval.
- Can't be checked out on Windows (colons in `testdata` paths). Work on claude-vm in `~/src/unraid-management-agent` (Go 1.27.2 at `/usr/local/go`, golangci-lint, goimports, pre-commit installed). Verify against the real tower by running the built binary briefly: `--port=18043 --bind-address=127.0.0.1 --read-only --discovery-enabled=false` (discovery off, or HA pops a duplicate "Tower").
- Merge gate is every check green, not the approval: the owner approved #286 and still waited on `codecov/patch` (90% of changed lines) and CodeRabbit's "Tests Cover Changed Code", which wants the changed function itself tested, not just a helper split out of it. Make file paths injectable via a struct field set in the constructor (`NotificationCollector.dynamixCfgPath` pattern) and test the success and error paths. CodeRabbit also warns on missing doc comments for touched functions, test functions included.
- Two open PRs must not both edit `CHANGELOG.md`; wait for the first to merge.

### wled/WLED-Docs

Full workflow lives in the **`wled-docs`** skill (repo setup, verification doctrine, CodeRabbit and maintainer dynamics, page-structure rules, mkdocs tooling). The hard gates and commit mechanics in this skill still apply there.

## General notes

**For upstream OSS PRs:** once automated checks pass, open the PR - don't gate on building a manual visual-verification matrix first.

### Rolling releases (CI-published pre-releases)

Never name a rolling release tag the same as a branch (e.g. tag `beta` alongside branch `beta`). ESPHome remote-package `ref:` and bare `git fetch origin <name>` resolve tags before branches, so the tag shadows the branch and freezes users' remote packages at the tag's commit. Use a distinct tag name like `beta-fw`. Also: `gh release create <tag>` without `--target` tags default-branch HEAD, not the branch you built from.
