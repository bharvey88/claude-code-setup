---
name: upstream-contrib
description: Workflow for filing GitHub issues and PRs to upstream/third-party repos (esphome, esphome-docs, device-builder, ring-keypad, etc.) and to Apollo product repos. Use whenever drafting or submitting any GitHub issue or pull request for Brandon.
---

# Upstream Issues and PRs

## Hard gates (Brandon has corrected these many times)

1. **Show before submit.** Always show the complete, final issue/PR title and body verbatim and get explicit approval before `gh issue create` / `gh pr create`. No exceptions, even for small issues.
2. **One logical change per issue/PR.** ESPHome maintainers reject mashed-together PRs. If the work contains multiple independent changes, split into separate atomic issues/PRs and say so up front.
3. **Attribution rules differ by destination:**
   - **Apollo repos (ApolloAutomation/*)**: include the `🤖 Generated with [Claude Code](https://claude.com/claude-code)` footer on commits/PRs (the repo owner requires it). Still NO `Co-Authored-By: Claude` trailer.
   - **Everywhere else (esphome, bharvey88 repos, third-party)**: no Claude footer AND no co-author trailer. No Claude credit of any kind.
   - Commit identity is always Brandon Harvey, `8107750+bharvey88@users.noreply.github.com`.
4. **De-AI the prose.** Terse, factual, minimal. Prove claims with logs/links instead of adjectives. No headers-for-everything bulk in small issues.
5. **Issues report, they don't fix.** No speculation about causes, no unrequested workarounds or "vibe coded" patches - just enough evidence to prove the issue ("dont add the workaround just post the issue lol"). Share a snippet only if it proves the point.
6. **Port exactly what was asked.** When duplicating a feature across repos ("do the same thing CAST-1 does"), port precisely that logic - no adjacent improvements, no bundled extras. If extra work seems warranted, ask first. Scope creep here has cost real trust.

## Process

1. Verify the correct target repo (backend vs frontend, e.g. device-builder vs esphome) before drafting.
2. Read the repo's `CONTRIBUTING.md` / `agents.md` / PR template and follow it. **Keep every PR template header, checkbox, and prompt - fill them in, never delete them.**
3. Work from Brandon's fork (`bharvey88`). Force-push with `--force-with-lease` only to the fork remote.
4. For screenshots/GIFs: leave a placeholder like `<!-- Brandon: drop image here -->` - he uploads media manually after posting.
5. After submitting, babysit follow-ups when asked: rebases on request, CI failures via `gh run view --log-failed`.

## Apollo product repos (MSR-1/2, AIR-1, MTR-1, TEMP-1, PLT-1, BTN-1, PUMP-1, R_PRO-1...)

Feature branch → PR to **`beta`** → **STOP**. A maintainer merges. Never self-merge, never PR straight to `main`. (The docs repo is different - see `apollo-docs`.) The eventual `beta → main` promotion uses a **merge commit, not squash**, so beta and main share history.

**Repo-meta carve-out:** changes that don't publish firmware - README, PR template, requirements, datasheets, `.github/workflows/*` - target **`main`** directly ("it's just fixes for the repos themselves"). Keep `main` and `beta` copies of `ci.yml`-type workflow files in agreement, or routine main↔beta merges resurrect old bugs.

**Before pushing to an existing PR branch:** verify which remote is ApolloAutomation (`git remote -v`) - clones/worktrees differ (`origin` is sometimes the fork), and pushing to the wrong remote silently creates a stray fork branch instead of updating the PR.

**For upstream OSS PRs:** once automated checks pass, open the PR - don't gate on building a manual visual-verification matrix first.

**Exception — `ApolloAutomation/installer`** (central web flasher, created 2026-07-08): not a firmware repo. PRs target `main` (merge auto-deploys Pages staging), no version bump applies, Brandon merges. See memory `apollo-installer`.

### Rolling releases (CI-published pre-releases)

Never name a rolling release tag the same as a branch (e.g. tag `beta` alongside branch `beta`). ESPHome remote-package `ref:` and bare `git fetch origin <name>` resolve tags before branches, so the tag shadows the branch and freezes users' remote packages at the tag's commit. Apollo convention: the rolling beta pre-release tag is **`beta-fw`**. Also: `gh release create <tag>` without `--target` tags default-branch HEAD, not the branch you built from.

### Editing the firmware YAML itself

Version bump, which file to edit (`Core.yaml` vs per-variant), ESPHome deprecated-API traps, `on_boot` merge form, flash-size ceiling, and local `esphome config` validation all live in the **`apollo-yaml`** skill. Use it for any change to the built firmware; come back here for the PR submit mechanics above.

