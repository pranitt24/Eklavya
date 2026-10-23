"""Run from repo root: python tools/add_nova.py
Registers the Nova guide (char_nova, 7 poses) in assets/nova/manifest.json and backend/asset_manifest.json."""
import json
from pathlib import Path
new = json.loads((Path(__file__).parent / "_nova_assets.json").read_text(encoding="utf-8"))
actor = {"group": "characters", "poses": sorted(e["id"].replace("char_nova_", "") for e in new),
         "pose_map": {"idle": "standing", "happy": "happy", "curious": "thinking",
                      "encouraging": "pointing", "surprised": "happy"}}
mp = Path("assets/nova/manifest.json")
m = json.loads(mp.read_text(encoding="utf-8"))
have = {a["id"] for a in m["assets"]}
m["assets"] += [e for e in new if e["id"] not in have]
m.setdefault("actors", {})["char_nova"] = actor
mp.write_text(json.dumps(m, ensure_ascii=False, indent=2), encoding="utf-8")
bp = Path("backend/asset_manifest.json")
b = json.loads(bp.read_text(encoding="utf-8"))
b["actors"]["char_nova"] = actor
bp.write_text(json.dumps(b, ensure_ascii=False, indent=1), encoding="utf-8")
print("Nova registered with poses:", actor["poses"])
