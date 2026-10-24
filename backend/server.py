"""B1: tiny HTTP server (standard library only, no pip installs).
Run from the repo root:  python -m backend.server
Phone over USB:          adb reverse tcp:8000 tcp:8000   then the app calls http://127.0.0.1:8000
Endpoints:
  GET  /health
  GET  /levels?grade=1&skill_id=...        list stored levels (json)
  GET  /levels/<level_id>                  one level
  POST /generate  {"skill_id","grade","tier","kind","prop","seed","use_llm"}  -> {"level","info"} (also stored)
  GET  /duel/questions?seed=42&n=10&grade=2   same seed => same questions on both phones
  GET  /assets/countable                   countable prop ids
  POST /students {name, age, gender?, school?, class_declared?, language?, avatar?}  -> student (with starting grade/tier)
  GET  /students | /students/<id> | /students/<id>/levels | /students/<id>/progress
  POST /students/<id>/placement {correct,total} -> {grade,tier}      (assigns the level from the placement test)
  POST /students/<id>/progress  {level_id,correct,total} -> {stars}
  /generate with no "kind" (or kind="story") builds a multi-task story; kind=count|add|sub|mul builds a single task"""
import json, sqlite3, time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import urlparse, parse_qs
from . import catalog as C, templates as T, students as S
from .pipeline import generate_level, load_env
from .validator import validate_level

DB = Path(__file__).parent / "nova.db"


def db():
    con = sqlite3.connect(DB)
    con.execute("""CREATE TABLE IF NOT EXISTS levels(level_id TEXT PRIMARY KEY, skill_id TEXT, grade INT,
                   tier INT, json TEXT, source TEXT, created REAL)""")
    S.init(con)
    return con


def store(level, source):
    with db() as con:
        con.execute("INSERT OR REPLACE INTO levels VALUES(?,?,?,?,?,?,?)",
                    (level["level_id"], level["skill_id"], level["grade"], level["difficulty_tier"],
                     json.dumps(level, ensure_ascii=False), source, time.time()))


class H(BaseHTTPRequestHandler):
    def _send(self, code, obj):
        body = json.dumps(obj, ensure_ascii=False).encode("utf-8")
        self.send_response(code)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Access-Control-Allow-Origin", "*")
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        u = urlparse(self.path); q = {k: v[0] for k, v in parse_qs(u.query).items()}
        try:
            if u.path == "/health":
                return self._send(200, {"ok": True})
            if u.path == "/assets/countable":
                return self._send(200, sorted(C.COUNTABLE_PROPS))
            if u.path == "/duel/questions":
                return self._send(200, T.duel_questions(int(q.get("seed", 1)), int(q.get("n", 10)), int(q.get("grade", 2))))
            if u.path == "/levels":
                sql, args = "SELECT json FROM levels WHERE 1=1", []
                if "grade" in q: sql += " AND grade=?"; args.append(int(q["grade"]))
                if "skill_id" in q: sql += " AND skill_id=?"; args.append(q["skill_id"])
                with db() as con:
                    rows = [json.loads(r[0]) for r in con.execute(sql + " ORDER BY created DESC", args)]
                return self._send(200, rows)
            if u.path == "/students":
                with db() as con:
                    return self._send(200, S.list_students(con))
            if u.path.startswith("/students/"):
                parts = u.path.strip("/").split("/")
                sid = int(parts[1])
                with db() as con:
                    if len(parts) == 2:
                        r = S.get_student(con, sid)
                        return self._send(200, r) if r else self._send(404, {"error": "not found"})
                    if parts[2] == "progress":
                        return self._send(200, S.get_progress(con, sid))
                    if parts[2] == "levels":   # levels for this student's assigned grade (and tier if present)
                        st = S.get_student(con, sid)
                        if not st:
                            return self._send(404, {"error": "not found"})
                        rows = [json.loads(r[0]) for r in con.execute(
                            "SELECT json FROM levels WHERE grade=? ORDER BY ABS(tier-?), created DESC", (st["grade"], st["tier"]))]
                        return self._send(200, rows)
            if u.path.startswith("/levels/"):
                with db() as con:
                    r = con.execute("SELECT json FROM levels WHERE level_id=?", (u.path.split("/")[-1],)).fetchone()
                return self._send(200, json.loads(r[0])) if r else self._send(404, {"error": "not found"})
            self._send(404, {"error": "no such route"})
        except Exception as e:
            self._send(500, {"error": f"{type(e).__name__}: {e}"})

    def do_POST(self):
        path = urlparse(self.path).path
        if path.startswith("/students"):
            try:
                n = int(self.headers.get("Content-Length", 0))
                b = json.loads(self.rfile.read(n) or b"{}")
                parts = path.strip("/").split("/")
                with db() as con:
                    if len(parts) == 1:
                        return self._send(200, S.create_student(con, b))
                    sid = int(parts[1])
                    if parts[2] == "placement":
                        return self._send(200, S.record_placement(con, sid, b["correct"], b["total"]))
                    if parts[2] == "progress":
                        return self._send(200, S.record_progress(con, sid, b["level_id"], b["correct"], b["total"]))
                return self._send(404, {"error": "no such route"})
            except Exception as e:
                return self._send(400, {"error": f"{type(e).__name__}: {e}"})
        if path != "/generate":
            return self._send(404, {"error": "no such route"})
        try:
            n = int(self.headers.get("Content-Length", 0))
            b = json.loads(self.rfile.read(n) or b"{}")
            level, info = generate_level(b.get("skill_id", "M1_COUNT"), int(b.get("grade", 1)), int(b.get("tier", 1)),
                                         b.get("kind"), b.get("prop"), b.get("seed"), b.get("use_llm", True))
            store(level, info["source"])
            self._send(200, {"level": level, "info": info})
        except Exception as e:
            self._send(400, {"error": f"{type(e).__name__}: {e}"})

    def log_message(self, fmt, *a):
        print("%s %s" % (self.address_string(), fmt % a))


def main(port=8000):
    load_env(); db().close()
    print(f"NOVA backend on http://0.0.0.0:{port}")
    ThreadingHTTPServer(("0.0.0.0", port), H).serve_forever()


if __name__ == "__main__":
    main()
