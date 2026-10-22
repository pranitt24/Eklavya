# Nova: Decisions

Last updated 2026-10-22. These are the project owner's decisions. Where they conflict with `Nova System Architecture & TechStack.md`, `Nova Database Schema.md` or any older `.agent` rule, **this file wins**. Background and reasoning are in `docs/HANDOVER.md`.

## Product
- Duolingo-style, level-based gamified study app for primary students in India.
- Languages: Marathi and English.
- Grades: design for 1–7, but build and demo grades 1–4 only.
- **No class-wise structure.** A placement test at registration assigns the starting level.
- Questions are grouped by difficulty. Learning outcomes are mapped per level or per group of levels, and drive LLM generation.

## Connectivity
- Assume students have internet (project guide's rule), but the app must still function in weak-internet areas: cached levels, an offline fallback level, queued sync.

## Content
- An LLM generates stories (and questions where possible) through an API, to avoid hand-making every level.
- Hybrid delivery: a verified bank of stories and questions, ahead-of-time generation, cached levels on the device.
- The LLM only chooses from a fixed asset catalogue and writes text. It never draws.

## Art
- A small reusable catalogue: characters with several moods, backdrops, props.
- All assets are generated with Gemini by the team. The owner will send the asset list.
- Not the Warli style. No designer, no budget.

## Bluetooth duel (Ganit Dangal)
- Must stay (project guide's requirement).
- Built with **Android Nearby Connections**.

## Tooling
- Antigravity for integration work.
- Claude for design docs, the JSON contract, backend, question templates and the UI.

## Working assumptions (recommended, not yet approved by the owner)
- Backend: FastAPI with SQLite first, Postgres-compatible schema.
- Mastery tracking (BKT) runs on the phone for instant adaptation; the server reconciles.
- Math is the first demo subject, because templates make answers correct by construction.
- Characters are image sets per mood, animated with whole-image transforms in Flutter (Rive can replace this later without changing the contract).
- Keep the Riverpod + Drift app shell (`lib/main.dart`) and migrate what is needed from `lib/nova_main`.

## Still open
- Deadline.
- Who owns the backend, and how many developers are on the engine track.
- The asset list for Gemini generation (owner will send).
