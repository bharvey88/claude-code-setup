---
name: apollo-writing-style
description: Apollo-specific formatting and naming conventions for Apollo Automation wiki content, GitHub issues/PRs, and community answers - apps/App Store naming, verbatim UI labels, mkdocs-material sidebar structure. Use whenever writing Apollo-facing prose for Brandon - wiki pages, issue text, forum/Discord replies, README content. General prose voice (no em dashes, anti-AI-tells, de-slop pass) lives in writing-voice - load that too.
---

# Apollo Writing Conventions

These are the Apollo/wiki-specific rules. For general prose voice (no em dashes, banned tells, structural tells, de-slop pass), load `writing-voice` - it applies here too.

- Check any repo `STYLE-GUIDE.md` and follow it.

## Naming and labels

- Home Assistant "add-ons" are now called **"apps"** / **"App Store"** in Apollo wiki content.
- **UI labels are verbatim.** Text inside bolded UI labels (button names, menu paths like **Add** or **Settings → Devices**) must exactly match the live GUI. Never reword them when editing docs.

## Wiki structure (mkdocs-material)

- **Keep the sidebar short.** Only h2/h3 appear in the sidebar (toc_depth 3). Demote section headings to **h4** when they shouldn't appear in the sidebar.
- Sidebar entries must be succinct noun phrases, never long partial sentences.
- Use mkdocs-material features freely: annotations, admonitions, content tabs, collapsible blocks, snippets. Brandon likes annotations - use them where they fit. One caveat: the CloudCannon GUI can't edit annotations, so on pages Brandon maintains through CloudCannon, mention the limitation and let him choose.
- Link to Home Assistant UI via My Home Assistant links (my.home-assistant.io/create-link).
- Audience is beginners: short sentences, no unexplained jargon.

## Blog (smarthomesellout)

Brandon's personal blog. It has its own skill with the full workflow and a voice sample - load `blog` instead. The general voice rules in `writing-voice` apply there too.
