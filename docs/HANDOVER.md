# NOVA: Project Handover

Written 2026-10-20, updated 2026-10-22, from a long planning chat between the project owner and Claude.

---

## 0. READ THIS FIRST (teammates and AI agents)

**Purpose of this file:** to let anyone, human or AI, continue the Nova project without the original chat. Treat it as the starting source of truth. Move it into the repo (for example `docs/HANDOVER.md`) and keep it updated.

### Precedence when sources disagree

1. **Decisions in section 2** (stated by the project owner). These always win.
2. **Recommendations in this file** (marked RECOMMENDED), unless the owner overrides them.
3. **Older docs in the repo** (`Nova System Architecture & TechStack.md`, `Nova Database Schema.md`, `.agent/skills/*.md`). These are partly outdated and partly wrong for the current direction. In particular the `.agent/skills` files say "offline only, no cloud AI, no PNGs, Std 3 and 4 only", which contradicts the decisions. **Do not follow them.** Fixing them is task T0.1.

### Rules for any AI agent working on this repo

- **Do not guess.** If an OPEN item (section 14) blocks you, stop and ask a human.
- **Small tasks, one branch per task.** Do not mix refactors with features. Do not push to `main`.
- **Do not change the JSON contract** (section 7) without explicit human approval. Everything depends on it.
- **Never commit secrets.** No API keys in the app or in git. LLM calls move to the backend.
- **Do not build features outside the current phase** (section 11).
- **Do not delete or stub out the Bluetooth duel.** The project guide requires it.
- **Do not create a third app shell.** Consolidate into one (T0.5).
- **In new UI:** no emojis, no generic Material icons where an illustration belongs, no purple-gradient defaults. Marathi and English must both render with a font that has Devanagari glyphs.
- **Verify before claiming done:** run `flutter analyze` and `flutter test` (and the backend tests once they exist). Say plainly what you could not run.
- **When you finish a task,** tick it in section 16 and add a line to the progress log.

### Quick map of the repo (branch `nova`)

| Path | What it is |
|---|---|
| `lib/main.dart` | Riverpod + Drift app shell (`MajheGaonApp`). Recommended survivor. |
| `lib/nova_main/` | A second, older app with its own state and routes. To be merged into the above. |
| `lib/core/services/` | `bkt_game_master_engine.dart`, `llm_game_master_service.dart`, `nova_schema_repository.dart`, `nova_audio_service.dart` |
| `lib/core/models/nova_schema_models.dart` | DB models and the level contract classes |
| `lib/core/data/nova_seed_catalog.dart` | Seed skills, questions and the 10-asset catalogue |
| `lib/core/db/` | Drift database |
| `lib/features/duel/` | Bluetooth math duel (mostly simulated) |
| `lib/features/voice_engine/` | Voice answer matcher (Levenshtein, Devanagari numerals) |
| `lib/features/screens/` | Home hub, level road, class selection, story adventure (3,740 lines) |
| `nova-main/` | Empty Flutter scaffold. Delete. |
| `.agent/skills/` | Rules read by Antigravity. Currently wrong. Rewrite. |

### Environment caveats

The planning chat had no Flutter SDK, so **no code was compiled or run**. Anything Claude wrote or will write in Dart is unverified until built on a machine with Flutter. Repo reviewed: `github.com/vaishnavikunte/nova`, branch `nova` (read-only, shallow clone). First pass at `9a7cbb8` (5 commits by Nikhil Sakpal), then re-checked at `762a76f` (19 Oct, "Level 3 and 4 added"); see the update note in section 3. The app was **not** built or run, because there was no Flutter SDK available, so everything below about the code comes from reading it.

Status labels used throughout:
- **DECIDED**: stated by the project owner. It overrides the older markdown docs.
- **RECOMMENDED**: suggested in the chat, not yet confirmed.
- **OPEN**: still needs an answer.

---

## 1. What we are building

A Duolingo-style, level-based gamified study app for primary students in India. The app should feel kid-friendly and visual, and levels are driven by story scenes with questions inside them.

## 2. Decisions (these override `Nova System Architecture & TechStack.md` and `Nova Database Schema.md` where they conflict)

| Topic | Decision | Status |
|---|---|---|
| Connectivity | Assume the student has internet (project guide's rule), but the app must still work in weak-internet areas | DECIDED |
| Content | An LLM generates stories and, where possible, questions via API, to avoid hand-making every level | DECIDED |
| Visuals | A small reusable set of base characters and backgrounds, composed dynamically from LLM-produced JSON | DECIDED |
| Structure | **No class-wise split.** A placement test at registration assigns a starting level | DECIDED |
| Difficulty | Questions grouped by difficulty; learning outcomes mapped per level or per group of levels, used to drive LLM generation | DECIDED |
| Languages | Marathi and English for now | DECIDED |
| Grades | Design for 1–7, build only grades 1–4 to prove the architecture | DECIDED |
| Content delivery | Hybrid: a verified bank of stories and questions, ahead-of-time LLM generation, cached levels for weak internet | DECIDED |
| Bluetooth duel (Ganit Dangal) | Must stay, because the project guide requires it. Build it with **Android Nearby Connections** (decided 2026-10-22) | DECIDED |
| Art production | All art assets are generated with Gemini. The owner will send the asset list | DECIDED |
| Budget and people | No designer and no budget for art | DECIDED |
| Character art style | Not the Warli style. Needs proper expressions, built in 1–2 days by 2 people | DECIDED |
| Tooling | Use Antigravity for integration work, with Claude producing docs, contract, backend, templates and the UI | DECIDED (plan) |

## 3. What the repo is today

- A Flutter app. The internal package name is `majhe_gaon`, with NOVA branding. It uses Riverpod, Drift/SQLite, `flutter_tts`, `speech_to_text`, Lottie, Rive and `flutter_blue_plus`. About 27k lines of Dart.
- No backend exists. The repo contains only the Flutter app.
- Only 3 small test files (about 76 lines). Nothing tests the new game master.
- `README.md` is still the Flutter default.

### Root problem

The repo is built on two incompatible visions:
- The **architecture doc**: online, server-authoritative, FastAPI, Postgres, Firebase, Gemini.
- The **`.agent/skills/*.md` rules** (the folder Antigravity reads, as far as we know): fully offline, "no cloud AI", under 100 MB, no PNG/JPG, Bluetooth duels, Standard 3 and 4 only.

The last commit then added direct Gemini and Groq calls from the app, which breaks the offline rules. The assets also break the PNG rule (43 PNG/JPG files, 33 MB).

### Concrete problems found

1. **Won't compile from a fresh clone.** `lib/core/services/llm_game_master_service.dart` imports `lib/core/config/local_api_keys.dart`, which is gitignored and not in the repo. Fix (T0.2): commit a key-less `local_api_keys.dart` that reads keys from `--dart-define`, and remove it from `.gitignore`.
2. **Two apps in one `lib/`.** `lib/main.dart` (Riverpod + Drift) and `lib/nova_main/main.dart` (custom state + named routes) are separate apps that import each other. Duplicate filenames: `adaptive_engine.dart`, `class_selection_screen.dart`, `app_theme.dart`.
3. **Three adaptive engines:** a simple BKT (`features/diagnostic`), a rule-based emotion engine (`nova_main/services`), and the new per-skill BKT game master (`core/services/bkt_game_master_engine.dart`).
4. **Three story screens.** One of them, `story_adventure_screen.dart`, is 3,740 lines.
5. **Stray `nova-main/` folder:** an empty Flutter scaffold with 20 lines of Dart. Safe to delete.
6. **API key shipped in the client:** the Gemini key is read from a local file and sent from the app. Anyone can extract it from the APK. No real key was ever committed (all 5 commits checked).
7. **No validation of LLM output.** The service parses the JSON and trusts it. Answers are never verified.
8. **Hard-coded content.** `curriculum_data.dart` and `assessment_data.dart` and most `nova_main` screens are static.
9. **Branches:** `main` is a single "first commit". The real work is on `nova`. Other branches: `nova-oct12-backup`, `feature/std1-level1-story`.

### Update: commit `762a76f` ("Level 3 and 4 added", 19 Oct, by `vaishnavikunte`)

The first review was at `9a7cbb8`. The branch has since gained one commit, and it makes the "everything is static" problem bigger:

- **Levels 3 and 4 were added by hard-coding.** `lib/core/services/llm_game_master_service.dart` now has 14 `levelNum ==` nested ternaries with hand-written Marathi titles and story lines (one title contains an emoji). Each new level also got its own large painter widget: `banyan_grove_stage_widget.dart` (421 lines), `village_market_stage_widget.dart` (517), `village_school_fair_stage_widget.dart` (829). This is the opposite of the data-driven scene renderer. **Do not add Level 5 this way.** Treat per-level stage widgets and per-level ternaries as legacy, to be replaced by the catalogue-driven renderer (T3.3).
- **The seed catalogue grew:** 5 characters, 4 backdrops, 14 props (23 assets) plus 4 shape assets, 48 questions, and about a dozen new Lottie files. Section 7's "10 assets" figure refers to the first review.
- **The team added `lib/core/config/local_api_keys.dart.example`,** which reads keys from `--dart-define`. The real `local_api_keys.dart` is still gitignored, so a fresh clone still does not compile. The Phase 0 package commits a key-less `local_api_keys.dart` with the same content; delete the `.example` afterwards.
- **Still true at `762a76f`:** `nova-main/` exists, the four old `.agent/skills` files are unchanged, `README.md` is the Flutter default, `flutter_blue_plus` is still a dependency, and the Android manifest has no Bluetooth or Nearby permissions. Now 122 Dart files, about 30k lines.

### Worth keeping

- The BKT math is correct.
- The Levenshtein voice matcher handles Devanagari numerals and Marathi words (for example पंचवीस → 25).
- The DB model classes match the schema doc.
- The contract classes (`GeneratedLevelContract` and related) are a usable start.
- The local fallback level generator is a good idea.
- The seed-based duel question generator works offline and is deterministic.

## 4. Target architecture (RECOMMENDED, consistent with the decisions above)

Split the system into two loops.

- **Content factory (server, slow):** plan, generate, validate, retry, store in the bank.
- **Play loop (phone, fast):** render from JSON, check answers locally, run a small local BKT, queue logs, sync later.

### End-to-end workflow

1. **Register:** language, avatar and nickname. No real names, since these are children.
2. **Placement test:** about 10–15 adaptive questions, each tagged to a skill, drawn only from the verified bank so it works offline. It initialises a mastery estimate per skill.
3. **Level request:** code, not the LLM, picks the skill(s), difficulty tier, language, theme and characters from the student's mastery gaps.
4. **Serve or generate:** serve a verified unseen story from the bank, otherwise run the generation pipeline. The phone always prefetches the next 2 levels.
5. **Play:** the app renders the level JSON, checks answers locally and updates local mastery.
6. **Sync:** when online, send the action log. The server reconciles mastery and returns updated state and new levels.
7. **Quality loop:** per-question stats feed back. A question nobody answers correctly is probably wrong, so flag it. One everyone gets right gets re-tiered.

If a generation call is slow or fails, the child never notices, because they are already playing a cached level.

### Backend (RECOMMENDED)

FastAPI with SQLite first (the schema design stays compatible with Postgres later). No Firebase auth yet, just a username and device ID. Four endpoints: register and placement, next level, submit results, sync. Move the Gemini key server-side. Port the existing prompt builder, contract models and BKT engine from the app to the server.

## 5. Story generation (RECOMMENDED)

Never ask the LLM for "a story". Give it a fixed arc to fill.

- **Inputs, chosen by code:** skill and difficulty, language, theme, 2–3 characters from a fixed cast, number of scenes, and a short summary of the previous level for continuity.
- **Fixed arc:** hook, problem, question, reaction, repeat, then celebration. One beat plus one question slot per scene.
- **Series feel:** a recurring cast and a village that changes as the student progresses.
- **Hard limits in the prompt, enforced by code afterward:** words per scene by grade, simple Marathi, nothing frightening.
- **Marathi and English:** generate each natively. Do not translate.
- **Stories are reusable:** key them by (skill, tier, theme, language), not by student.

## 6. Question formation (RECOMMENDED)

Three routes, chosen by risk:

- **A. Parameterized templates (most math):** code picks the numbers and computes the answer, so it is correct by construction. The LLM only writes the story wording. Distractors come from real mistakes (for example a forgotten carry).
- **B. LLM-written with verification (Marathi language and similar):** the LLM drafts, then code and an independent check validate it. A native Marathi speaker reviews the first batches before they enter the bank.
- **C. Hand-written seed set:** a small reviewed set for placement tests and fallback.

Fixed rules:
- **Question types:** `voice_input`, `match_following`, `spot_item`, `fill_blanks`. Each has a strict payload schema. The LLM cannot invent new types.
- **Difficulty is defined by parameters, not LLM judgment.** For example tier 1 is numbers under 10 with no carry, tier 3 is two-digit with carry. Calibrate later from real answer data.
- **Every question carries a skill ID.** Levels map to a skill or skill group, which is also what placement measures.
- **Skills graph:** needs prerequisites and level bands. Start with one subject (probably math, because templates guarantee correct answers) and add Marathi language skills once the pipeline works.

### Placement test

Adaptive, not fixed: start mid-difficulty and move up or down. It sets an initial mastery estimate per skill, not a single level number, and BKT keeps correcting it. Use bank questions only, not live LLM output.

## 7. Animation from a fixed asset catalogue (RECOMMENDED)

The LLM only chooses from named options and writes text. It never draws. Variety comes from combinations (for example 6 characters × 6 expressions × 8 motions × 8 backdrops).

Sketch of the v2 scene contract (the current contract only has one backdrop, character, prop and expression per scene, with no positions or timeline):

```json
{
  "scene_id": 3,
  "text": {"mr": "चिंटूला झाडाखाली आंबे सापडले!", "en": "Chintu found mangoes under the tree!"},
  "backdrop": "bg_banyan_grove",
  "actors": [
    {"id": "char_chintu", "slot": "left", "expression": "curious", "enter": "walk_in_left"},
    {"id": "char_tiger", "slot": "right", "expression": "idle", "loop": "idle_bounce"}
  ],
  "props": [{"id": "prop_mango", "slot": "ground_center", "count": 5, "enter": "pop_in_staggered"}],
  "timeline": [
    {"at": 0.0, "do": "narrate"},
    {"at": 1.5, "actor": "char_chintu", "do": "point_at", "target": "prop_mango"},
    {"at": 3.0, "do": "show_question"}
  ],
  "question_ref": "Q_COUNT_05_v3",
  "on_correct": {"actor": "char_chintu", "expression": "happy", "play": "jump", "sfx": "sfx_cheer"},
  "on_wrong":   {"actor": "char_tiger", "expression": "encouraging", "play": "head_tilt"}
}
```

Rules for the validator:
- Fixed named slots (left, center, right, ground). The LLM never outputs pixel coordinates.
- Enums everywhere. Any unknown asset, expression or motion name means reject and retry.
- Cross-checks: the mango `count` must equal the question's answer, at most 3 actors, and every asset must exist.

**Key idea:** the JSON is the script. Rive, Lottie, images or code-drawn art are the actors and stage. How a character is drawn is a client detail, so the art approach can be swapped later without touching the pipeline.

### Current catalogue is tiny

At the first review the catalogue in `lib/core/data/nova_seed_catalog.dart` had 10 assets (4 characters, 4 props, 2 backdrops). At `762a76f` it has 23 (5 characters, 4 backdrops, 14 props) plus 4 shapes, but characters have no mood variants and nothing is data-driven yet. Demo target: about 4 backdrops, 2–3 characters with 4–5 moods each, about 10 props, about 6 motions.

## 8. Art approach (RECOMMENDED, not confirmed)

Constraints: no designer, no budget, not Warli style, proper expressions, 1–2 days, 2 people.

**Option 1 (recommended): expression-swapped image characters ("paper doll").**
- Each character is a set of images, one per mood. JSON `"expression"` swaps the image with a cross-fade. JSON `"play"` runs a Flutter transform on the whole image (bounce, jump, tilt, shake, slide-in). No rigging.
- Generate one character sheet per character with an image generator (all moods in one image for consistency), crop, remove the background (open-source `rembg`), export as WebP.
- Scope: 2 characters × 4 moods (idle, happy, curious, encouraging), 3 backdrops, about 8 props.
- Plan: Day 1 morning, person A locks one style and generates sheets while person B builds the Flutter character widget. Day 1 afternoon, clean and trim all images to a common canvas and anchor point. Day 2, integrate and test on a cheap Android phone.
- Risks: character drift between moods (biggest risk), the generic "AI look", artifacts such as odd hands or faces, and no limb animation (no walking, waving or lip-sync). Also check the image generator's terms and whether the college allows AI-generated art.

**Option 2: free pre-made animated characters** (Rive community, LottieFiles, itch.io, OpenGameArt). Fastest if one author and one consistent style covers all characters, but licenses vary per file and mixed packs look patchworked. Give it a one-hour search in parallel.

**Rive** was also discussed. Best approach there: one `.riv` per character with one state machine (a `mood` input plus triggers like `jump`, `wave`, `point`, `head_tilt`), identical input names across characters, and Rive only for characters. Rough estimate: 1.5–2 weeks for 3 characters with an experienced person and 3–4 weeks for a beginner, mostly spent on drawing. The `rive` version in `pubspec.yaml` is `^0.13.0`, and its Flutter API changed in later versions, so check current docs. Suggested de-risking: a 2-day spike with one character and 3 moods wired to the JSON.

**DECIDED (2026-10-22):** all art is generated with Gemini. The owner will send the asset list. Generate all moods of one character in a single sheet to keep it consistent.

## 9. UI notes

Why the current UI looks AI-made:
- Palette: purple `#6C47FF` with gold and mint on cream, "extracted" from the generated PNG mockups in `assets/Design System/`.
- Fonts: Baloo 2 and Nunito (the default kid-friendly pair AI tools pick). Nunito has no Devanagari glyphs as far as we know, so Marathi text probably falls back to a system font.
- 166 Material `Icons.*` usages, an emoji in feedback strings (for example 💎 in `feedback_messages.dart`), uniform rounded cards, 3D bevel buttons and gradients everywhere.

Direction (RECOMMENDED):
- Progress as an illustrated map or path, not cards.
- Voice-first and icon-first. Every prompt has audio and a picture (a Grade 1 child reads slowly).
- A small deliberate palette of 4–5 colours.
- A Devanagari font tested together with the Latin font.
- Replace Material icons and emojis with illustration.
- Big touch targets.
- The illustrated look still depends on the character and backdrop art. The owner prefers Claude's UI designs, so the plan is for Claude to do the UI. Plan: a clickable HTML mockup of 3–4 screens (home path, placement question, level scene, result) for approval, then port to Flutter.

## 10. Bluetooth duel (Ganit Dangal), required by the project guide

Reading `lib/features/duel/` shows it is **mostly simulated**:
- `DuelHostService.startHost()` is only comments. Nothing advertises or runs a GATT server. `flutter_blue_plus` is central/client only, so a host needs another package (such as `flutter_ble_peripheral`).
- `duel_lobby_screen.dart` fakes the connection with `_mockIncomingTimer` and `Future.delayed`.
- The Android manifest has no Bluetooth permissions (only microphone and internet).
- Real parts: the client scan and connect code, and `duel_question_generator.dart` (shared seed, same 10 questions on both phones with no network).
- The code passes `License.nonprofit` to `flutter_blue_plus`. Verify that licence applies to this project.

Recommendations:
- **DECIDED (2026-10-22): use Android Nearby Connections** (the `nearby_connections` package). It is Android-only, uses Bluetooth and Wi-Fi underneath, and is far simpler for two phones than a hand-built GATT server. Once it works, remove `flutter_blue_plus` from `pubspec.yaml`.
- Testing needs two real Android phones. Emulators cannot do Bluetooth. Budget about a full day.
- The seed-based generator fits the planned deterministic math templates.

## 11. Priority plan in phases

Effort is a rough guess for a small team working in parallel. The deadline is not known.

**Phase 0: Align (about 1 day, P0).** Write the decisions doc. Rewrite `.agent/skills` to match. Pick one app shell (recommendation: keep the Riverpod and Drift one, `lib/main.dart`, and migrate what is needed from `nova_main`). Freeze new features. Delete `nova-main/`. Commit a key-less `local_api_keys.dart` that reads keys from `--dart-define`. Write a real README. Assign owners (engine, app, art). *Done when:* a fresh clone builds and everyone has read the doc.

**Phase 1: Contract and data model (2–3 days, P0).** JSON contract v2 plus a validator. Schema v2: skills with prerequisites and level bands, a levels table, language fields, a generated-levels cache, placement results and validation status. Skills graph for grades 1–4, starting with math. *Done when:* a hand-written sample level passes the validator and a broken one fails.

**Phase 2: Backend and generation pipeline (4–6 days, P0).** FastAPI plus SQLite, the four endpoints, math templates, the LLM-with-verification route, the story pipeline (plan, generate, validate, retry, store), server BKT, and tests. *Done when:* one command generates a validated Marathi and English level from a skill and difficulty, and bad LLM output is rejected and retried.

**Phase 3: App vertical slice (5–7 days, P0).** Register, adaptive placement, level assignment, prefetch and cache with an offline fallback level, the scene renderer from JSON, the character widget, local BKT, the log queue and sync. *Done when:* you can register, play placement, get a level, play it in airplane mode, sync later, and the next level changes based on answers.

**Phase 4: Look and feel (3–5 days, parallel from Phase 1, P1).** Lock the art style and produce characters, backdrops and props. Fix typography and palette, replace Material icons and emojis, rebuild home as an illustrated path. *Done when:* a stranger would not guess it was generated.

**Phase 5: Hardening and demo (3–4 days, P1).** Test on a cheap real Android phone (including Marathi text-to-speech and speech recognition, and a throttled network). Native Marathi speaker reviews the question bank. Enough content for a demo. Architecture diagram, demo script, small metrics view (mastery curves, validation reject rate).

**Later (P2).** Grades 5–7, coin store and rewards, accounts and parental consent, Hindi, teacher dashboard.

**Duel work** (build the real Nearby Connections implementation) is required, so schedule it alongside Phase 3 and test it on two phones.

### Cut for now

Class selection and the old `nova_main` screens (placement replaces them), and the coin store. The duel is NOT cut.

### Two tracks

- **Engine** (Phases 1–2): contract, schema, backend, BKT.
- **App and art** (Phases 3–4): renderer, placement UI and characters.

Freeze the contract at the end of Phase 1 so neither track blocks the other.

## 12. Working with Antigravity (RECOMMENDED)

- It reads the `.agent/` folder. Its current rules tell it to go offline, so **fix them before anything else**.
- **Division:** Claude produces the decisions doc, contract, schema, validator, backend and tests, the templates and the UI. Antigravity wires files into the repo, merges the app shells, deletes duplicates, runs `flutter analyze` and fixes compile errors.
- **Rules:** one small task at a time, one branch per task, review every diff, no contract changes without a person approving, tests as the gate (contract, BKT and validator tests).
- Put the decisions doc and rules in the repo so the tool stays on course.
- Claude cannot compile Flutter in its environment and cannot push to the repo, so Claude's Dart is untested until the team builds it, and the team commits the files.
- The Antigravity details here are from memory, not verified. Check its current features and free-tier limits.

## 13. Risks

- **LLM output quality** (mitigated by the validator and templates).
- **Marathi speech on real phones.** Text-to-speech and speech recognition availability varies, and offline recognition for kids' speech is weak. Always provide a tap fallback.
- **Marathi LLM phrasing errors.** Needs a native speaker's review.
- **Children's data.** The app would collect kids' voice, nicknames and gameplay logs. India's DPDP Act has parental-consent provisions for under-18s. Check the current rules with the guide before any real pilot.
- **Art quality and consistency** with no designer.
- **Bluetooth duel**, which is currently fake and needs real two-phone testing.

## 14. Open questions

1. Deadline?
2. Who owns the backend, and how many developers are on the engine track?
3. The asset list for the Gemini-generated art (the owner will send it).
4. Is AI-generated art allowed by the college and project guide?
5. Does anyone on the team enjoy drawing or vector tools (Figma, Inkscape)?
6. Is math the right first subject for the demo?

## 15. What was verified and what was not

- **Verified by reading the repo:** structure, entry points, duplicates, the contract and catalogue, the LLM service (no validation, key in client), the duel code (mostly simulated), the git history, that no real API key was committed, and asset sizes.
- **Not verified:** that the app builds or runs, how the UI or characters actually look, whether the story screen actually uses the LLM contract end to end, Antigravity's current features, Rive's current free-tier limits and package API.
- **Estimates** (time, effort) are rough guesses, not measurements.
- Claude has not produced the following yet: `DECISIONS.md`, rewritten `.agent` rules, `TASKS.md`, contract v2, schema v2, validator, backend, templates, UI mockup. As of 2026-10-22 the Phase 0 package (DECISIONS.md, rewritten `.agent` rules, README, key-less `local_api_keys.dart`, Antigravity prompts) has been prepared but not applied or tested; the rest remains.

---

## 16. Task backlog (copy each block as a prompt for an AI agent)

Mark tasks `[x]` when done. Each has acceptance criteria.

### Phase 0: Align

- [ ] **T0.1 Rewrite `.agent/skills/*.md` to match the decisions.** Replace the old rules with: online-hybrid app that must still work in weak internet (cache and offline fallback); LLM-generated content goes through a validator and a verified bank; no class-based structure, a placement test assigns levels; Marathi and English; grades 1–4 only for now but design for 1–7; Riverpod and Drift stay; the Bluetooth duel stays; PNG/WebP assets are allowed, keep total size reasonable; no API keys in the client. *Accept:* no remaining rule contradicts section 2, and the old "no cloud AI" and "Std 3 and 4 only" rules are gone.
- [ ] **T0.2 Make a fresh clone build.** Commit a `lib/core/config/local_api_keys.dart` that reads keys from `--dart-define` (no secrets in git), remove its line from `.gitignore`, and document the run command in the README. *Accept:* `flutter pub get && flutter analyze` has no missing-import error for `local_api_keys.dart`.
- [ ] **T0.3 Delete the stray `nova-main/` folder.** *Accept:* the folder is gone and nothing imports from it.
- [ ] **T0.4 Write a real `README.md`.** Cover what Nova is, the decisions summary, how to run, folder map, and a link to this handover. Replace the Flutter default text. *Accept:* README matches section 2.
- [ ] **T0.5 Plan the app-shell consolidation (analysis only, no code changes).** Produce a table of every screen, service and model in `lib/nova_main/` versus `lib/core`, `lib/features`, saying keep, merge, or delete, and what each depends on. Propose the order of moves. Do not delete anything yet. *Accept:* a written plan the owner approves.
- [ ] **T0.6 Branch hygiene.** Propose how to land `nova` as the real mainline and what to do with `nova-oct12-backup` and `feature/std1-level1-story`. Ask the owner before any force-push or branch deletion.

### Phase 1: Contract and data model

- [ ] **T1.1 Write the v2 level contract as a JSON Schema** (section 7: slots, expressions, motion presets, timeline, `question_ref`, `on_correct`, `on_wrong`, text in `mr` and `en`). Store at `contracts/level_v2.schema.json` with example files. *Accept:* the example level validates and at least 5 deliberately broken examples fail.
- [ ] **T1.2 Write schema v2** (SQLite first, Postgres-compatible): skills with prerequisites and level band, levels, level-to-skill mapping, questions with `language`, `difficulty_tier`, `question_type`, `status` (draft, verified, rejected), generated-levels cache, placement results, per-user BKT state, gameplay logs. *Accept:* a migration script creates the tables and a seed script loads a small grade 1–4 math skills graph.
- [ ] **T1.3 Build the validator** (Python, for the backend; mirror the key checks in Dart for the client). Checks: schema, known asset IDs, known expression and motion names, at most 3 actors, props `count` consistent with the answer, correct answer present in options, language fields non-empty. *Accept:* unit tests cover every rule.
- [ ] **T1.4 Define the grade 1–4 math skills graph** with prerequisites and three difficulty tiers per skill, each tier defined by parameters (number range, carry, steps), not by LLM judgment. *Accept:* the owner or a teacher reviews the list.

### Phase 2: Backend and generation pipeline

- [ ] **T2.1 FastAPI skeleton + SQLite** with endpoints: register and placement, next level, submit results, sync. *Accept:* the OpenAPI doc loads and each endpoint has a test.
- [ ] **T2.2 Math question templates:** code generates numbers, correct answer and distractors from real mistakes; deterministic from a seed. Reuse the same generator for the duel. *Accept:* property tests prove the stored answer always equals the computed answer.
- [ ] **T2.3 Story pipeline:** plan, generate, validate, retry (max N), store. Fixed arc and word limits from section 5. Gemini key on the server only. *Accept:* one command generates a validated Marathi and English level, and malformed LLM output is rejected and retried.
- [ ] **T2.4 Server-side BKT** ported from `bkt_game_master_engine.dart`, with tests. *Accept:* known inputs give known mastery values.
- [ ] **T2.5 Question stats loop:** flag questions with near-zero correct rate. *Accept:* a report lists suspect questions.

### Phase 3: App vertical slice

- [ ] **T3.1 Adaptive placement flow** (bank questions only, works offline). *Accept:* a new user ends with per-skill mastery and a starting level.
- [ ] **T3.2 Level fetch, prefetch (next 2 levels) and cache,** with a bundled fallback level for offline. *Accept:* airplane mode still lets the user play.
- [ ] **T3.3 Scene renderer** that draws a level from v2 JSON (backdrop, actors in slots, props, timeline). *Accept:* the example level renders on a device.
- [ ] **T3.4 Character widget:** expression swap with cross-fade and motion presets (bounce, jump, tilt, shake, slide-in) driven by JSON; unknown names fall back safely. *Accept:* every motion and expression in the contract plays.
- [ ] **T3.5 Local BKT + action log queue + sync.** *Accept:* answers made offline sync later and the next level difficulty changes.
- [ ] **T3.6 Remove client-side LLM calls** and use the backend instead. *Accept:* no API key anywhere in the app.
- [ ] **T3.7 Bluetooth duel for real.** Use Android Nearby Connections (decided; the `nearby_connections` package). Implement host and client, add the required Android permissions, remove the mock timers, use the seed-based question generator, and drop `flutter_blue_plus` once replaced. *Accept:* two physical Android phones complete a duel, and scores update live.

### Phase 4: Look and feel

- [ ] **T4.1 UI mockup** (clickable, 3–4 screens: home path, placement question, level scene, result) for owner approval before any Flutter UI code.
- [ ] **T4.2 Art:** character sheets (2 characters × 4 moods), 3 backdrops, about 8 props, background removed, common canvas and anchor, WebP. Owner's team produces these. *Accept:* consistent style, files named like `char_tiger_happy.webp`.
- [ ] **T4.3 Theme rebuild:** new palette, Devanagari-capable fonts, remove emojis and generic icons, illustrated level path. *Accept:* Marathi text renders in the chosen font on a real device.

### Phase 5: Hardening and demo

- [ ] **T5.1 Real-device tests** on a cheap Android phone: Marathi TTS and speech recognition, throttled network.
- [ ] **T5.2 Native Marathi speaker reviews** the question bank.
- [ ] **T5.3 Seed enough content** for a demo (a few levels per skill).
- [ ] **T5.4 Architecture diagram, demo script, small metrics view** (mastery curves, validation reject rate).

---

## 17. Progress log

Add one line per completed task: date, task ID, who or which agent, short note.

- 2026-10-21: handover written. No implementation work done yet.
- 2026-10-22: Phase 0 package prepared (DECISIONS.md, rewritten `.agent` rules, README, key-less `local_api_keys.dart`, Antigravity prompts); not yet applied to the repo or tested. Decisions recorded: Nearby Connections for the duel, all art generated with Gemini.
