---
name: writing-voice
description: General prose voice and anti-AI-tells rules for ANY user-facing writing for Brandon - blog posts (personal or Apollo), wiki pages, GitHub issues/PRs, community/forum/Discord replies, README and commit/PR descriptions - plus the rules for code comments Claude writes in any language. Load alongside any writing task, and before adding or editing a comment in source. Apollo-specific formatting lives in apollo-writing-style; blog workflow lives in blog; auditing comments already in a codebase is the comment-review skill.
---

# Brandon's Writing Voice

General prose rules. They apply to everything user-facing, personal or work. Re-taught across dozens of sessions.

## Voice

- **Never use em dashes.** Use commas, periods, or "X to Y" for ranges.
- Terse beats thorough. Cut bulk before showing Brandon.
- Use contractions. "Don't", not "do not", unless emphasis demands it.
- **US spellings.** behavior, color, labeled, canceled - not behaviour, colour, labelled. Brandon has corrected this; watch for it creeping into longer prose.

### Banned tells (word/phrase level)

- "delve", "realm", "underscore", "meticulous", "crucial", "robust", "seamless", "leverage", "game-changer", "elevate", "supercharge"
- "it's not X, it's Y" / "isn't just X" negative-parallel constructions, and "no X, no Y, no Z" triplet denials
- "I'm most proud of..." and similar canned-reflection phrases
- "here's what actually...", "here's the thing", "the best part?", "let's dive in", "let's explore", "in today's...", "rapidly evolving", "whether you're a..."
- Rhetorical-question hooks and triadic punchlines
- "serves as", "stands as", "acts as" used to dodge a plain "is"
- Elegant variation: cycling synonyms for the same noun across a paragraph (the sensor / the device / the unit / the product). Pick one word and repeat it.
- Sycophantic openers and chatbot artifacts: "Great question!", "I hope this helps!", "Happy to help!", "Certainly!"
- Hedge stacks: "could potentially possibly", "may sometimes help to". One qualifier max.

### Structural tells (these read as AI even with clean words)

- The "**Bold term:** explanation sentence" list where every item has identical shape. Most recognizable AI pattern there is. Vary list items or use prose.
- Paragraphs of near-identical length and sentences of near-identical rhythm. Mix in short ones.
- Sweeping context-setting openers and summary closers. Start and end on substance.
- Signposting ("Now let's turn to..."). Just make the point.
- **Troubleshooting written symptom-first as a run-on.** "Buttons do the wrong thing, so check which presets are saved" reads backwards and Brandon has called it out. Use a conditional: "If the buttons control the wrong things, check what you have saved in presets 1 through 4." Same for every entry in the list.
- **Negative-definition asides** ("X cannot describe it", "the older model could not"). Say what the thing does, not what the other thing lacks: "WLED-MM can only chain panels into a single row. You need WLED 16.0.1 or newer for a 2x2 grid."

### Don't over-correct (what is NOT AI)

De-slopping removes filler, not personality. Stripping too hard makes prose bland, which is its own tell.

- A *single* em dash, formal vocabulary, or clean grammar is not proof of AI. The patterns above only matter when they cluster. Don't hunt one isolated instance into a worse sentence.
- Preserve human signals: specific numbers and part names, an unresolved caveat, a dated reference ("since the 2024.x firmware"), a genuine aside, a blunt opinion.
- Sentence variety is the goal, not uniform short sentences. A long sentence next to a three-word one reads human. Three medium sentences in a row do not.

## Code comments

Prose rules above cover writing aimed at people reading a page. These cover comments in source, which have a different failure mode: not slop, but restating what the code already says.

Adapted from the [im-only-human](https://github.com/AlCalzone/im-only-human) rules. The full version, with the reasoning and examples behind each rule, is bundled at `C:\Users\bharv\.claude\skills\comment-review\references\im-only-human-comments-style.md`. Read it when a call is borderline. Don't restate it here; it gets updated upstream.

- Most lines need no comment. Add one only for a non-obvious why, sitting next to the line it explains. If the names and the operation already show the intent, write nothing.
- Same test when editing an existing comment: would deleting it lose a fact the code can't show? A comment that only reassures the reader a retry or fallback is safe protects them from nothing. Delete it rather than polishing it.
- No history, no issue numbers, no "previously". That's what git blame and the PR body are for.
- Don't teach the language. That `setInterval` takes milliseconds belongs in the reply, not the file. A less-common spec guarantee the code's correctness actually depends on, like `Map` iterating in insertion order right above code relying on it, does belong.
- Imperative mood for an action the code takes right there: `Clamp`, `Reject`, `Copy`. Not `Clamps`, and not a subject-less fragment leaning on the declaration below it. A class-level or design comment stating a property is exempt.
- State the rule, not the disaster it prevents. `// Clamp to 0xFF because the device rejects larger values`, not `// Values above 0xFF would be rejected, so clamp to 0xFF`.
- No "X, not Y" contrast. State the true half.
- If the comment exists to stop a future tidy-up, say "must". A neutral description of current behavior looks safe to delete.
- One clause per sentence, with one exception: an action plus one trailing why joined by "so" or "because" is fine. Three or more facts chained by any mix of comma, colon, semicolon, "and", "which" gets split. This is stricter than the prose rules above, where sentence variety is the goal. Comments are scanned, not read.
- Capitalize the first word. No trailing period on a one-liner. No capitalized NOT/NONE for emphasis.
- `//` or `#` for ordinary comments, even across several lines. Reserve `/* */` for a short inline note with code continuing on the same line; it churns more in diffs.

## Process

- Write the draft, then do a de-slop pass against the lists above.
- Then do a second read asking one question: "does this still read as obviously AI-generated?" Fix what survived the first pass.
- If sentences could be reordered without anyone noticing, they're filler. Cut them.
- Stop there. Don't keep "humanizing" past the point of natural, see the over-correct rules above.
