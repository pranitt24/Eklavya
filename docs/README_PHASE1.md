# Nova Phase 1 drop-in (contract v2, validator, schema v2, skills)

Copy into the repo root (keeps paths): `contracts/`, `backend/`, `docs/math_skills_g1_4.json`.

Run checks (no dependencies, Python 3.9+):
    python -m unittest backend.tests.test_validator
    python -m backend.db.init_db nova.db      # creates DB + seeds 21 skills

What is here
- `contracts/level_v2.schema.json`  structure of a level (for the Flutter side / docs)
- `contracts/examples/`             1 valid level + 5 deliberately broken ones
- `backend/validator.py`            the real gatekeeper: rejects unknown assets, wrong answers, count mismatches, too-long text, etc.
- `backend/catalog.py`              placeholder asset names. EDIT THIS when the Gemini asset list is final
- `backend/db/schema_v2.sql`        tables: skills, tiers, questions, levels, cache, users, mastery, placement, logs, stats
- `docs/math_skills_g1_4.json`      21 grade 1-4 math skills, prerequisites, 3 tiers each defined by parameters

When the asset list arrives: update `catalog.py` and the enums in `level_v2.schema.json`; tests keep passing as long as the example uses names that still exist.
Note: the contract is now frozen for Phase 2/3 unless the owner approves a change.
