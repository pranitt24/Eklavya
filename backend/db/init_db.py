"""Create the v2 database and seed the grade 1-4 math skills graph.
Run from repo root:  python -m backend.db.init_db [path/to/nova.db]"""
import json, sqlite3, sys
from pathlib import Path

HERE = Path(__file__).parent
SKILLS_JSON = HERE.parent.parent / "docs" / "math_skills_g1_4.json"


def init(db_path="nova.db"):
    con = sqlite3.connect(db_path)
    con.executescript((HERE / "schema_v2.sql").read_text(encoding="utf-8"))
    data = json.loads(SKILLS_JSON.read_text(encoding="utf-8"))
    for s in data["skills"]:
        con.execute("INSERT OR REPLACE INTO skills VALUES (?,?,?,?,?,?,?)",
                    (s["skill_id"], data["subject"], s["grade"], s["order"],
                     s["name"]["en"], s["name"]["mr"], s["question_type"]))
    for s in data["skills"]:
        for p in s["prerequisites"]:
            con.execute("INSERT OR IGNORE INTO skill_prerequisites VALUES (?,?)", (s["skill_id"], p))
        for t in s["tiers"]:
            params = {k: v for k, v in t.items() if k != "tier"}
            con.execute("INSERT OR REPLACE INTO skill_tiers VALUES (?,?,?)",
                        (s["skill_id"], t["tier"], json.dumps(params)))
    con.commit()
    return con


def known_skill_ids(con):
    return {r[0] for r in con.execute("SELECT skill_id FROM skills")}


if __name__ == "__main__":
    c = init(sys.argv[1] if len(sys.argv) > 1 else "nova.db")
    print("skills:", c.execute("SELECT COUNT(*) FROM skills").fetchone()[0])
