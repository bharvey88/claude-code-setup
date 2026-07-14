---
name: ha-automations
description: Author and edit Home Assistant automations, scripts, scenes, and helpers for Brandon - new automation, converting/consolidating existing ones, adding a script or helper. Use whenever building HA logic. For dashboards use ha-dashboards; for "why did X fire/not fire" use ha-debug.
---

# Home Assistant Automation Authoring

Brandon expects this done autonomously through the HA MCP server (`ha_config_set_automation` / `_script` / `_scene` / `_helper`) - create and validate via the config API, never hand him YAML snippets to paste or tell him to edit `configuration.yaml`. **Always load `home-assistant-best-practices` first** - it holds the native-condition/helper decision workflow and the safe-refactoring rules; this skill is his personal conventions layered on top. (That plugin skill is read-only - it's overwritten on updates, so durable additions land here, never there.)

## Before writing: ground it in evidence

- **Pull real history before choosing thresholds or logic** (`ha_get_history` on the entities and mode selectors involved). Base the design on how things actually behave, not assumption - he explicitly rewards this.
- **When he describes a manual habit on a schedule** ("I run Mr Freeze around 8pm"), propose automating it directly - auto-trigger gated so a manual pick always wins - rather than a reminder/notification.
- Native triggers/conditions and built-in helpers before any Jinja - check the best-practices skill's substitution tables (numeric_state, time condition, min_max/threshold/derivative helpers, Template Helper via config flow instead of `template:` YAML).
- Use `entity_id`, not `device_id` (device_id breaks on re-add). Exception: Z2M autodiscovered device triggers.
- For Zigbee buttons/remotes: ZHA → `event` trigger with `device_ieee`; Z2M → `device` or `mqtt` trigger. Watch numeric-string coercion on button payloads (see ha-debug).
- New multi-sensor/climate devices: check the generated entity IDs before wiring them anywhere - a device named after its area produces doubled slugs (`sensor.living_room_living_room_climate_*`), which he wants renamed before they're referenced. His light groups are a deliberate 4-layer hierarchy (leaf / `*_group` / `*_all` / top-level `*_lights`) - don't "fix" them.

## Brandon's authoring checklist (apply every time)

1. **Aliases on everything** - set `alias:` on every trigger, condition, choose-option, and action so the visual editor and trace timeline read like sentences.
2. **Right mode** - don't default to `single`. Motion-with-timeout → `restart`; sequential (locks) → `queued`; independent per-entity → `parallel`; one-shot notify → `single`.
3. **The watchdog pattern** - a threshold-crossing trigger never fires when the condition is ALREADY true (cat room hot all night = nothing crosses). Pair crossing triggers with a periodic re-check trigger (e.g. `/30`) as a safety net; this is his named, established convention ("guest watchdog pattern").
4. **Categories + labels** - list his existing categories and labels first (`ha_config_get_category` / `ha_config_get_label`), then apply them to every new automation/script/helper. His semantics: `security` = physical security/safety + UPS; `monitoring` = system/appliance health. Create a new label rather than leaving something unlabeled, but reuse his taxonomy before inventing buckets.
5. **Consolidate** - N near-identical automations that share a trigger and differ only in data become ONE automation with trigger IDs + a `choose:` keyed on `trigger.id`. Don't ship a family of copies.
6. **No extra helper scripts** - don't factor shared logic into a new `script.*` entity. Reuse an existing automation/script (e.g. an existing init sequence) or inline the actions.
7. **Notification tags** - use `tag` to replace stale transient notifications (arming, UPS, washer). Multi-instance alerts (per-room CO2, per-device) get a templated per-entity tag (`co2_high_{room}`) so one room's clear can't eat another's active alert. Never auto-clear safety alerts (smoke/CO/leak).
8. **Blueprint `description:` fields are user-facing behavior only** - what it does for the user, never implementation diffs or PR-style changelogs.

## Respect his intent

- When he asks "can we do X?" - answer/propose first, don't unilaterally restructure his existing automations or dashboards.
- Smallest change that does the job; don't redesign unless he asks.
- When he says "just fix it" / "stop going back and forth", take the most autonomous path with the tools you have and stop diagnosing.

## Verify

Trigger the scenario where possible (fire the trigger, toggle the helper, `ha_call_service`) and confirm via a fresh `ha_get_automation_traces` / `ha_get_history` that it behaved. Device quirk to remember: some hardware treats "innocent" commands as power-on (his Midea ACs power on from a fan-speed command) - gate device commands on the device actually being in the expected state. After any HA restore/rollback incident, re-verify your automations actually match what you left before trusting them. Tell him plainly what you built, what conventions you applied, and what you observed. For diagnosing misbehavior, hand off to `ha-debug`.
