---
name: supercharge
description: Use when Brandon says "/supercharge", "supercharge this prompt", "make this more ambitious", "level up this prompt", "how would an expert ask this", or pastes a prompt or task and wants it rewritten into a bigger, deeper version before it runs. Based on Felix Rieseberg's "How to be more ambitious" (altitude, depth, range).
---

# Supercharge a Prompt

## Overview

Rewrite Brandon's prompt so the model aims higher, not just longer. Three kinds of ambition do the work (Speed, "same task faster", is the default and gets skipped):

- **Altitude:** ask for the outcome behind the task, not the task.
- **Depth:** do it the way the best person in the field would, with their instruments and raw material, judged by something other than the model.
- **Range:** bring in fields the task doesn't obviously need, for what they *do*, not how they talk.

A longer prompt is not a more ambitious one. Adding steps, lists of suspects and "be thorough" is Speed in disguise. The supercharged prompt states a higher goal, a harder bar, rawer inputs and a real judge, then lets the model pick the path.

## Step 1: Ground it

If the prompt names a project, repo, device or system, skim what's real before rewriting: the repo's CLAUDE.md or handoff, which connectors and tools this session has, where the data lives. The rewrite should name actual data sources and tools, not invented ones. Spend a few tool calls here, not a research project.

## Step 2: Run the three lenses

Answer these for yourself. Not every lens fits every prompt; say which ones you're skipping and why in one line.

**Altitude**
- What does Brandon want to happen *after* this task is done? What's the goal beyond the goal? ("Fix this crash" → "keep it crash-free".)
- Could this become a durable workflow that takes him out of the loop? What access would the model need for that (logs, crash reports, version-to-commit mapping, hardware it can test on)?
- Weak fit for creative work. Strong tell it fits: there'd be a meeting or a follow-up conversation about the result.

**Depth** (answer all four)
1. What would a top professional do here that the prompt doesn't ask for?
2. What's the *rawest* material they'd start from, instead of what's been pre-digested?
3. What specific methods and instruments would they use? (Databases and statistical models, not markdown tables. Profilers, not guesses. Insist on the instrument, not the vocabulary.)
4. What, other than the model or Brandon, would show the result is right? Prefer a tool the model can run for immediate feedback: a test, a benchmark, a simulator, a held-out dataset, a real device.

Then:
- **Set an unreasonable bar and call it reasonable.** 10s load → ask for 200ms. If it sounds impossible, the prompt says it's solvable and to keep going.
- **Challenge a belief.** Name one thing assumed true and ask the model to reproduce or refute it from raw data.
- **Ask for new knowledge.** Once the model is deep in the data, have it find the blind spot nobody knows about yet and prove it on data it hasn't seen.

**Range**
- Swap the noun for verbs. A QBR isn't "a deck", it's "getting busy people to believe a cause-and-effect story and decide under uncertainty in 30 minutes". The verbs point at the fields that help.
- Assemble the crew: if this had to be world-class or Earth gets blown up, who's on the team? Include a red team (a short seller, a forensic accountant, a pentester, a hostile reviewer).
- For each field, write what that person *does* ("research the short position", "run a failure-mode analysis"), never "write like a ...". Role-play makes the transcript weird without improving the result.

## Step 3: Write the supercharged prompt

Output, in this order:

1. **The real goal**, one line, in verbs.
2. **Lenses**: 2 to 4 terse bullets on what each applied lens added, plus the one-liner for any lens you skipped.
3. **The supercharged prompt** in a fenced code block, ready to paste or run. Its parts, in order, using only the ones that apply:
   - Outcome: the goal beyond the goal, stated as what should be true when done.
   - Bar: the concrete, unreasonable target, framed as achievable.
   - Raw material: where to start, named specifically.
   - Instruments: the methods and tools the best practitioners use.
   - Assumption to test: the belief to reproduce or refute.
   - New knowledge: the blind spot to find and prove.
   - Crew: each field and the job it does.
   - Judge: the outside check, preferably something runnable.
   - Boundaries: Brandon's real constraints (repo rules, what needs his sign-off, what not to touch).

   Aim for under 300 words. State goals, inputs and judges; leave the step-by-step to the model.
4. **What it needs**: access, data or tools the prompt assumes that this session doesn't have yet (a connector to authorize, hardware to plug in, an export to grab). Skip if none.
5. **Go further** (optional, one line): the next rung up the altitude ladder, the version that replaces the whole process rather than doing it better. (QBR deck → "design a better way for leadership to catch problems early than a quarterly deck, prove from our history it would have caught things sooner, run it beside the current one for a quarter".)

Then ask whether to run it now, tweak it, or take the "go further" version.

## Quick reference

| Original asks for | Supercharged asks for |
|---|---|
| Fix this bug | Keep it bug-free, with the access to prove it |
| Make it faster | A 20x target, measured by a benchmark the model runs |
| Analyze this summary | Start from the raw logs; test what we believe |
| Act like an expert | Use the expert's instruments |
| Check your work | An outside judge: tests, a simulator, held-out data |
| Make a deck / doc / post | The verb behind it, and the crew who'd nail it |

## Common mistakes

- **Longer, not higher.** Twenty prescriptive steps and a list of suspects. Replace steps with outcome, bar and judge.
- **Vocabulary swap.** "As a senior data scientist..." with the same markdown-table method. Name the instrument.
- **Model grades itself.** "Then review your work" is not a judge. Name the test, benchmark, device or dataset.
- **Every lens, every time.** Altitude on a birthday poem is noise. Pick what fits and say why you skipped the rest.
- **Invented access.** A prompt that assumes crash reports or a database that doesn't exist. Ground it in Step 1 and list gaps under "What it needs".
- Follow writing-voice for the explanation around the prompt (terse, no em dashes).
