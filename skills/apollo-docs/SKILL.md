---
name: apollo-docs
description: Full workflow for editing and publishing the Apollo Automation wiki (ApolloAutomation/docs, wiki.apolloautomation.com, mkdocs-material). Use for ANY task touching the Apollo docs/wiki - editing pages, sidebar/nav changes, new tutorials, fixing links, or when Brandon says "ship it", "do our usual", "merge and sync".
---

# Apollo Docs: Edit and Ship

The complete ritual for ApolloAutomation/docs work. Follow every phase. Also load the `apollo-writing-style` skill before writing any wiki content.

## Phase 1: Fresh workspace (NEVER skip)

Stale clones are the #1 recurring failure. Never reuse an existing clone in `C:\Users\bharv\development` or an old temp dir without syncing it first.

1. Create a fresh worktree or clone of the **latest `dev` branch** of `ApolloAutomation/docs` (a per-session temp dir or git worktree is preferred).
2. Confirm you are on latest `dev` (`git pull`) before editing anything. Brandon sometimes edits via CloudCannon, so a clone from even earlier the same day can be stale. Do NOT merge or sync CloudCannon PRs yourself - Brandon handles CloudCannon syncing manually.

## Phase 2: Edit and preview

- Edit markdown / `mkdocs.yaml` per the request, following `apollo-writing-style`.
- Starter-kit pages require the community CTA snippet - check it's present before committing (the repo's AGENTS.md enforces this).
- Run `mkdocs serve` locally and give Brandon the `http://127.0.0.1:8000/...` deep link to the exact page changed. Iterate with him.
- Track the serve process: **always stop `mkdocs serve` after shipping** or when Brandon says he's done reviewing.
- After editing, run `mkdocs build` once and check for new `WARNING`/`INFO` link issues on the pages you touched (ignore the pre-existing `libcairo`/social-card errors - that's a local env thing).

### Editing gotchas (these keep biting)

- **Never stack admonitions.** Two or more admonitions back-to-back is Brandon's most-repeated docs correction ("no more 3 green boxes"). Prefer **annotations** at the end of the relevant sentence for asides; use ONE admonition only when it truly earns the visual weight; put long code in pre-collapsed collapsible blocks. Note annotations render via client-side JS - `curl`/WebFetch shows a literal `(1)`, so verify them in the mkdocs serve preview, not by fetching HTML.
- **Annotations inside numbered lists need 4-space content indent.** Use two spaces after the marker (`3.  text`) so content starts at column 4, with `{ .annotate }` and the annotation's own `1.` list indented 4 spaces. A 3-space indent parses the annotation as EXTRA list items (readers see phantom steps and a literal `(1)`) - this shipped broken once. Grepping the HTML for `class="annotate"` is NOT enough to catch it; verify structure (the annotation `<ol>` nested inside the `<li>`, top-level `li` count = step count) or check `.md-annotation` count in a Playwright-driven browser against the local serve.
- **`mkdocs serve` on Windows misses file changes.** The watcher silently skips rebuilds, so a stale preview does not mean the edit is wrong. If a refresh doesn't show your change, kill and restart `mkdocs serve` instead of debugging the page.
- **Setup pages stay lean.** Conceptual depth and explanation live on the Learn the Basics pages; a product's setup page links there instead of re-teaching.
- **Worktree git discipline:** worktrees carry stale `origin/*` refs (fetch first), never `git add -A` (stage named files only), and fix a bad pushed commit with a cleanup commit, not a force-push.
- **Don't bulk-edit Markdown with `sed -i`.** On this repo `sed -i` rewrites line endings (CRLF→LF) on *every* file it scans, even no-match files, producing dozens of spurious diffs. Use the Edit/Write tools instead. If you must run a batch command, `git add` only the files you actually changed and confirm the real diff with `git diff --ignore-all-space --stat` before committing.
- **Snippet-included pages need root-absolute links.** Any page that is (or might be) pulled into another via `--8<-- "...:N:"` - `homey/` pages, or a product page mirrored onto a sibling (e.g. TEMP-1 → TEMP-1B) - must use root-absolute paths for images and cross-page links: `/assets/foo.webp` and `/products/.../page.md`, NOT relative `../../...`. Relative paths resolve against the *including* page's folder and 404. This is the #1 source of "link/image not found" warnings. To mirror a page onto a sibling product, snippet-include it (`--8<-- "products/<src>/...:N:"`, `:5:` skips the 4-line front matter, `:7:` also skips the H1 so you can write your own H1 + a product-specific note) rather than duplicating the content. **Always snippet the ORIGINAL source page, never another wrapper** - chained wrappers break. Mirror the source's directory structure on the destination side, and skip adding redirects for pages that were only just published (nothing links to them yet).

## Phase 3: Ship (the full chain, no stopping halfway)

When Brandon approves ("ship it", "let's merge", "do our usual"), complete ALL of these steps yourself. Do NOT stop after creating the PR and ask him to merge - he has said many times that you should do the whole chain.

1. Branch + commit. Apollo repos (including this docs repo) require a `🤖 Generated with [Claude Code](https://claude.com/claude-code)` footer on commits, per the repo owner. Never add a `Co-Authored-By: Claude` trailer.
2. Open PR against `dev`.
3. Squash-merge the `dev` PR: `gh pr merge <N> --squash --admin --delete-branch`. The `check-source` required status check is flaky/queued forever, so `--admin` bypasses it.
4. **Immediately** open a `dev → main` sync PR. The wiki only publishes from `main`, but you can NEVER merge directly to `main` - the sync PR reports "not mergeable" because `main` requires the head up to date and carries merge commits `dev` lacks. Fix it with GitHub's "Update branch": `gh api -X PUT repos/ApolloAutomation/docs/pulls/<N>/update-branch`, wait a few seconds, then merge. Plain `gh pr merge <N> --merge` sometimes works, but `main`'s branch policy often still blocks it ("base branch policy prohibits the merge") - in that case use `gh pr merge <N> --merge --admin`. Even `--admin` can transiently fail right after the update-branch with `Required status check "check-source" is queued` - wait ~15s and re-run the exact same `--merge --admin`; the second try goes through. The local post-merge step may print `fatal: 'dev' is already used by worktree` - harmless, the remote merge already happened; verify with `gh pr view <N> --json state`.
5. The deploy workflow on `main` takes ~6 min. Verify the change is live at `wiki.apolloautomation.com` (fetch the page).

## Phase 4: Cleanup

- Kill any running `mkdocs serve`.
- Remove the temp worktree/clone if you created one.

## Hard rules

- This flow is for the **docs repo only**. Never edit Apollo product repos (MSR-2, AIR-1, etc.) as part of a docs task.
- Product repos have a different flow: feature branch → PR to `beta` → STOP and wait for a maintainer. Never self-merge product repos.
- Don't suggest "flagging a maintainer" - Brandon routes things himself.
