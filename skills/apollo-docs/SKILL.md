---
name: apollo-docs
description: Full workflow for editing and publishing the Apollo Automation wiki (ApolloAutomation/docs, wiki.apolloautomation.com, mkdocs-material). Use for ANY task touching the Apollo docs/wiki - editing pages, sidebar/nav changes, new tutorials, fixing links, or when Brandon says "ship it", "do our usual", "merge and sync".
---

# Apollo Docs: Edit and Ship

The complete ritual for ApolloAutomation/docs work. Follow every phase. Also load the `apollo-writing-style` skill before writing any wiki content.

## Phase 1: Fresh workspace (NEVER skip)

Stale clones are the #1 recurring failure. Never reuse an existing clone in `C:\Users\bharv\development` or an old temp dir without syncing it first.

**Always a worktree, never a second clone.** The canonical clone is `C:\Users\bharv\development\apollo-docs` and its `.git` alone is ~3 GB, larger than the 1.85 GB of content. A `git clone` duplicates all of that; a worktree shares it and costs only the working tree. Eleven duplicate clones quietly ate 48 GB of `C:\tmp` before this rule existed.

**Everything is namespaced by a session key** so parallel sessions never collide. Pick a short task-derived key (e.g. `docs-nox-faq`) and use it throughout:

| | |
|---|---|
| worktree | `C:\tmp\<key>` |
| scratch | `C:\tmp\_mkdocs-scratch\<key>\` |
| port | first free from 8000 upward |

1. **Preflight** (safe to run with other sessions live - it only removes provable orphans):

   ```powershell
   $sc = "C:\tmp\_mkdocs-scratch"
   New-Item -ItemType Directory -Force $sc | Out-Null
   foreach ($d in (Get-ChildItem $sc -Directory -ErrorAction SilentlyContinue)) {
     $j = Join-Path $d.FullName "session.json"
     $alive = $false
     if (Test-Path $j) {
       $s = Get-Content $j -Raw | ConvertFrom-Json
       if (Get-Process -Id $s.pid -ErrorAction SilentlyContinue) { $alive = $true }
     } elseif ($d.LastWriteTime -gt (Get-Date).AddMinutes(-2)) {
       $alive = $true   # a sibling session mid-startup, before it wrote session.json
     }
     if (-not $alive) { Remove-Item -LiteralPath $d.FullName -Recurse -Force }
   }
   ```

   Never kill a `mkdocs serve` you did not start, and never sweep a scratch dir whose recorded PID is still alive - that is another session's live preview.

2. Create the worktree off the **latest `dev`** (fetch first; worktrees inherit stale `origin/*` refs):

   ```powershell
   $canon = "C:\Users\bharv\development\apollo-docs"
   git -C $canon fetch origin
   git -C $canon worktree add "C:\tmp\<key>" -b <branch-name> origin/dev
   ```

3. Confirm you are on latest `dev` before editing anything. Brandon sometimes edits via CloudCannon, so a clone from even earlier the same day can be stale. Do NOT merge or sync CloudCannon PRs yourself - Brandon handles CloudCannon syncing manually.

## Phase 2: Edit and preview

- Edit markdown / `mkdocs.yaml` per the request, following `apollo-writing-style`.
- Starter-kit pages require the community CTA snippet - check it's present before committing (the repo's AGENTS.md enforces this).
- **Start `mkdocs serve` with a contained scratch dir and a free port.** `mkdocs serve` hardcodes `tempfile.mkdtemp(prefix='mkdocs_')` ([serve.py:40](https://github.com/mkdocs/mkdocs/blob/master/mkdocs/commands/serve.py)) with no config override, and each build there is ~2.1 GB. Redirecting `TMP`/`TEMP` is the only way to know where it landed:

  ```powershell
  $key = "<key>"
  $scratch = "C:\tmp\_mkdocs-scratch\$key"
  New-Item -ItemType Directory -Force $scratch | Out-Null
  $port = 8000
  while (Get-NetTCPConnection -State Listen -LocalPort $port -ErrorAction SilentlyContinue) { $port++ }
  $env:TMP = $scratch; $env:TEMP = $scratch
  # launch serve in the background, then record it:
  #   mkdocs serve -a 127.0.0.1:$port
  @{ pid = <serve-pid>; port = $port; worktree = "C:\tmp\$key" } |
    ConvertTo-Json | Set-Content (Join-Path $scratch "session.json") -Encoding utf8
  ```

  Give Brandon the `http://127.0.0.1:<port>/...` deep link to the exact page changed, and **state the port** - with parallel sessions he may have more than one preview open. Iterate with him.
- Track the serve process: **always stop `mkdocs serve` after shipping** or when Brandon says he's done reviewing. Stopping means kill *and* sweep (see Phase 4) - a killed serve never runs its own `finally: shutil.rmtree`, so the ~2.1 GB stays behind.
- **Do not run a separate `mkdocs build` to check links.** `serve` performs a full (non-dirty) build and logs the identical `WARNING`/`INFO` link diagnostics on every rebuild, so read them from the serve output. A separate build dumped another ~2 GB per session; twelve such dumps once held 24.8 GB. If you genuinely need `--strict` gating, build into `$scratch\build` and delete it in the same step. Ignore the pre-existing `libcairo`/social-card errors either way - that's a local env thing.

### Editing gotchas (these keep biting)

- **Never stack admonitions.** Two or more admonitions back-to-back is Brandon's most-repeated docs correction ("no more 3 green boxes"). Prefer **annotations** at the end of the relevant sentence for asides; use ONE admonition only when it truly earns the visual weight; put long code in pre-collapsed collapsible blocks. Note annotations render via client-side JS - `curl`/WebFetch shows a literal `(1)`, so verify them in the mkdocs serve preview, not by fetching HTML. The `.md-annotation` class is added at runtime, so **a zero count in built HTML proves nothing** and is not evidence the annotation is broken; a known-good page scores zero the same way. Only a Playwright check against the running serve tells you.
- **Never put two annotation markers on one line.** `text (1) (2)` is ugly and Brandon has called it out ("i dont like double annotations lol"). One marker per step or paragraph. If a step needs a second aside, either move it onto a different step (annotation numbering restarts per block, so each gets its own `(1)`), write it as plain prose, or promote it to a single admonition when the page has no other admonition to stack against.
- **Annotations inside numbered lists need 4-space content indent.** Use two spaces after the marker (`3.  text`) so content starts at column 4, with `{ .annotate }` and the annotation's own `1.` list indented 4 spaces. A 3-space indent parses the annotation as EXTRA list items (readers see phantom steps and a literal `(1)`) - this shipped broken once. Grepping the HTML for `class="annotate"` is NOT enough to catch it; verify structure (the annotation `<ol>` nested inside the `<li>`, top-level `li` count = step count) or check `.md-annotation` count in a Playwright-driven browser against the local serve.
- **`mkdocs serve` on Windows misses file changes.** The watcher silently skips rebuilds, so a stale preview does not mean the edit is wrong. If a refresh doesn't show your change, kill and restart `mkdocs serve` instead of debugging the page. Restart it after *every* round of edits before giving Brandon a link, and confirm the new text is actually served (`curl <url> | grep`) rather than trusting `mkdocs build` output.
- **An orphaned `mkdocs serve` can hold a port and serve a stale build for hours.** A serve from an earlier session survives that session ending, so a new one logs "Serving on ..." while the old process still answers. Symptom: pages you just created 404 and pages you deleted still load, on a build that was clean. The per-session port assignment in Phase 2 avoids this by construction. To inspect, use `Get-CimInstance Win32_Process -Filter "Name like '%python%'" | Where-Object { $_.CommandLine -like '*mkdocs*' }` - but **do NOT blanket-kill every match.** With parallel sessions that kills Brandon's other live preview. Kill only the PID in your own `session.json`; treat every other match as someone else's until its recorded PID proves dead.
- **`navigation.indexes` is inert in this repo** because `toc.integrate` is enabled and Material disables one when the other is set. A nav section header therefore cannot double as its own page. If you want a section whose header is a page, you must give it a child entry, so name that child something distinct (`Set Up WLED-MM`, not a second `Getting Started`) or duplicate labels appear in the sidebar.
- **Setup pages stay lean.** Conceptual depth and explanation live on the Learn the Basics pages; a product's setup page links there instead of re-teaching.
- **Worktree git discipline:** worktrees carry stale `origin/*` refs (fetch first), never `git add -A` (stage named files only), and fix a bad pushed commit with a cleanup commit, not a force-push.
- **Don't bulk-edit Markdown with `sed -i`.** On this repo `sed -i` rewrites line endings (CRLF→LF) on *every* file it scans, even no-match files, producing dozens of spurious diffs. Use the Edit/Write tools instead. If you must run a batch command, `git add` only the files you actually changed and confirm the real diff with `git diff --ignore-all-space --stat` before committing.
- **Snippet-included pages need root-absolute links.** Any page that is (or might be) pulled into another via `--8<-- "...:N:"` - `homey/` pages, or a product page mirrored onto a sibling (e.g. TEMP-1 → TEMP-1B) - must use root-absolute paths for images and cross-page links: `/assets/foo.webp` and `/products/.../page.md`, NOT relative `../../...`. Relative paths resolve against the *including* page's folder and 404. This is the #1 source of "link/image not found" warnings. To mirror a page onto a sibling product, snippet-include it (`--8<-- "products/<src>/...:N:"`, `:5:` skips the 4-line front matter, `:7:` also skips the H1 so you can write your own H1 + a product-specific note) rather than duplicating the content. **Always snippet the ORIGINAL source page, never another wrapper** - chained wrappers break. Mirror the source's directory structure on the destination side, and skip adding redirects for pages that were only just published (nothing links to them yet).

## Phase 3: Ship (the full chain, no stopping halfway)

When Brandon approves ("ship it", "let's merge", "do our usual"), complete ALL of these steps yourself. Do NOT stop after creating the PR and ask him to merge - he has said many times that you should do the whole chain.

1. Branch + commit. Apollo repos (including this docs repo) require a `🤖 Generated with [Claude Code](https://claude.com/claude-code)` footer on commits, per the repo owner. Never add a `Co-Authored-By: Claude` trailer. **From a `C:\tmp` worktree the PreToolUse hook blocks that footer**, because the path doesn't look like an Apollo repo. Make the repo apparent in the same command (`git remote get-url origin` first, or a `# ApolloAutomation/docs` comment) and it passes. Also confirm `git config user.email` in the worktree: a fresh worktree can inherit the bare `bharvey88@users.noreply.github.com`, and it must be the ID-prefixed form.
2. Open PR against `dev`.
3. Squash-merge the `dev` PR: `gh pr merge <N> --squash --admin --delete-branch`. The `check-source` required status check is flaky/queued forever, so `--admin` bypasses it.
4. **Immediately** open a `dev → main` sync PR. The wiki only publishes from `main`, but you can NEVER merge directly to `main` - the sync PR reports "not mergeable" because `main` requires the head up to date and carries merge commits `dev` lacks. Fix it with GitHub's "Update branch": `gh api -X PUT repos/ApolloAutomation/docs/pulls/<N>/update-branch`, wait a few seconds, then merge. Plain `gh pr merge <N> --merge` sometimes works, but `main`'s branch policy often still blocks it ("base branch policy prohibits the merge") - in that case use `gh pr merge <N> --merge --admin`. Even `--admin` can transiently fail right after the update-branch with `Required status check "check-source" is queued` - wait ~15s and re-run the exact same `--merge --admin`; the second try goes through. The local post-merge step may print `fatal: 'dev' is already used by worktree` - harmless, the remote merge already happened; verify with `gh pr view <N> --json state`.
5. The deploy workflow on `main` takes ~6 min. Verify the change is live at `wiki.apolloautomation.com` (fetch the page). **A green `ci` run is not the same as a published site.** The workflow's `deploy` job only hands the artifact to GitHub Pages; Pages then runs its own build that starts a few minutes later and takes several more. During that window new pages 404 and deleted pages still load, which looks like a failed deploy but isn't. Check the real state with `gh api repos/ApolloAutomation/docs/pages/builds --jq '.[0] | "\(.status) \(.created_at)"'` and wait for `built` before fetching pages. Verify both directions: new URLs return 200 *and* removed URLs return 404.

## Phase 4: Cleanup (a docs session must leave nothing behind)

Skipping this is what turned `C:\tmp` into 81 GB. Run every step and verify, touching only your own session key.

```powershell
$key = "<key>"; $scratch = "C:\tmp\_mkdocs-scratch\$key"; $wt = "C:\tmp\$key"
$canon = "C:\Users\bharv\development\apollo-docs"

# 1. stop only YOUR serve, then sweep its build dirs (a killed serve cannot clean up after itself)
$s = Get-Content (Join-Path $scratch "session.json") -Raw | ConvertFrom-Json
Stop-Process -Id $s.pid -Force -ErrorAction SilentlyContinue
Remove-Item -LiteralPath $scratch -Recurse -Force -ErrorAction SilentlyContinue

# 2. remove the worktree properly - this REFUSES if the tree is dirty, which is the safety gate
git -C $canon worktree remove $wt
git -C $canon worktree prune

# 3. verify, do not assume
if (Test-Path $wt) { Write-Output "STILL THERE: $wt" }
if (Test-Path $scratch) { Write-Output "STILL THERE: $scratch" }
git -C $canon worktree list
```

- If `worktree remove` refuses because the tree is dirty, that means uncommitted work. **Surface it to Brandon; never `--force` past it.** Salvage with `git format-patch --binary` (a few KB) before removing.
- Also delete a stale `site/` in the canonical clone if a build ever landed there - it is gitignored, so it accumulates invisibly at ~2 GB.
- `Remove-Item` on the literal `C:\tmp` root is blocked by a PreToolUse hook. Explicit subpaths (`C:\tmp\<key>`) pass fine, so always target the full path.

## Hard rules

- This flow is for the **docs repo only**. Never edit Apollo product repos (MSR-2, AIR-1, etc.) as part of a docs task.
- Product repos have a different flow: feature branch → PR to `beta` → STOP and wait for a maintainer. Never self-merge product repos.
- Don't suggest "flagging a maintainer" - Brandon routes things himself.
