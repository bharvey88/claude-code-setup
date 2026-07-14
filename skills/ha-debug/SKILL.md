---
name: ha-debug
description: Debug Home Assistant problems for Brandon - "why did X notify/fire/not fire", automation didn't run, sensor unavailable, integration failing, unexpected notification, custom card broken or spinning. Use whenever Brandon pastes a phone notification, an HA error, or describes HA behaving unexpectedly.
---

# Home Assistant Debugging Ritual

Brandon expects this done autonomously through the HA MCP server. Do not ask him to check things in the UI, pull logs, or run commands - you have direct access to his instance. Also load the `home-assistant-best-practices` skill before changing any automation.

## Phase 0: Confirm the HA MCP server is actually connected

Make one cheap MCP call first (`ha_search` or `ha_get_entity`). If the HA tools are missing or erroring, say so immediately and ask Brandon to reconnect (`/mcp`) - do NOT fall back to unauthenticated LAN probing, browser automation, or asking him to paste console output. That fallback burned three sessions in one week; one authenticated call would have settled each.

## Phase 1: Evidence first (no guessing, no fixes yet)

1. Identify the automation/entity involved (`ha_search`, `ha_get_entity`). Confirm the entity/integration still exists before theorizing about it - he may have deleted it already.
2. Pull the actual record of what happened:
   - `ha_get_automation_traces` for the automation in question - read the trigger, condition results, and which branch ran.
   - `ha_get_history` for the entities involved around the event time.
   - `ha_get_logs` for integration/component errors.
3. State the root cause with evidence (trace step, state timeline) before touching anything. If Brandon is asking a question rather than requesting a fix, report findings and stop.
4. Don't assert timing/behavior specifics you inferred - flag them as unverified. Don't infer integration/domain from a device's friendly name (his "Soundbar" is WLED); verify which integration actually owns the entity.

## Known traps (check these before exotic theories)

**Templates and state:**
- Numeric-string template coercion: HA renders a numeric-looking value as a number, so an event `data: { button: "3" }` read via `{{ trigger.event.data.button }}` arrives as int `3` and `pressed == '3'` is silently false (trace shows trigger fired but "Choose: No action executed"). A `| string` in a `variables:` block gets re-coerced and lost. Coerce at the comparison (`pressed | string == '3'`) or, better, route with native `event` triggers using `event_data:` filters + trigger IDs.
- Jinja `regex_search()` returns a **boolean**, not a match object - `regex_search(...) is not none` is always True. Use the result directly. (Caused false-critical battery alerts.)
- `persistent_notification.*` entities are NOT in the state machine - any dedup guard reading their state is silently always-false. Dedup against a real state-tracked source (e.g. `todo.get_items`).
- `someone_is_home` template sensor lags real presence by minutes. Never use it as a fast arming/leaving veto - gate on `zone.home` count + guest count instead.
- Battery Notes: for "is this device silently dead" logic, do NOT trust any time-since-report signal - `last_updated` AND `battery_last_reported` both freeze at HA restart for stable-battery Zigbee devices (24 devices once all showed the same "2.9 days"). Use the `battery_plus` entity's genuine `unavailable` state. `battery_low` / `device_name` attributes are fine. Battery Notes device registration is UI-only (config subentries) - no service/API can add a device to it.

**Automations and blueprints:**
- Automation `mode` mismatches (e.g. `single` on motion-restart patterns) cause silent skipped runs - check the trace for "already running".
- Template warnings sourced from a **blueprint** are invisible to automation-config search - the template lives in the blueprint source, not the instance. Fetch and read the blueprint YAML directly.
- HA caches blueprint code in memory. After patching/re-importing a blueprint, re-pointing the automation is NOT enough - reload automations (or restart) before verifying, or you'll "confirm" the old code.
- Calendar triggers refresh on a ~15-minute scan - a just-created event a few minutes out won't fire the trigger. Re-saving the automation forces a listener refresh; real events set days ahead are unaffected. Don't smoke-test with near-future calendar events.
- Threshold-crossing triggers never fire when the condition was already true (nothing crosses). See the watchdog pattern in `ha-automations`.

**Integrations and registry:**
- Integration with `source: import` + stuck in `setup_retry` + `supports_options: false` → delete and re-add the integration first; skip network forensics.
- Reflashed/re-added devices leave **ghost device-registry entries**: same manufacturer/model, old entities permanently `unavailable`. Registry-based matching picks them up as real; a live device that's merely offline looks identical, so distinguishing needs Brandon's input.
- Some entity references live in raw YAML (packages, scripts) the MCP tools can't see. If MCP search finds no reference but something clearly uses the entity, hand Brandon a `grep -rn` to run on `/config` instead of guessing.

**Dashboards and cards:**
- `ha_search` default `search_types` EXCLUDES dashboards - rename impact-analysis that skips `search_types=["dashboard"]` will declare "no stale references" and still break cards.
- Trend-graph cards (mini-graph-card and friends) spin forever with no error when an entity has zero recorder history - and ONE dead entity poisons a shared multi-entity graph, not just its own series. Check recorder history before blaming the card.
- `Failed to execute 'define' on 'CustomElementRegistry'` = the same card JS registered twice as a Lovelace resource (e.g. HACS-managed + a stray duplicate without the `hacstag` param), not a card bug.

## Phase 2: Fix

- Smallest change that addresses the root cause. Don't redesign the automation unless asked.
- Follow the `ha-automations` checklist for anything you touch (aliases, mode, categories/labels, consolidation).

## Phase 3: Verify

- Re-run or trigger the scenario where possible (fire the trigger, toggle the helper, `ha_call_service`) and confirm via a fresh trace/history that it now behaves.
- Be timestamp-precise: "no new warnings" is not proof. Confirm Brandon's real-world action (e.g. "you shook the cube at 15:53:34") lands AFTER the last bad log line.
- Tell Brandon plainly: what was wrong, what changed, and what you observed in verification.
