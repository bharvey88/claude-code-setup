---
name: apollo-yaml
description: Use when changing ESPHome firmware YAML in an Apollo Automation product repo (AIR-1, MSR-1/2, MTR-1, TEMP-1, PLT-1, BTN-1, PUMP-1, R_PRO-1, CAST-1, H-1) - a sensor/select/entity fix, a component change, an OTA/manifest tweak - before editing files or opening the PR.
---

# Apollo Firmware Fix

The end-to-end path for a firmware YAML change in an Apollo product repo: pick the repo and branch, edit the right file, keep the build green, bump the version, validate locally, then hand the PR to `upstream-contrib`. This skill owns the firmware-specific parts. **REQUIRED for the submit step: `upstream-contrib`** (show-before-submit, one change per PR, attribution).

## Before you touch anything

- **Is the repo real and in-scope?** Released repos: AIR-1, MSR-1, MSR-2, MTR-1, R_PRO-1, PLT-1, TEMP-1, BTN-1, PUMP-1, H-1, H-2, CAST-1. **Do NOT touch TEMP_PRO-1, RLY-1, or TEMP_PROJECT-1** (not shipped products) unless Brandon explicitly says so. See memory `apollo-product-repos`.
- **Write access:** `bharvey88` can push to most Apollo repos except **H-2** (use a fork there). Firmware PRs are cut from Brandon's fork against `beta`.
- **Which branch?** A firmware change → PR to **`beta`**, then STOP (a maintainer merges, never self-merge). A **workflow-only** change (`.github/workflows/*`, no firmware published) → target **`main`**, because `pull_request_target` / default-branch workflows only take effect on `main`.

## Repo structure

Firmware lives in `Integrations/ESPHome/`:

- **`Core.yaml`** holds all shared logic (substitutions, `select:`, `script:`, `button:`, `sensor:`, `interval:`) and the `version:` substitution at the top. Every variant includes it as a package.
- **Per-variant files** are thin wrappers that own `esphome:`/`substitutions:` and pull Core, e.g. `AIR-1.yaml`, `AIR-1_Factory.yaml`, `AIR-1_BLE.yaml`. Products vary: MSR-1 adds `_BLE`/`_Factory`; R_PRO-1/CAST-1 use `_ETH`/`_W`; TEMP-1/PLT-1 add `Battery`/`NonBattery`/`Resistance`. `AIR-1.yaml` (the plain variant) is what ESPHome Device Builder references.

**Which file to edit:** shared behavior and the version go in **`Core.yaml`**. Variant identity (a BLE-only override, a per-variant manifest URL) goes in that variant's `substitutions:`. A single Core edit still has to validate against **every** variant.

## Editing rules (these turn CI red if you miss them)

- **Don't create a new YAML file** to add behavior. Edit the existing file or use `!extend`. Brandon: "im not adding a separate yaml file that is stupid."
- **Use built-in ESPHome components, not hand-rolled lambdas**, per each repo's `AGENTS.md`.
- **Verify accessors against the `dev`/`beta` branch, not stable.** CI compiles every config against stable + beta + dev, so a member that's deprecated-but-present on stable fails the beta/dev legs. Known trap: `select` state is `.current_option()`, not `.state` (removed 2026.7.0). `sensor`/`number`/`switch`/`text` `.state` are fine - don't blanket-rewrite. See `esphome-avoid-deprecated-api`.
- **`esphome: on_boot` must be list form** (`- priority: ...`) in Core.yaml, not mapping form. Package merge concatenates list form and replaces mapping form, so mapping-form boot logic silently vanishes per variant.
- **Edit all affected variants.** If you touch `AIR-1.yaml`, ask what the Factory and BLE variants need too.
- **Watch the flash ceiling.** Builds must stay under the app-partition size (~1.83 MB; base runs ~94%, Factory ~95%). If a change pushes a variant over, drop `captive_portal`/`web_server` on Factory only.
- **GitHub release-asset OTA needs bigger HTTP buffers** (`buffer_size_rx: 5120`, `buffer_size_tx: 2048`) or the download fails on the signed-URL/CSP headers.
- **Manifest URLs in `apply_ota_source` substitutions must match exactly** what the build pipeline publishes (`manifest-standard.json`, `manifest-ble.json`, Pages `firmware/` vs `firmware-ble/`).

## Version bump (any PR that changes built firmware)

Bump the `version:` substitution in **`Core.yaml`**. Format is date-based **`YY.M.D.N`**, no zero-padding.

- Date is **today's actual date** - re-check it, don't reuse the date already in the string.
- **`N` resets to 1 every new day.** Never carry it across a date boundary. If beta shows `26.6.17.1` from yesterday and you bump today (the 18th), it's `26.6.18.1`, not `26.6.17.2`. `N` goes to 2+ only for a second bump the same day.
- Cosmetic/no-publish PRs (whitespace, dedupe with identical compiled output) skip the bump - check "Other - Does not publish" in the PR template instead.

## Validate locally (config only)

Run from `Integrations/ESPHome/`, in **PowerShell** (ESP-IDF refuses to build under MSYS/Git Bash), one per variant:

```
esphome config AIR-1.yaml
esphome config AIR-1_Factory.yaml
esphome config AIR-1_BLE.yaml
```

Look for `INFO Configuration is valid!` on each. `secrets.yaml` warnings are expected and fine (Core ships default substitutions like `ota_password: "apolloautomation"`).

- **`esphome config` only renders/validates - it does NOT download the toolchain, so it's fast.** That is the assistant's job.
- **`esphome compile`/`esphome run` is the slow hardware path.** Don't run it as validation.
- No standing esphome venv exists. If the system `esphome` is wrong/locked, make a throwaway venv and pin the exact version (`python -m venv <scratch>; ... pip install esphome==<ver>`). CI is the authoritative compile anyway; if local build fights you, just get the YAML right and let CI compile.

## Hardware testing is Brandon's job

Config validation is yours. **Flashing, `esphome compile`/`run`, upload, and serial monitoring are Brandon's** - teach the steps, don't run them, don't probe COM ports. See memory `flashing-is-brandons-job`. Produce a hardware-test checklist for him at the end, and test on the `bharvey88` fork first before the ApolloAutomation PR.

## Submit

Labels are applied at PR create (`gh pr create ... --label new-feature|bugfix|breaking-change`); release-drafter builds the notes off those labels, and a `label-check` workflow enforces them. Then follow **`upstream-contrib`** for the actual submit: verify target repo, show the full PR title/body and get approval, keep every PR-template checkbox, commit with `git commit -F <ascii file>` (Apollo footer, no `Co-Authored-By`), base `beta`, head `bharvey88:<branch>`.

## Quick reference

| Situation | Do |
|-----------|-----|
| Shared logic / component / entity fix | Edit `Core.yaml` |
| Per-variant override | Edit that variant's `substitutions:` |
| Reading a `select` value in a lambda | `.current_option()`, never `.state` |
| Adding behavior | Extend existing YAML / `!extend`, never a new file |
| Any published firmware change | Bump `Core.yaml` version to today's date, N=1 |
| Workflow-only change | Target `main`, not `beta` |
| Validating | `esphome config <variant>.yaml` per variant, PowerShell |
| Compiling to a device | Brandon's job - hand off a checklist |

## Common mistakes

- Bumping only `N` and keeping yesterday's date.
- Editing `AIR-1.yaml` and forgetting `_Factory`/`_BLE`.
- Rewriting every `.state` when only `select` changed.
- Mapping-form `on_boot` that gets dropped on package merge.
- Running `esphome config` from Git Bash and blaming the config for the ESP-IDF failure.
- Naming a rolling-release tag the same as a branch (use `beta-fw`); see `upstream-contrib`.
