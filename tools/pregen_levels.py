"""Pre-generate levels into backend/nova.db so the demo works even if Gemini is slow/down.
Run from repo root:  python tools/pregen_levels.py            (uses Gemini if key set, else fallback text)
                     python tools/pregen_levels.py --no-llm   (instant, built-in text only)"""
import sys, time, pathlib
sys.path.insert(0, str(pathlib.Path(__file__).resolve().parents[1]))
from backend.pipeline import generate_level
from backend.server import store, db
db().close()
use_llm = "--no-llm" not in sys.argv
n = 0
for grade, tiers in ((1, (1, 2, 3)), (2, (1, 2, 3)), (3, (1, 2)), (4, (1, 2))):
    for tier in tiers:
        for skill_kind in (None, "add", "sub"):      # None = mixed story for the grade
            for seed in range(2):
                sid = f"M{grade}_STORY" if skill_kind is None else f"M{grade}_{skill_kind.upper()}"
                lv, info = generate_level(sid, grade, tier, None, seed=grade*1000+tier*100+seed*10+n, use_llm=use_llm)
                store(lv, info["source"]); n += 1
                print(f"{lv['level_id']:40s} {info['source']:9s} {len(lv['questions'])} tasks")
                if use_llm: time.sleep(1)
print("stored", n, "levels")
