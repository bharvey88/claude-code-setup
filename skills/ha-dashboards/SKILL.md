---
name: ha-dashboards
description: Build and edit Home Assistant Lovelace dashboards for Brandon - new cards/views, restructuring layout, card-mod styling, Mushroom/Bubble custom cards, "make this look better", "is there a better way to display X". Use for any change to his HA dashboards. For automations/scripts use ha-automations; for "why did X misbehave" use ha-debug.
---

# Home Assistant Dashboard Building

Brandon expects this done autonomously through the HA MCP server. Do not ask him to open the UI editor, paste YAML, or copy config - you have direct read/write access to his instance. Also load `home-assistant-best-practices` for the card-type/domain reference.

## Mechanics (the parts that bite)

- **His default dashboard is `lovelace`** (title "Harvey", path `/lovelace/home` = view 0). `ha_config_get_dashboard(list_only=True)` to confirm targets.
- **He edits live and drags cards constantly.** Re-fetch a fresh `config_hash` immediately before every write; never carry a hash across a gap. After a write timeout, re-read the hash before retrying - the write may or may not have applied. After any HA restore/rollback, re-verify hashes and content before trusting the config is what you left.
- **Address cards by heading/title, never by section index.** Index positions go stale the moment he drags something; an index-targeted edit has landed on the wrong room's card before.
- **Edit with `python_transform`, not full-config replacement** - surgical, can't clobber unrelated cards.
- **`python_transform` bans `def`/`FunctionDef`** (VALIDATION_FAILED "Forbidden node type"). Inline logic as comprehensions: multi-condition drop filters go in one `[c for c in cards if not (...)]`.
- **The full config often exceeds the token limit.** When `ha_config_get_dashboard` dumps to a file, probe/extract with python (no jq on his box), don't Read the whole thing.
- **Search has blind spots.** `ha_config_get_dashboard(card_type=/entity=/heading=)` skips `picture-elements` `elements` and entity ids inside Jinja; `ha_search` skips dashboards entirely unless `search_types=["dashboard"]`. To find every reference, dump full config and grep/python.
- **Never change a view's layout type (sections ↔ masonry ↔ grid) unless he explicitly asks** - not even while fixing something else or answering "why are there gaps". He reverted an unrequested masonry switch angrily. Related: masonry does NOT honor card order past the first row (placement is height-balanced per column), so exact multi-row layouts in masonry are a losing fight - sections is his layout.

## The preview-then-swap loop (his flow for look-and-feel)

For subjective visual changes ("looks better?", "a dropdown or?"), don't replace the original in place. **Add a labeled preview card alongside it**:

1. Append a preview card (or a `vertical-stack` with a `heading` "Preview: X") right below the existing block. Show alternatives as "Preview A / Preview B".
2. He looks at the live view and reacts ("I like the chips", "too spaced out", "too tall").
3. Tune, or on approval: swap the chosen design into the real block and **delete every preview card** (filter by heading so none orphan).

For a mechanical/obvious change just make it - and when the destination is obvious from an established pattern (same card format as a sibling room), just put it there; don't ask "where do you want it".

**Uncertain third-party card behavior gets verified BEFORE touching his live dashboard.** His sharpest correction came from three live trial-and-error "fixes" to a custom card in a row - fetch the card's actual source (or build/test locally) and prove the behavior first, then apply once.

## His aesthetic (settled preferences, June-July 2026)

- **Compact everything.** Fixed compact card width (~220-260px), never divide full width by card count; a few cards left-aligned with empty space after is fine. Density via card-mod: `ha-card { --spacing: 4px; --icon-size: 26px; --card-primary-font-size: 13px; --card-secondary-font-size: 11px; }`. Target: a view fits one screen without scrolling.
- **Many one-column sections**, one per logical category, no `column_span`, modest inner grids (2-up) - keeps HA's section editor drag/reorder/resize working. Group by device category, worst-first within each group.
- **No redundant chrome**: no "all healthy" banners when stats already say it, no headings/labels for blocks he already recognizes ("i dont want the 'Lights' thing at all"). Empty-state and summary rows belong INSIDE an auto-entities template (append/fallback cards), never in `conditional` cards - Lovelace conditional cards don't support `condition: template` and render red error boxes.
- **Near-binary / tightly-bounded sensors get a compact `mini-graph-card`** (big current value + short sparkline, height shrunk to ~42px from the 100px default), NOT a full ApexCharts timeline ("such a huge step just to show 0 or 1 or 2").
- **Camera-adjacent status (locks, gates, motion, person/vehicle/package) goes in badges overlaid on the camera card** (picture-glance style), not as tile rows below - he rolled this out dashboard-wide. Gotcha: an inactive/off badge that's the only badge renders nearly invisible with default styling - force an explicit icon.
- **Sensor sources**: never use AIR-1 onboard temp/humidity as a room's authoritative reading (MCU self-heating, and they're recorder-excluded) - prefer his ecobee/Zooz/BTHome/IKEA room sensors.

## Card recipes that won (and the gotchas inside them)

- **Battery pills (A/B tested)**: `custom:bubble-card` (card_type `button`, button_type `state`) beat a chrome-less slim-bar list. Per-device: colored `.bubble-icon` + tinted `.bubble-icon-container` by charge threshold via `styles`, `scrolling_effect: false` (marquee on long names reads as broken), `show_attribute` with `battery_type_and_quantity`, forced `.bubble-button-background { opacity: 1; background-color: var(--ha-card-background) }` (his theme makes bubble's background transparent), NO fixed pill height (two-line names need to breathe). 2 pills per section column.
- **Mushroom chips full-width**: `alignment` only does start/center/end. Control spread with card-mod on `.chip-container`: `width: 100% !important` + `justify-content`. His tuned ladder: `space-between` (too spread) → `space-evenly` (better) → settled on `justify-content: center` + `gap: 16px`.
- **Bubble Card v3.2.0+ pop-ups are standalone**: one `custom:bubble-card` with `card_type: pop-up`, its own `hash` and `cards:` list; a separate button with `tap_action: navigate` to `#hash` opens it. The legacy "pop-up as first card of a stack" pattern triggers a migration nag.
- **Inline lock buttons**: a `tile` for `lock.*` with `features: [{type: lock-commands}]`. He liked it on the Batteries view but rejected the added height on camera-row door cards - the height impact depends on context, so preview it rather than assuming.
- **auto-entities**: `filter.template` returning a list of mushroom-template-card dicts, sorted by a `sort_key` key (mushroom ignores extra keys). Display names via `device_attr(entity_id, 'name_by_user')` with attribute fallback so renames show immediately.
- **Percentage fill bar**: card-mod `background-image: linear-gradient(to right, <tint> P%, rgba(0,0,0,0) P%)` - `background-image`, not `background`, so the theme card color survives. Tint by threshold.
- Custom cards installed (check resources before recommending): mushroom, bubble-card, button-card, apexcharts, mini-graph, card-mod, auto-entities, flower-card, and more.

## Verify

card-mod patches Mushroom/Bubble shadow DOM, so styling can silently break on an upgrade. Never claim a dashboard change shipped without looking at the live result - tell him to hard-refresh (card-mod caches), or pull a screenshot if available. State plainly what you changed and what you observed.
