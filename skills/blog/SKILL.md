---
name: blog
description: Write and publish a blog post on smarthomesellout.com for Brandon. Use whenever he asks to write a blog post, turn a session/project into a post, or work on smarthomesellout blog content.
---

# smarthomesellout Blog Post

Repo: `C:\Users\bharv\development\smarthomesellout` (Astro 6 + Bun + Cloudflare Workers). **Read the repo's CLAUDE.md first** - it owns the stack, schema-lock, and deploy rules. This skill owns the writing workflow and voice.

## Apollo disclosure (always)

Brandon works for Apollo Automation. Any post that names or discusses an Apollo device (CAST-1, radar/MTR, AIR-1, etc.) or Apollo the company MUST carry a disclosure that he works there. Put it as an italic line at the top of the post body, right after the frontmatter, before the first paragraph:

```
*Disclosure: I work for Apollo Automation. <device-context sentence>*
```

Base line is always `Disclosure: I work for Apollo Automation.` Add a short context sentence when the post is about a specific device ("The CAST-1 is one of our devices and this is firmware I work on.") or tie it to the mention ("The radar devices I mention below are ours."). Plain voice, no em dashes. This applies to incidental mentions too, not just posts that are about an Apollo product.

## Phase 1: Source material

Posts document something Brandon actually did. He often says "look at our previous chats about X" - search session transcripts and memory for the real details (actual numbers, actual commands, actual mistakes). Never pad with generic advice he didn't live through. The mistakes and dead ends ARE the content ("a couple things that wasted my time so they don't waste yours").

Drafts started on Brandon's laptop arrive under-cooked - that machine doesn't have these skills - so give any laptop-drafted post a full voice pass here before treating it as near-final.

## Phase 2: Voice (the part he rewrites every time it's wrong)

Load `writing-voice` for the general rules (no em dashes, banned tells, structural tells, the two-pass de-slop). The rules below are blog-specific on top of that. This is a personal blog, not Apollo, so it does NOT use `apollo-writing-style`.

Calibrate against this excerpt from a published post:

> My Home Assistant backups had quietly gotten huge. When I went looking for why, it was the recorder database. ... I'd already deleted a few obvious things before I really dug in, which knocked it down a bit, but it was still way bigger than it had any right to be. The thing that finally clicked is that I'd misunderstood what excludes even do.

Rules:
- First person, past tense, conversational. He's telling a friend what happened, not teaching a course.
- Terse, concrete, no metaphor. "Won't work properly," not "will go dark."
- Plain titles, not clever ones: "I cut my Home Assistant backups in half". Offer 2-4 title options before committing.
- Headings are plain statements ("Excludes only stop new data", "What I actually ran", "Where it landed").
- Numbers and specifics everywhere: "7GB down to about 3.6GB", "482 rows an hour", "10 to 20 minutes".
- It's fine to end sections with what he's NOT doing yet ("I'm not there yet").
- UI labels verbatim and bolded (**Developer Tools**, **Actions** tab).

## Phase 3: File format

`src/content/blog/YYYY-MM-DD-slug.md`. Frontmatter: `title`, `date`, `excerpt` (2-4 sentences, same voice, states the payoff), `cover` (optional, `/images/blog/<slug-or-name>.jpg`), `tags` (free-form human-readable like `home assistant`, lowercase), `draft`, `affiliate`. The Zod schema in `src/content.config.ts` and `public/admin/config.yml` must stay in sync - don't add fields.

**Cover image.** Brandon supplies his own (usually a phone photo from Downloads, 3-5 MB). Don't ship it raw and don't just leave a placeholder - resize it yourself:

1. Copy/resize into `public/images/blog/<name>.jpg`, **1600px on the long edge, JPEG quality 80, EXIF orientation applied** (`ImageOps.exif_transpose`). That lands ~300-700 KB, matching the existing covers. PIL is available at `C:\esphome-build\venv\Scripts\python.exe`.
2. Reference it in frontmatter as `cover: /images/blog/<name>.jpg`. It renders as the post header (`BlogLayout.astro`). Do NOT put it inline in the body.
3. The OG/social image is separate - auto-generated per slug at build by `scripts/gen-og.ts` into `public/og/` (gitignored). You don't supply it; just confirm the social embed renders during the live check.

Inline body images (screenshots etc.): Brandon supplies those; leave a clear placeholder comment and tell him what you need.

**Heads-up on `bun run check` on Windows:** `core.autocrlf=true` with no `.gitattributes` means biome flags every pre-existing file for CRLF line endings locally (the `␍` diff). That is Windows-only noise - the same tree passes on Linux CI, and git commits your post as LF. Don't "fix" those files. Just confirm your own post isn't in the error list (`bun x biome check <your-post>.md`) and that `bun run build` passes.

## Phase 4: Workshop

Show him the full draft in chat before committing. Expect de-slop rounds - he will flag anything that "reads like AI" and means it. Workshop wording with him rather than defending the draft.

## Phase 5: Ship and verify

1. `bun run check` and `bun run build` must pass (CI runs the same).
2. Commit straight to `main` (no staging). Personal repo: no Claude footer, no co-author trailer.
3. GitHub Actions deploys on push. Wait for the run, then **verify live**: fetch the post URL on smarthomesellout.com, and check the OG image / social embed renders. "Committed" is not "shipped".
