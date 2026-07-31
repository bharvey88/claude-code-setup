---
name: apollo-writing-style
description: Apollo-specific formatting and naming conventions for Apollo Automation wiki content, GitHub issues/PRs, and community answers - apps/App Store naming, verbatim UI labels, mkdocs-material sidebar structure. Use whenever writing Apollo-facing prose for Brandon - wiki pages, issue text, forum/Discord replies, README content. General prose voice (no em dashes, anti-AI-tells, de-slop pass) lives in writing-voice - load that too.
---

# Apollo Writing Conventions

These are the Apollo/wiki-specific rules. For general prose voice (no em dashes, banned tells, structural tells, de-slop pass), load `writing-voice` - it applies here too.

- Check any repo `STYLE-GUIDE.md` and follow it.

## Naming and labels

- Home Assistant "add-ons" are now called **"apps"** / **"App Store"** in Apollo wiki content. That's software only - Apollo *hardware* add-ons (sensor boards, expansions) stay "add-on".
- **UI labels are verbatim.** Text inside bolded UI labels (button names, menu paths like **Add** or **Settings → Devices**) must exactly match the live GUI. Never reword them when editing docs.
- **Never invent a UI label you haven't seen.** Writing a plausible-sounding label from upstream docs or inference ships wrong instructions that read as authoritative. Whole sections have been fabricated this way: a "Scrolling Text Tool" tab that is actually **Scrolling Text**, a "color palette" control that does not exist, a "Grid (across x tall)" field really labelled **rows x cols**. When you cannot verify a label, describe the action instead ("set the panel count") and tell Brandon which strings you could not confirm - he can usually screenshot it in seconds. A screenshot or screen recording is worth more than any amount of upstream documentation.
- **Existing wiki pages are NOT a source of truth for UI labels.** Older product pages carry labels from earlier Home Assistant versions. Copying one forward ships a stale instruction AND spreads it to the new page. Caught 2026-07-31: the R-PRO-1 page says click `"1 device"` below the device, wording that predates the current integrations UI; it got copied onto CAST-1 pages and Brandon flagged it ("the 1 device thing is old and you switched to that?"). Reuse the *structure* of an old page freely, but re-verify every UI string against the live GUI or describe the action instead.
- The starter kit is "ESPHome Starter Kit" in prose; "ESK-1" appears only in literal strings (hostnames, SSIDs, `apollo-esk-1`).
- **Credit community members by name** when their shared setup/work is used ("Thanks to Donovan for sharing his setup"), never "a community member" - that reads as AI slop. (Apollo staff/maintainers stay unnamed in public content, per global rules.)
- For user-visible copy with more than one reasonable phrasing, present 2-4 wording options and let Brandon pick.

## Wiki structure (mkdocs-material)

- **Keep the sidebar short.** Only h2/h3 appear in the sidebar (toc_depth 3). Demote section headings to **h4** when they shouldn't appear in the sidebar. More than ~6 sidebar entries on a page is too many - tighten. Do this while writing the page, not after Brandon points at it: orienting headings like "Which One Do I Have?" or "What Next" are exactly the ones that belong at h4.
- Sidebar entries must be succinct noun phrases, never long partial sentences. Headings are plain statements, no metaphor.
- Use mkdocs-material features freely: annotations, content tabs, collapsible blocks, snippets. Brandon prefers **annotations over admonitions** - and never stack admonitions back-to-back (see `apollo-docs` gotchas). One caveat: the CloudCannon GUI can't edit annotations, so on pages Brandon maintains through CloudCannon, mention the limitation and let him choose.
- URLs the reader should visit are hyperlinks with an imperative lead-in ("Open the [Device Builder](...)"), never bare URLs in code blocks.
- **Fill in real values in copy-paste examples, don't use placeholder variables.** `entity_id: tts.your_tts_engine` reads as confusing filler; `entity_id: tts.piper` reads as an instruction, and link the engine's docs. For the parts that genuinely differ per device (the MAC suffix in `media_player.apollo_cast_1_722124_...`), keep the concrete value and add ONE annotation saying where to find theirs. Brandon, 2026-07-31: "this is confusing.. we should fill in piper like".
- Link to Home Assistant UI via My Home Assistant links (my.home-assistant.io/create-link). Redirect gotchas: `navigate` is NOT a valid redirect (404s); `supervisor_ingress` isn't supported on all HA versions - use `supervisor_addon` (info page, one extra click, always works). The `automations` redirect only opens the list; no create-new-automation redirect exists.
- Audience is beginners: short sentences, no unexplained jargon.

## Tone by destination

Docs are terse and plain. **Community posts (forum, social, giveaways) are warm, upbeat, celebratory** - a different register than the wiki, same anti-AI-tells rules.

## Blog (smarthomesellout)

Brandon's personal blog. It has its own skill with the full workflow and a voice sample - load `blog` instead. The general voice rules in `writing-voice` apply there too.
