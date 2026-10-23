# NOVA: Handover v2 (status + asset pack + plan of action)

Written 2026-10-23. This file UPDATES `docs/HANDOVER.md` (v1). Sections 1-13 of v1 (what we are building, decisions, architecture, story generation, question formation, risks) are still valid. Where v1 and this file disagree, this file wins. Put it in the repo as `docs/HANDOVER_v2.md`.

Precedence for any human or AI: (1) owner decisions in section 2 below and in v1 section 2, (2) this file, (3) v1, (4) other old docs in the repo. Rules for AI agents are unchanged from v1 section 0: do not guess, one small task per branch, do not push to `main`, never commit secrets, do not change the JSON contract without the owner's approval, do not delete or stub the duel, verify with `flutter analyze` and `flutter test`, and say plainly what you could not run.

---

## 1. Status snapshot (2026-10-23)

| Item | State | Notes |
|---|---|---|
| Phase 0 (decisions doc, rules, `nova-main/` removed, key template) | Applied | Antigravity's STEP 0 check is the proof. Re-check on a fresh clone. |
| T0.5 consolidation analysis | Done | `docs/CONSOLIDATION_PLAN.md`, branch `docs/consolidation-plan`, commit `6bb47b3` (290 lines). Merge it into `nova`. |
| Consolidation Steps 1-4 (move widgets, utils, accessibility screens, demo tools out of `lib/nova_main/`) | Finished by Antigravity (owner report, 2026-10-23) | Branch `task/consolidate-steps-1-4`. Review the diff and its `flutter analyze` numbers before merging. Nothing was supposed to be deleted. |
| Phase 1: contract v2, validator, schema v2, math skills | Delivered | Owner reports it applied. Files: `contracts/level_v2.schema.json`, `contracts/examples/*`, `backend/validator.py`, `backend/catalog.py`, `backend/db/schema_v2.sql`, `backend/db/init_db.py`, `docs/math_skills_g1_4.json`. 25 unit tests passed in the planning environment (`python -m unittest backend.tests.test_validator`). Run them again in the repo. |
| Art | First batch delivered (section 3) | Generated with Gemini by the owner. |
| Backend, app vertical slice, placement, duel | Not started | See section 5. |

Key findings from `CONSOLIDATION_PLAN.md` that affect everything below:
- Only `lib/main.dart` (`MajheGaonApp`) actually runs. `lib/nova_main/main.dart` is dead code and 12 of its 16 screens are unreachable.
- `lib/main.dart` has no named-route table, so any `Navigator.pushNamed` call (accessibility and demo screens) crashes at runtime. Use `MaterialPageRoute`.
- 25 files depend on `lib/nova_main/services/app_state.dart`. Migrating it to Riverpod is a later, separate step.
- Class selection touches 5 layers (screens, routes, `CurriculumData`, Drift fields `enrolledStandard` / `activeStandard`, AppState). The placement test replaces it later.
- `lib/features/curriculum/` (4 screens) and the onboarding presentation screen are orphaned.

Environment caveat (unchanged): Claude's planning environment has no Flutter SDK. All Dart written by Claude is untested until built on a machine with Flutter.

## 2. New decisions (owner, 2026-10-23)

| Topic | Decision |
|---|---|
| Duel transport | **Android Nearby Connections** (not pure BLE). Android-only. Tell the project guide; if the guide objects, fall back to `flutter_ble_peripheral` for the host. |
| Art source | Generated with Gemini by the owner's team. More assets will come as a list. |
| Poses vs expressions | Option A approved (section 4): keep `expression` in the contract, map it to a pose per character on the client and in the validator. No contract change. |
| Speed | There is a demo to the project guide today. Prefer something that visibly works over completeness. |

## 3. Asset pack (first batch)

Raw files: `background_assets.zip` (13 backgrounds) and `character_assets.zip` (about 90 sprites). They were cleaned by `tools/process_assets.py` into the pack `nova_assets/` (104 assets, 3.1 MB, all WebP). Copy it to `assets/nova/` in the repo and register the folders in `pubspec.yaml`. Do not edit the output by hand: fix the raw file or the script and re-run. `manifest.json` lists every asset with size and flags.

### What is in it
- `backgrounds/` (13, 1280x720): bg_banyan_tree, bg_cowshed, bg_farm, bg_mango_trees, bg_river, bg_river_bank, bg_temple, bg_handpump, bg_house_courtyard, bg_market, bg_village_overview, bg_village_road, bg_school.
- `characters/` (46): boy, girl, mother, father, grandfather, grandmother, postman, shopkeeper, shopper. Naming is `char_<who>_<pose>`.
- `animals/` (18): cow, dog, parrot, sparrow, fish. Naming is `animal_<who>_<pose>`.
- `props/` (16): rupee notes 10/50/100/500, gold coin, coin piles small/medium/large, pots, lantern, globe, cart, bench, bookstand, Marathi blackboard, notice board.
- `environment/` (11): banyan tree, well, handpump, tractor (3 views), school bus (5 views).
- `_unsorted/shopkeeper_sheet.png`: a multi-pose character sheet, not a sprite. Crop it later or regenerate.

### Poses available per character (this is NOT an expression set)
- boy: standing, jumping, jumping_front, pointing, shocked, thinking, side, running, walking
- girl: standing, jumping, jumping_front, thinking, waving, side, running, walking, walking_side
- mother: standing, jumping, teaching, thinking, walking
- father: standing, happy, jumping, thinking, waving
- grandfather: happy, angry, teaching, holding_book
- grandmother: standing, waving, reading, teaching, walking
- postman: standing, waving, reading
- shopkeeper: standing, waving, welcoming, weighing, writing
- cow: standing, walking, eating, calling, sleeping. dog: standing, sleeping. parrot: perched, flying, chilli. sparrow: perched, flying, chirping. fish: normal, smiling, jumping, bubbling, diving.

### Problems found (read before building UI on this art)
1. **Sprites are low resolution.** 91 of 104 sprites are under 300 px tall (typical 150 x 220 px). On a phone at roughly 300 dp tall they will look soft or blurry. Fix: ask Gemini for higher-resolution output (ask for 1024 px or larger on the long side), or upscale as a stopgap. Until then keep characters small on screen.
2. **Style mismatch.** Backgrounds are glossy 3D-render style; sprites are flatter vector style. It works acceptably in a quick test but should be reviewed on a device. Consider generating future sprites with the same prompt style as the backgrounds.
3. **Poses, not expressions.** The contract (v1 section 7) assumes `expression` (idle, happy, curious, encouraging, surprised). The art gives poses instead. See section 4 for how to bridge this without breaking the contract.
4. **Uneven pose coverage.** The boy has no waving or happy pose, the girl has no pointing or shocked pose, the grandmother has no happy pose. Do not assume every character has every pose; read `manifest.json`.
5. **No countable story props.** There is no mango, banana, ball, flower, basket or star. Math counting questions need objects that can appear in groups of 1 to 20. Currently usable for counting: gold coin, rupee notes, pots, lantern, fish, parrot, sparrow. More props are needed (see "asset wishlist").
6. **Mislabeled raw files (fixed in the script).** `standing_grandfather`, `waving_grandfather` and `reading_book_grandfather` were actually the grandmother. The script renames them to `char_grandmother_*`. Other raw names had typos (parot, chllyparroat, lanten, glob, trator, shopkepper) and are normalised.
7. **Father sprites had a baked-in grey box** (semi-transparent grey, RGB 127). The script removes it. Check on a coloured background that no halo remains.
8. **Small artifacts.** `char_grandfather_happy` has a sparkle mark next to it. Duplicate raw file `jumping_father (1).png` was ignored.
9. **Licence and rules.** Check Gemini's output terms and whether the college allows AI-generated art (open question from v1, still open).
10. **Character names.** The working names in the old catalog (Chintu, Tiger, Meena) do not exist in the art. Asset ids use roles (`char_boy`, `char_girl`). The owner should choose story names and say which character is the hero.

### Asset wishlist (send to Gemini next)
- Countable props: mango, banana, apple, ball, flower, basket, book, star, pencil, laddu. One image each, transparent background, same style.
- Poses: boy waving / happy / surprised; girl pointing / happy / shocked; mother happy / waving; grandmother happy.
- Backdrops are enough for now (13 is plenty for the demo).
- Sound effects: cheer, oops, pop, whoosh (not requested yet; the contract refers to `sfx_*`).

## 4. Bridging poses and the contract (RECOMMENDED, needs owner approval)

The contract and validator currently reference `expression` values and the old placeholder catalog (`char_chintu`, `char_tiger`, `char_meena`, `prop_mango`, `bg_banyan_grove`, ...). None of those match the real art. Two options:

- **Option A (recommended, no contract change):** keep `expression` in the JSON. Add a per-character `pose_map` in the client (and in `backend/catalog.py`) that maps expression to an available pose, with a safe fallback to `standing`. Example for the boy: idle -> standing, happy -> jumping, curious -> thinking, surprised -> shocked, encouraging -> pointing. Actor ids change to the real ones (`char_boy`, `char_girl`, ...). The JSON schema keeps its shape, only the enum lists change.
- **Option B (later):** add an optional `pose` field to actors for direct control. This is an additive contract change and needs approval.

Either way, `backend/catalog.py` and the enum lists in `contracts/level_v2.schema.json` must be regenerated from `manifest.json` (task A1 below). Motions (`jump`, `head_tilt`, `shake`, ...) stay Flutter transforms applied to whichever pose image is showing; no new art is needed for them.

## 5. Plan of action

### Today: demo to the project guide (what to show, in order of impact)
1. A level rendered from JSON with the real backgrounds and characters (needs A1, A2, A3 below). This is the single most convincing demo.
2. The validator rejecting a bad level (works now, run `python -m unittest backend.tests.test_validator`).
3. The architecture picture from v1 section 4 (content factory on the server, play loop on the phone).
4. Clickable UI mockup (T4.1), if time allows.
5. Be honest about what is simulated: the duel is still mostly mock, the backend does not exist yet.

### Task backlog (copy each block as a prompt for an AI agent; tick in v1 section 16 when done)

- [x] **A1 DONE 2026-10-23 (Claude): catalog and contract enums regenerated from the real assets. 29 tests pass.** Original task text: Regenerate catalog and contract enums from the real assets. Owner: Claude or any agent. Read `assets/nova/manifest.json`. Rewrite `backend/catalog.py` (BACKDROPS, ACTORS with pose lists and a pose_map, PROPS, motions unchanged) and the enum lists in `contracts/level_v2.schema.json`. Rewrite `contracts/examples/level_valid.json` and the 5 broken examples to use real ids and countable props that exist (use `prop_coin_gold` or `animal_fish_*` until mango etc. arrive). *Accept:* all unit tests pass and the valid example validates against the new catalog. Needs owner OK on section 4 option A first.
- [ ] **A2 Import the asset pack.** Owner: Antigravity. Copy `nova_assets/` to `assets/nova/`, register in `pubspec.yaml`, remove or keep the old PNG assets in `assets/Design System/` as the owner decides (ask, do not delete). Add a Dart `AssetCatalog` that loads `manifest.json`. *Accept:* `flutter analyze` is no worse than baseline, and a debug screen shows every background and sprite.
- [~] **A3 WRITTEN, NOT COMPILED (2026-10-23, Claude): `lib/features/scene/*`, demo entry `lib/scene_demo_main.dart`, see `docs/SCENE_RENDERER.md`. Needs a first `flutter analyze` and a device check.** Original task text: Scene renderer + character widget. Owner: Claude writes Dart, Antigravity wires and builds. Draw a level from v2 JSON: backdrop full-bleed, actors in left/center/right slots (bottom-anchored), props in slots with `count` laid out in a row or arc, timeline playback, expression-to-pose swap with cross-fade, motion presets as transforms, unknown names fall back to `standing` and never crash. *Accept:* `contracts/examples/level_valid.json` renders on a device and every motion plays.
- [ ] **A4 Real Android duel with Nearby Connections.** Owner: Antigravity. Replace the mock timers in `lib/features/duel/`, add Nearby Connections (advertise on host, discover on client), add the required Android permissions, keep the seed-based question generator so both phones get the same 10 questions, and show live scores. Do not delete the existing duel screens. *Accept:* two physical Android phones finish a duel. Emulators cannot test this.
- [ ] **B1 Backend skeleton.** T2.1 in v1 (FastAPI + SQLite, four endpoints). Not started.
- [ ] **B2 Math question templates** (T2.2) and **B3 story pipeline** (T2.3). Not started. B2 can start now because it needs no art.
- [ ] **C1 Placement test and level assignment** (T3.1, T3.2). Not started. Needs the consolidation steps first, because class selection must be retired.

### Order of work
1. Finish and review Antigravity's consolidation Steps 1-4; merge `docs/consolidation-plan` and the Phase 1 files into `nova`.
2. A1 -> A2 -> A3 (the demo path). In parallel: owner generates the asset wishlist; another teammate starts A4 (needs two phones).
3. Then B1-B3 (backend) and C1 (placement). Then consolidation Steps 5+ and the AppState to Riverpod migration.
4. Hardening and demo polish (v1 phase 5).

### Branch hygiene
One branch per task: `task/<id>-<short-name>`. Never push to `main`. Merge `docs/consolidation-plan` into `nova` before other consolidation work. Ask the owner before any force-push or branch deletion.

## 6. Open questions

1. Does the guide accept Android Nearby Connections? (Owner decided to use it; confirm with the guide.)
2. Option A or B for poses (section 4)?
3. Names and roles for the story cast (who is the hero, who is the guide character)?
4. Is AI-generated art allowed by the college, and do Gemini's terms permit this use?
5. Who owns the backend, and how many people are on it?
6. Is math still the first subject for the demo? (Assumed yes.)
7. Deadline beyond today's guide meeting?

## 7. What was verified and what was not

- **Verified (by running in the planning environment):** asset processing script ran and produced 104 WebP files; visual check of the grandparent and father sprites after processing; the validator and DB seed unit tests (25 tests) passed.
- **Verified by Antigravity's own report (not independently checked):** the findings in `CONSOLIDATION_PLAN.md`.
- **Not verified:** that the Flutter app builds or runs; how the art looks on a phone; Marathi TTS and speech recognition on real devices; whether removing AppState silences any implicit audio; the duel on real phones; Gemini licence terms.

## 8. Progress log

- 2026-10-21: handover v1 written.
- 2026-10-22/23: Phase 0 applied; T0.5 `CONSOLIDATION_PLAN.md` produced by Antigravity (commit `6bb47b3`).
- 2026-10-23: Phase 1 files (contract v2 schema, validator, schema v2, 21-skill math graph) delivered by Claude and applied by the owner.
- 2026-10-23: first asset batch received and cleaned (`nova_assets/`, 104 assets). Duel decision: Nearby Connections.
- 2026-10-23: consolidation Steps 1-4 finished by Antigravity (per owner; diff not yet reviewed here).
- 2026-10-23: A1 done (catalog, schema enums, examples, tests regenerated from `manifest.json`; 3 demo levels in `assets/nova/demo/`). A3 written but not compiled: `lib/features/scene/`, standalone demo `flutter run -t lib/scene_demo_main.dart`.
