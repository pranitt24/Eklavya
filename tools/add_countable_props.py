"""Run from repo root:  python tools/add_countable_props.py
Adds the 11 countable props to assets/nova/manifest.json (assets list) and backend/asset_manifest.json."""
import json
from pathlib import Path
new = json.loads((Path(__file__).parent / "_new_props.json").read_text(encoding="utf-8"))
ids = [e["id"] for e in new]
mp = Path("assets/nova/manifest.json")
m = json.loads(mp.read_text(encoding="utf-8"))
have = {a["id"] for a in m["assets"]}
for e in new:
    if e["id"] not in have:
        m["assets"].append({k: v for k, v in e.items() if k != "countable"})
for key in ("props", "countable_props"):
    if key in m:
        m[key] = sorted(set(m[key]) | set(ids))
mp.write_text(json.dumps(m, ensure_ascii=False, indent=2), encoding="utf-8")
bp = Path("backend/asset_manifest.json")
b = json.loads(bp.read_text(encoding="utf-8"))
for key in ("props", "countable_props"):
    b[key] = sorted(set(b[key]) | set(ids))
bp.write_text(json.dumps(b, ensure_ascii=False, indent=1), encoding="utf-8")
print("added", len(ids), "props")
