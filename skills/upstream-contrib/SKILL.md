---
name: upstream-contrib
description: Workflow for filing GitHub issues and PRs to upstream/third-party repos (esphome, esphome.io docs, device-builder, ring-keypad, etc.) and to Apollo product repos. Use whenever drafting or submitting any GitHub issue or pull request for Brandon.
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
3. Work from Brandon's fork (`bharvey88`). Force-push (`--force-with-lease`, fork remote only) is fine **before review starts**. **Once anyone has begun reviewing a PR, never force-push it.** A force-push makes a reviewer re-figure-out what changed, so the PR gets set aside in favor of the hundreds that didn't. To bring an out-of-date branch current or fix a build break mid-review, **merge the base branch in** (`git merge origin/dev`) or **add a commit on top** — a merge/normal commit shows the diff clearly. Rebase-and-force only on a branch no one is reviewing yet.
4. For screenshots/GIFs: leave a placeholder like `<!-- Brandon: drop image here -->` - he uploads media manually after posting.
5. After submitting, babysit follow-ups when asked: bring a stale branch current with a merge commit (not a rebase-force — see step 3), CI failures via `gh run view --log-failed`.

### esphome/esphome specifics (learned 2026-07)

- The proof IS the failing test: for bugfix PRs, write a unit test that fails before the fix and passes after, and say so in one sentence. Their PR template treats a linked issue as optional, so a self-proving PR needs no separate issue. Brandon: no verbose wording, "they dont like AI vibe coded stuff".
- **PR title MUST start with a `[tag]` prefix** or the "Validate PR title" check fails. Use the component name for component work (`[sen5x] ...`); use **`[core]`** for shared/core code that isn't one component (`config_validation.py`, `AGENTS.md`, etc.). This bit us on a `cv.rename_key` PR (title had no tag). "Check blocking labels" failing right after open is usually transient (it only fails on `needs-docs`/`merge-after-release`/`chained-pr` labels).
- Before pushing: run BOTH `ruff check` and `ruff format --check` on touched files (a `ruff check` pass alone is not enough; format failures fail their CI - this bit us once).
- Stacked PRs exist there now; use only for genuinely dependent changes. Independent fixes stay separate PRs so either can merge alone.
- Windows-only bugs: a filesystem-based repro test may pass on their POSIX CI both before and after the fix. Add an OS-independent variant (e.g. monkeypatched glob returning unnormalized paths) so CI actually guards the regression. Raw-backslash fake paths do NOT work as the portable variant - POSIX treats backslash as a filename char and is_file filters drop them.
- **`esphome/const.py` is FROZEN** (CI `lint_const_py_frozen` in `script/ci-custom.py`). A new `CONF_` constant shared across 2+ components goes in **`esphome/components/const/__init__.py`** (alphabetical, name must match value), imported via `from esphome.components.const import CONF_X`. A constant *defined* in 3+ files fails `lint_constants_usage`; the usage lint matches definition lines, not imports.
- **pre-commit `pylint` hook needs `pylint` on PATH.** It runs `pylint` via `script/run-in-env.py`; if pylint isn't installed the commit aborts with `FileNotFoundError`. Install the pinned version (`requirements_test.txt`, e.g. `pylint==4.0.6`) into `C:\Users\bharv\esphome-venv` and prepend `esphome-venv/Scripts` to PATH before `git commit`. ruff/flake8/ci-custom are already isolated/available.
- **Config-key renames:** `cv.rename_key(OLD, NEW)` silently remaps for back-compat (used in `api`). For an honest deprecation, write a warn-then-remap validator (`_LOGGER.warning("'x' is deprecated, use 'y'. Will be removed in YYYY.M.0")` then `config[new]=config.pop(old)`) placed first in `cv.All(...)`, and check the Breaking-change box. There is no `cv.deprecated` helper. A key rename needs a matching docs PR. Reviewers also want a config-validation test: `tests/component_tests/<comp>/test_<comp>.py` (+ empty `__init__.py`) importing the validator and asserting remap + `pytest.raises(Invalid)` on the collision case (a config specifying both old and new key must raise, not silently drop one). Model on `tests/component_tests/aqi/test_aqi.py`.
- **Type-hint EVERYTHING** (a maintainer enforces this on review, twice this session). Validators: `def _v(config: ConfigType) -> ConfigType:` (`from esphome.types import ConfigType`). Test functions too: `def test_x(old_key: str, new_key: str) -> None:` — even though older tests like `aqi/test_aqi.py` lack hints, that's not the current bar. Add hints up front to avoid a review round-trip.
- **Local test/lint venv:** the pre-commit `pylint` hook and running `tests/component_tests/` both need tools installed into `esphome-venv` and its `Scripts` on PATH: `pylint==4.0.6`, `pytest==9.1.1` (+ pins in `requirements_test.txt`). Run component tests with `PYTHONPATH=<worktree> python -m pytest tests/component_tests/<comp>/ -q`.
- **C++ logging conventions** (a maintainer enforced these across 3 review rounds on the sen5x model PR, 2026-07-21; canonical doc: developers.esphome.io/architecture/logging/): messages terse, no explanatory caveat sentences (those go in the docs PR), no near-duplicate format strings (each unique string costs flash); no setup-time `ESP_LOGE` for failures that `error_code_` already surfaces via `dump_config` - set the error code and `mark_failed()` silently. Macro split: `LOG_STR("x")` only for `LogString*` values crossing function boundaries (unwrap at the log site with `LOG_STR_ARG`); a literal created and consumed inline in one log statement uses `LOG_STR_LITERAL("x")` directly (it IS `LOG_STR_ARG(LOG_STR(x))`). Runtime-compared string constants (e.g. strncmp product names) should use flash storage + flash compare helpers on ESP8266-supporting components - acceptable as a followup PR if flagged.
- **AGENTS.md mandates the walrus for config access in `to_code`:** `if (x := config.get(CONF_X)) is not None: cg.add(var.set_x(x))` - the `if CONF_X in config:` + `config[CONF_X]` form is their documented "Bad" example. Read the repo's AGENTS.md before pushing; it is long and opinionated (heap rules, container choices, callback patterns).
- **Review babysitting flow:** after fixing a review comment, reply in-thread ("Done in <sha>") and resolve the thread via GraphQL `resolveReviewThread`; leave reviewer "followup PR" notes unresolved as their marker. Fork-PR authors CANNOT re-request review via REST/GraphQL (404/FORBIDDEN) - only the UI button next to the reviewer's name, which is Brandon's click. The Kōan bot (`esphbot`) re-reviews on every push and its non-blocking suggestions may be declined with a short rationale comment; never invoke `@esphbot rebase` (it pushes its own fixes). When a bot suggestion contradicts what a human maintainer asked for in the same review, the human wins.

### esphome docs (esphome.io)

- The docs repo is now **`esphome/esphome.io`** (Astro/Starlight, `.mdx` under `src/content/docs/components/`), NOT the old Sphinx `esphome-docs`. Brandon's fork is still named **`bharvey88/esphome-docs`** (forked before the rename; `gh repo fork` reports "already exists"). Default branch is **`current`**.
- **Branch rule (PR template):** merge into **`next`** when the docs change matches an *unreleased* esphome code PR (e.g. a rename whose new key only exists after the firmware ships) - targeting `current` would show users a key their installed firmware lacks. Merge into **`current`** only for fixes to already-released behavior. Notes use GitHub `> [!NOTE]` blockquotes.
- Editing docs via `gh api PUT contents` (create fork branch from the target-branch SHA, PUT the file) sidesteps the repo's husky/npm pre-commit hooks; PR CI still validates. Two gotchas from the sen5x docs PR: the base64 body must go through `-F content=@file` (`-f` sends the literal `@path` string, 422 "content is not valid Base64"), and the file must be **LF-only** - their lint hard-fails on any CRLF ("File contains Windows newline"), and round-tripping content through Python stdout on Windows silently converts to CRLF. Strip `\r` and write bytes.

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

