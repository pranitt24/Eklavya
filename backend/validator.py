"""Level contract v2 validator. Pure Python (no dependencies).
Usage:  errors = validate_level(level_dict, known_skills={"M1_ADD_10", ...})
Empty list == valid. Each error is {"path", "code", "msg"}."""
import re
from . import catalog as C

DEVANAGARI = re.compile(r"[\u0900-\u097F]")


def _err(errs, path, code, msg):
    errs.append({"path": path, "code": code, "msg": msg})


def _words(s):
    return len(str(s).split())


def _check_text(errs, path, obj, grade=None, limit=True):
    if not isinstance(obj, dict):
        return _err(errs, path, "TEXT_NOT_OBJECT", "expected {mr, en}")
    for lang in C.LANGS:
        v = obj.get(lang)
        if not isinstance(v, str) or not v.strip():
            _err(errs, f"{path}.{lang}", "TEXT_EMPTY", f"'{lang}' text missing or empty")
    mr, en = obj.get("mr"), obj.get("en")
    if isinstance(mr, str) and mr.strip() and not DEVANAGARI.search(mr):
        _err(errs, f"{path}.mr", "MR_NOT_DEVANAGARI", "Marathi text has no Devanagari characters")
    if limit and grade in C.MAX_WORDS_PER_SCENE:
        for lang, v in (("mr", mr), ("en", en)):
            if isinstance(v, str) and _words(v) > C.MAX_WORDS_PER_SCENE[grade]:
                _err(errs, f"{path}.{lang}", "TOO_LONG",
                     f"{_words(v)} words > limit {C.MAX_WORDS_PER_SCENE[grade]} for grade {grade}")
    if isinstance(en, str):
        bad = {w.strip(".,!?").lower() for w in en.split()} & C.BANNED_WORDS_EN
        if bad:
            _err(errs, f"{path}.en", "BANNED_WORD", f"not child-safe: {sorted(bad)}")


def _check_question(errs, path, q):
    if not isinstance(q, dict):
        return _err(errs, path, "Q_NOT_OBJECT", "question must be an object")
    qt = q.get("type")
    if qt not in C.QUESTION_TYPES:
        return _err(errs, f"{path}.type", "Q_UNKNOWN_TYPE", f"unknown question type {qt!r}")
    _check_text(errs, f"{path}.prompt", q.get("prompt"), limit=False)
    if qt == "voice_input":
        a = q.get("answer")
        if not isinstance(a, (int, float)) or isinstance(a, bool):
            _err(errs, f"{path}.answer", "Q_ANSWER_INVALID", "voice_input needs numeric 'answer'")
    elif qt in ("spot_item", "fill_blanks"):
        opts = q.get("options")
        if not isinstance(opts, list) or len(opts) < 2:
            return _err(errs, f"{path}.options", "Q_OPTIONS_INVALID", "need >= 2 options")
        if len(set(map(str, opts))) != len(opts):
            _err(errs, f"{path}.options", "Q_OPTIONS_DUPLICATE", "duplicate options")
        if q.get("answer") not in opts:
            _err(errs, f"{path}.answer", "Q_ANSWER_NOT_IN_OPTIONS", "correct answer not among options")
    elif qt == "match_following":
        pairs = q.get("pairs")
        if not isinstance(pairs, list) or len(pairs) < 2 or not all(
                isinstance(p, dict) and "left" in p and "right" in p for p in pairs):
            _err(errs, f"{path}.pairs", "Q_PAIRS_INVALID", "need >= 2 pairs with left/right")
        elif len({str(p["left"]) for p in pairs}) != len(pairs) or \
                len({str(p["right"]) for p in pairs}) != len(pairs):
            _err(errs, f"{path}.pairs", "Q_PAIRS_AMBIGUOUS", "duplicate left/right values")
    cp = q.get("counts_prop")
    if cp is not None and cp not in C.PROPS:
        _err(errs, f"{path}.counts_prop", "UNKNOWN_ASSET", f"unknown prop {cp!r}")
    elif cp is not None and cp not in C.COUNTABLE_PROPS:
        _err(errs, f"{path}.counts_prop", "PROP_NOT_COUNTABLE", f"{cp!r} is not a countable prop")


def validate_level(level, known_skills=None):
    errs = []
    if not isinstance(level, dict):
        return [{"path": "$", "code": "NOT_OBJECT", "msg": "level must be an object"}]
    if level.get("schema_version") != "2.0":
        _err(errs, "schema_version", "BAD_VERSION", "must be '2.0'")
    for k in ("level_id", "skill_id", "theme"):
        if not isinstance(level.get(k), str) or not level.get(k):
            _err(errs, k, "MISSING_FIELD", f"'{k}' required")
    grade = level.get("grade")
    if grade not in (1, 2, 3, 4):
        _err(errs, "grade", "BAD_GRADE", "grade must be 1-4 (design allows 1-7 later)")
    if level.get("difficulty_tier") not in (1, 2, 3):
        _err(errs, "difficulty_tier", "BAD_TIER", "tier must be 1, 2 or 3")
    if known_skills is not None and level.get("skill_id") not in known_skills:
        _err(errs, "skill_id", "UNKNOWN_SKILL", f"unknown skill {level.get('skill_id')!r}")
    _check_text(errs, "title", level.get("title"), limit=False)
    _check_text(errs, "summary", level.get("summary"), limit=False)

    qs = level.get("questions")
    qmap = {}
    if not isinstance(qs, list) or not qs:
        _err(errs, "questions", "NO_QUESTIONS", "need at least one question")
    else:
        for i, q in enumerate(qs):
            p = f"questions[{i}]"
            qid = q.get("id") if isinstance(q, dict) else None
            if not qid:
                _err(errs, p, "Q_NO_ID", "question needs id")
            elif qid in qmap:
                _err(errs, p, "Q_DUP_ID", f"duplicate question id {qid}")
            else:
                qmap[qid] = q
            _check_question(errs, p, q)

    scenes = level.get("scenes")
    used_q = set()
    if not isinstance(scenes, list) or not (1 <= len(scenes) <= C.MAX_SCENES):
        _err(errs, "scenes", "BAD_SCENE_COUNT", f"need 1-{C.MAX_SCENES} scenes")
        scenes = scenes if isinstance(scenes, list) else []
    seen_ids = set()
    for i, s in enumerate(scenes):
        p = f"scenes[{i}]"
        if not isinstance(s, dict):
            _err(errs, p, "SCENE_NOT_OBJECT", "scene must be an object")
            continue
        sid = s.get("scene_id")
        if sid in seen_ids:
            _err(errs, f"{p}.scene_id", "DUP_SCENE_ID", f"duplicate scene_id {sid}")
        seen_ids.add(sid)
        _check_text(errs, f"{p}.text", s.get("text"), grade=grade)
        if s.get("backdrop") not in C.BACKDROPS:
            _err(errs, f"{p}.backdrop", "UNKNOWN_ASSET", f"unknown backdrop {s.get('backdrop')!r}")
        actors = s.get("actors", [])
        if not isinstance(actors, list) or len(actors) > C.MAX_ACTORS:
            _err(errs, f"{p}.actors", "TOO_MANY_ACTORS", f"max {C.MAX_ACTORS} actors")
            actors = actors if isinstance(actors, list) else []
        slots, actor_ids = set(), set()
        for j, a in enumerate(actors):
            ap = f"{p}.actors[{j}]"
            if a.get("id") not in C.CHARACTERS:
                _err(errs, f"{ap}.id", "UNKNOWN_ASSET", f"unknown character {a.get('id')!r}")
            if a.get("slot") not in C.ACTOR_SLOTS:
                _err(errs, f"{ap}.slot", "UNKNOWN_SLOT", f"unknown slot {a.get('slot')!r}")
            elif a["slot"] in slots:
                _err(errs, f"{ap}.slot", "SLOT_TAKEN", f"slot {a['slot']} used twice")
            slots.add(a.get("slot"))
            actor_ids.add(a.get("id"))
            if a.get("expression", "idle") not in C.EXPRESSIONS:
                _err(errs, f"{ap}.expression", "UNKNOWN_EXPRESSION", f"{a.get('expression')!r}")
            for mk in ("enter", "loop"):
                if mk in a and a[mk] not in C.MOTIONS:
                    _err(errs, f"{ap}.{mk}", "UNKNOWN_MOTION", f"{a[mk]!r}")
        props = s.get("props", [])
        prop_counts = {}
        for j, pr in enumerate(props if isinstance(props, list) else []):
            pp = f"{p}.props[{j}]"
            if pr.get("id") not in C.PROPS:
                _err(errs, f"{pp}.id", "UNKNOWN_ASSET", f"unknown prop {pr.get('id')!r}")
            if pr.get("slot") not in C.PROP_SLOTS:
                _err(errs, f"{pp}.slot", "UNKNOWN_SLOT", f"{pr.get('slot')!r}")
            cnt = pr.get("count", 1)
            if not isinstance(cnt, int) or isinstance(cnt, bool) or not (1 <= cnt <= 20):
                _err(errs, f"{pp}.count", "BAD_COUNT", "count must be int 1-20")
            else:
                prop_counts[pr.get("id")] = prop_counts.get(pr.get("id"), 0) + cnt
            if "enter" in pr and pr["enter"] not in C.MOTIONS:
                _err(errs, f"{pp}.enter", "UNKNOWN_MOTION", f"{pr['enter']!r}")
        qref = s.get("question_ref")
        if qref is not None:
            if qref not in qmap:
                _err(errs, f"{p}.question_ref", "UNKNOWN_QUESTION", f"{qref!r} not in questions")
            else:
                q = qmap[qref]
                used_q.add(qref)
                cp = q.get("counts_prop")
                if cp and prop_counts.get(cp) != q.get("answer"):
                    _err(errs, f"{p}.props", "COUNT_MISMATCH",
                         f"{cp} count {prop_counts.get(cp)} != answer {q.get('answer')}")
        for key in ("on_correct", "on_wrong"):
            r = s.get(key)
            if r is None:
                continue
            rp = f"{p}.{key}"
            if r.get("actor") not in actor_ids:
                _err(errs, f"{rp}.actor", "ACTOR_NOT_IN_SCENE", f"{r.get('actor')!r}")
            if r.get("expression", "idle") not in C.EXPRESSIONS:
                _err(errs, f"{rp}.expression", "UNKNOWN_EXPRESSION", f"{r.get('expression')!r}")
            if "play" in r and r["play"] not in C.MOTIONS:
                _err(errs, f"{rp}.play", "UNKNOWN_MOTION", f"{r['play']!r}")
            if "sfx" in r and r["sfx"] not in C.SFX:
                _err(errs, f"{rp}.sfx", "UNKNOWN_ASSET", f"{r['sfx']!r}")
        if qref is not None and ("on_correct" not in s or "on_wrong" not in s):
            _err(errs, p, "MISSING_REACTION", "scene with a question needs on_correct and on_wrong")
        last, has_sq = -1.0, False
        for j, t in enumerate(s.get("timeline", []) or []):
            tp = f"{p}.timeline[{j}]"
            at = t.get("at")
            if not isinstance(at, (int, float)) or at < 0 or at < last:
                _err(errs, f"{tp}.at", "BAD_TIME", "'at' must be >= 0 and non-decreasing")
            else:
                last = at
            do = t.get("do")
            if do not in C.TIMELINE_ACTIONS:
                _err(errs, f"{tp}.do", "UNKNOWN_ACTION", f"{do!r}")
            if do == "show_question":
                has_sq = True
                if qref is None:
                    _err(errs, tp, "SHOW_Q_NO_QUESTION", "show_question but scene has no question_ref")
            if "actor" in t and t["actor"] not in actor_ids:
                _err(errs, f"{tp}.actor", "ACTOR_NOT_IN_SCENE", f"{t['actor']!r}")
            if "play" in t and t["play"] not in C.MOTIONS:
                _err(errs, f"{tp}.play", "UNKNOWN_MOTION", f"{t['play']!r}")
        if qref is not None and not has_sq:
            _err(errs, f"{p}.timeline", "NO_SHOW_QUESTION", "scene has a question but never shows it")
    for qid in set(qmap) - used_q:
        _err(errs, "questions", "ORPHAN_QUESTION", f"question {qid} not used by any scene")
    return errs


def is_valid(level, known_skills=None):
    return not validate_level(level, known_skills)
