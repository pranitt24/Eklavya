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
for grade, tiers in ((1, (1, 2, 3)), (2, (1, 2)), (3, (1,)), (4, (1,))):
    for tier in tiers:
        for kind in ("count", "add", "sub", "mul"):
            if kind == "mul" and grade < 2: continue
            if kind == "count" and grade > 1: continue
            for seed in range(2):
                lv, info = generate_level(f"M{grade}_{kind.upper()}", grade, tier, kind, seed=grade*1000+tier*100+seed*10+n, use_llm=use_llm)
                store(lv, info["source"]); n += 1
                print(f"{lv['level_id']:40s} {info['source']}")
                if use_llm: time.sleep(1)
print("stored", n, "levels")
