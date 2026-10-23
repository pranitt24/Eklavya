# NOVA backend (B1-B3), standard library only

Run from repo root:
    cp backend/.env.example backend/.env   # then put your NEW Gemini key in .env (git-ignored)
    python -m unittest backend.tests.test_pipeline backend.tests.test_validator
    python -m backend.server                # http://0.0.0.0:8000
    adb reverse tcp:8000 tcp:8000           # phone reaches it at http://127.0.0.1:8000

Generate a level:
    curl -X POST localhost:8000/generate -H "Content-Type: application/json" -d "{\"skill_id\":\"M1_ADD_10\",\"grade\":1,\"tier\":1}"
Response info.source is "gemini" or "fallback" (fallback = built-in text, used when key missing / API fails / output invalid).

Design: templates.py builds the whole level skeleton in code (always valid), pipeline.py asks Gemini Flash only for
the Marathi/English text, validates, retries twice, then falls back. Duel: GET /duel/questions?seed=42&n=10&grade=2.

Assets: backend/asset_manifest.json = manifest.json + 11 new countable props (prop_apple, prop_ball, prop_banana,
prop_basket, prop_book, prop_chocolate, prop_flower, prop_laddu, prop_mango, prop_pencil, prop_star).
Copy the 11 PNGs to assets/nova/props/ as <id>.webp (or .png) and register them in the Flutter asset catalog + assets/nova/manifest.json.
