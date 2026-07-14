---
name: prefers-native-constructs
description: "Prefer built-in/native constructs over custom templating when both exist"
metadata:
  type: feedback
---

When both a native construct and a hand-rolled template solve the same problem, use the native one.

**Why:** Native constructs are more readable, survive upgrades, and are what the user maintains long-term. A clever template is a liability the next person has to decode.

**How to apply:** Reach for the built-in helper/option first; only template when there's genuinely no native path. Links to related guidance go here with `[[other-memory-name]]`.
