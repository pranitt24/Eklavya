"""Student profiles, placement (level assignment) and progress. Pure sqlite3, no HTTP.
Stored locally only. Keep it minimal: name, age, optional class/school/avatar/language."""
import time

SCHEMA = """
CREATE TABLE IF NOT EXISTS students(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, age INT,
  gender TEXT, school TEXT, class_declared INT, language TEXT DEFAULT 'mr', avatar TEXT,
  grade INT, tier INT, created REAL);
CREATE TABLE IF NOT EXISTS placements(id INTEGER PRIMARY KEY AUTOINCREMENT, student_id INT, score INT, total INT,
  grade INT, tier INT, ts REAL);
CREATE TABLE IF NOT EXISTS progress(id INTEGER PRIMARY KEY AUTOINCREMENT, student_id INT, level_id TEXT,
  correct INT, total INT, stars INT, ts REAL);
"""


def init(con):
    con.executescript(SCHEMA)


def _clamp(v, lo, hi):
    return max(lo, min(hi, v))


def assign_level(age, correct, total):
    """Simple, explainable rule (NOT a validated assessment).
    Baseline grade from age (6->1, 7->2, 8->3, 9+->4); the placement score moves it."""
    base = _clamp((age or 7) - 5, 1, 4)
    ratio = (correct / total) if total else 0.5
    if ratio < 0.4:
        return _clamp(base - 1, 1, 4), 1
    if ratio < 0.75:
        return base, 1
    if ratio < 1.0 or total < 3:
        return base, 2
    return _clamp(base + 1, 1, 4), 1


def create_student(con, d):
    name = (d.get("name") or "").strip()
    if not name:
        raise ValueError("name is required")
    age = d.get("age")
    if age is not None:
        age = int(age)
        if not 3 <= age <= 15:
            raise ValueError("age must be 3-15")
    g, t = assign_level(age, 0, 0) if age else (1, 1)
    cur = con.execute("INSERT INTO students(name,age,gender,school,class_declared,language,avatar,grade,tier,created)"
                      " VALUES(?,?,?,?,?,?,?,?,?,?)",
                      (name, age, d.get("gender"), d.get("school"), d.get("class_declared"),
                       d.get("language", "mr"), d.get("avatar"), g, t, time.time()))
    con.commit()
    return get_student(con, cur.lastrowid)


def get_student(con, sid):
    r = con.execute("SELECT id,name,age,gender,school,class_declared,language,avatar,grade,tier FROM students WHERE id=?",
                    (sid,)).fetchone()
    if not r:
        return None
    keys = ("id", "name", "age", "gender", "school", "class_declared", "language", "avatar", "grade", "tier")
    return dict(zip(keys, r))


def list_students(con):
    return [get_student(con, r[0]) for r in con.execute("SELECT id FROM students ORDER BY id DESC")]


def record_placement(con, sid, correct, total):
    s = get_student(con, sid)
    if not s:
        raise ValueError("unknown student")
    g, t = assign_level(s["age"], int(correct), int(total))
    con.execute("INSERT INTO placements(student_id,score,total,grade,tier,ts) VALUES(?,?,?,?,?,?)",
                (sid, int(correct), int(total), g, t, time.time()))
    con.execute("UPDATE students SET grade=?, tier=? WHERE id=?", (g, t, sid))
    con.commit()
    return {"student_id": sid, "grade": g, "tier": t, "score": int(correct), "total": int(total)}


def record_progress(con, sid, level_id, correct, total):
    if not get_student(con, sid):
        raise ValueError("unknown student")
    stars = 3 if total and correct == total else 2 if total and correct / total >= 0.5 else 1
    con.execute("INSERT INTO progress(student_id,level_id,correct,total,stars,ts) VALUES(?,?,?,?,?,?)",
                (sid, level_id, int(correct), int(total), stars, time.time()))
    con.commit()
    return {"student_id": sid, "level_id": level_id, "stars": stars}


def get_progress(con, sid):
    rows = con.execute("SELECT level_id,correct,total,stars,ts FROM progress WHERE student_id=? ORDER BY ts", (sid,))
    return [dict(zip(("level_id", "correct", "total", "stars", "ts"), r)) for r in rows]
