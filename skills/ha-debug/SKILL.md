---
name: ha-debug
description: Debug Home Assistant problems for Brandon - "why did X notify/fire/not fire", automation didn't run, sensor unavailable, integration failing, unexpected notification. Use whenever Brandon pastes a phone notification, an HA error, or describes HA behaving unexpectedly.
---

# Home Assistant Debugging Ritual

Brandon expects this done autonomously through the HA MCP server. Do not ask him to check things in the UI, pull logs, or run commands - you have direct access to his instance, his Chrome extension, and his LAN. Also load the `home-assistant-best-practices` skill before changing any automation.

## Phase 1: Evidence first (no guessing, no fixes yet)

1. Identify the automation/entity involved (`ha_search`, `ha_get_entity`).
2. Pull the actual record of what happened:
   - `ha_get_automation_traces` for the automation in question - read the trigger, condition results, and which branch ran.
   - `ha_get_history` for the entities involved around the event time.
   - `ha_get_logs` for integration/component errors.
3. State the root cause with evidence (trace step, state timeline) before touching anything. If Brandon is asking a question rather than requesting a fix, report findings and stop.

## Known traps (check these before exotic theories)

- `someone_is_home` template sensor lags real presence by minutes. Never use it as a fast arming/leaving veto - gate on `zone.home` count + guest count instead.
- Battery Notes: use `battery_low` / `battery_last_reported` / `device_name` attributes on `battery_plus` sensors, never `last_updated` (resets on restart).
- Integration with `source: import` + stuck in `setup_retry` + `supports_options: false` → delete and re-add the integration first; skip network forensics.
- Automation `mode` mismatches (e.g. `single` on motion-restart patterns) cause silent skipped runs - check the trace for "already running".
- Numeric-string template coercion: HA renders a numeric-looking value as a number, so an event `data: { button: "3" }` read via `{{ trigger.event.data.button }}` arrives as int `3` and `pressed == '3'` is silently false (the trace shows the trigger fired but "Choose: No action executed"). A `| string` in a `variables:` block gets re-coerced and lost. Fix by coercing at the comparison (`pressed | string == '3'`) or, better, route with native `event` triggers using `event_data:` filters + trigger IDs instead of a template `choose`.

## Phase 2: Fix

- Smallest change that addresses the root cause. Don't redesign the automation unless asked.
- Set `alias:` on every trigger, condition, choose-option, and action so the visual editor and traces read like sentences.
- If the fix spawns near-identical automations, consolidate into one automation with trigger IDs + `choose:` instead.
- Apply Brandon's existing categories and labels to anything new.

## Phase 3: Verify

- Re-run or trigger the scenario where possible (fire the trigger, toggle the helper, or use `ha_call_service`) and confirm via a fresh trace/history that it now behaves correctly.
- Tell Brandon plainly: what was wrong, what changed, and what you observed in verification.
