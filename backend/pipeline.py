"""B3: story pipeline. Skeleton from templates.py, text from Gemini Flash, validated, retried, with fallback.
API key comes ONLY from env GEMINI_API_KEY (or backend/.env, which must be git-ignored)."""
import json, os, re, urllib.request, urllib.error
from pathlib import Path
from . import templates as T
from .validator import validate_level

MODELS = [m for m in (os.environ.get("GEMINI_MODEL"), "gemini-2.5-flash", "gemini-3.5-flash", "gemini-2.5-flash-lite", "gemini-flash-latest") if m]
MODELS = list(dict.fromkeys(MODELS))
URL = "https://generativelanguage.googleapis.com/v1beta/models/{m}:generateContent"
WORD_LIMIT = {1: 25, 2: 30, 3: 40, 4: 50}
KEYS = ("title", "summary", "intro", "question_scene", "prompt", "wrap")


def load_env():
    p = Path(__file__).parent / ".env"
    if p.exists():
        for line in p.read_text(encoding="utf-8").splitlines():
            if "=" in line and not line.strip().startswith("#"):
                k, v = line.split("=", 1)
                os.environ.setdefault(k.strip(), v.strip().strip('"').strip("'"))


def _gemini_text(prompt, timeout=40):
    """Tries each model name in MODELS; remembers the first that works."""
    key = os.environ.get("GEMINI_API_KEY")
    if not key:
        raise RuntimeError("GEMINI_API_KEY not set")
    body = json.dumps({"contents": [{"parts": [{"text": prompt}]}],
                       "generationConfig": {"responseMimeType": "application/json", "temperature": 0.8}}).encode()
    last, seen = None, []
    for m in list(MODELS):
        req = urllib.request.Request(URL.format(m=m), data=body,
                                     headers={"Content-Type": "application/json", "x-goog-api-key": key})
        try:
            with urllib.request.urlopen(req, timeout=timeout) as r:
                data = json.load(r)
            if MODELS[0] != m:
                MODELS.remove(m); MODELS.insert(0, m)
            return data["candidates"][0]["content"]["parts"][0]["text"]
        except urllib.error.HTTPError as e:
            detail = e.read().decode("utf-8", "ignore")[:300]
            msg = (re.search(r'"message":\s*"([^"]{0,80})', detail) or [None, ""])[1]
            seen.append(f"{m}: HTTP {e.code} {msg}")
            last = RuntimeError(" | ".join(seen))
            if e.code not in (404, 400, 429, 500, 502, 503, 504):
                raise last
        except (TimeoutError, urllib.error.URLError) as e:   # slow or unreachable: try the next model
            seen.append(f"{m}: {type(e).__name__}"); last = RuntimeError(" | ".join(seen))
    raise last


def _prompt(kind, grade, a, b, ans, prop):
    mr_n, en_n, _ = T.PROPS_INFO[prop]
    lim = WORD_LIMIT[grade]
    return f"""You write tiny math stories for village school children (grade {grade}) in Marathi and English.
Guide character: Nova, a friendly helper. Other characters are unnamed children/family. Setting: an Indian village.
Math facts (DO NOT change numbers): kind={kind}, a={a}, b={b}, answer={ans}, objects={en_n} (Marathi: {mr_n}).
Return ONLY JSON with keys {list(KEYS)}; each value is {{"mr": "...", "en": "..."}}.
Rules: Marathi in Devanagari; each of intro/question_scene/wrap at most {lim-5} words per language;
simple words; child-safe and cheerful; never reveal the answer {ans}; the question text (question_scene and prompt)
must contain the numbers a{'' if b is None else ' and b'} exactly as digits and ask for the result;
title and summary are short. Do not mention anything scary or violent."""


def _texts_ok(kind, a, b, texts):
    if not isinstance(texts, dict) or any(k not in texts for k in KEYS):
        return False
    for k in KEYS:
        v = texts[k]
        if not isinstance(v, dict) or not all(isinstance(v.get(l), str) and v[l].strip() for l in ("mr", "en")):
            return False
    en = texts["prompt"]["en"]
    need = [a] + ([b] if b is not None and kind != "count" else [])
    if kind == "count":
        need = []
    return all(str(n) in en for n in need)


def _story_prompt(grade, facts, prop):
    mr_n, en_n, _ = T.PROPS_INFO[prop]
    lim = WORD_LIMIT[grade] - 5
    lines = "\n".join(f"{i+1}. kind={f['kind']}, a={f['a']}, b={f['b']}, answer={f['answer']}" for i, f in enumerate(facts))
    return f"""You write a short illustrated math STORY for village school children (grade {grade}) in Marathi and English.
Characters: Nova, a friendly guide, and one friend (unnamed). Setting: an Indian village. Objects: {en_n} (Marathi: {mr_n}).
The story has an intro, {len(facts)} tasks and a happy ending. Each task continues the same story in one short sentence and then asks its question.
Tasks (use the numbers EXACTLY as digits; NEVER reveal an answer):
{lines}
Return ONLY JSON: {{"title":{{"mr":"","en":""}},"summary":{{"mr":"","en":""}},"intro":{{"mr":"","en":""}},"tasks":[{{"mr":"","en":""}}],"wrap":{{"mr":"","en":""}}}}
with exactly {len(facts)} items in "tasks". Rules: Marathi in Devanagari; each intro/task/wrap at most {lim} words per language;
simple words; cheerful and child-safe; nothing scary or violent."""


def _ok(v):
    return isinstance(v, dict) and all(isinstance(v.get(l), str) and v[l].strip() for l in ("mr", "en"))


def _story_ok(facts, texts):
    if not isinstance(texts, dict) or not all(_ok(texts.get(k)) for k in ("title", "summary", "intro", "wrap")):
        return False
    tasks = texts.get("tasks")
    if not isinstance(tasks, list) or len(tasks) != len(facts) or not all(_ok(t) for t in tasks):
        return False
    for f, t in zip(facts, tasks):
        need = [f["a"]] + ([f["b"]] if f["kind"] != "count" else [])
        if not all(str(n) in t["en"] for n in need):
            return False
    return True


def generate_level(skill_id, grade, tier=1, kind=None, prop=None, seed=None, use_llm=True, retries=2,
                   known_skills=None, n_tasks=3):
    """kind None/'story' -> multi-task story (default). kind in count/add/sub/mul -> single-task level.
    Returns (level, info); info.source is 'gemini' or 'fallback'."""
    load_env()
    story = kind in (None, "story")
    info = {"source": "fallback", "attempts": 0, "errors": [], "mode": "story" if story else "single"}
    if story:
        k = T.kind_from_skill(skill_id, default=None)
        seq = [k] if k else list(T.STORY_KINDS[grade])
        kinds = [seq[i % len(seq)] for i in range(max(1, min(n_tasks, 4)))]
        level, meta = T.build_story_level(kinds, grade, tier, skill_id, prop, seed)
        facts, the_prop = meta["facts"], meta["prop"]
    else:
        level, f = T.build_level(kind, grade, tier, skill_id, prop, seed)
        facts, the_prop = [dict(kind=kind, a=f["a"], b=f["b"], answer=f["answer"])], f["prop"]
    if use_llm and os.environ.get("GEMINI_API_KEY"):
        for _ in range(retries + 1):
            info["attempts"] += 1
            try:
                if story:
                    raw = _gemini_text(_story_prompt(grade, facts, the_prop))
                else:
                    f0 = facts[0]
                    raw = _gemini_text(_prompt(kind, grade, f0["a"], f0["b"], f0["answer"], the_prop))
                raw = re.sub(r"^```(?:json)?|```$", "", raw.strip(), flags=re.M).strip()
                texts = json.loads(raw)
                if story:
                    if not _story_ok(facts, texts):
                        info["errors"].append("gemini story text missing parts or numbers"); continue
                    cand, _ = T.build_story_level(kinds, grade, tier, skill_id, the_prop, seed, texts)
                else:
                    if not _texts_ok(kind, facts[0]["a"], facts[0]["b"], texts):
                        info["errors"].append("gemini text missing keys or numbers"); continue
                    cand, _ = T.build_level(kind, grade, tier, skill_id, the_prop, seed, texts)
                errs = validate_level(cand, known_skills)
                if errs:
                    info["errors"].append([e["code"] + "@" + e["path"] for e in errs][:5]); continue
                level, info["source"] = cand, "gemini"
                break
            except (urllib.error.URLError, TimeoutError, KeyError, ValueError, RuntimeError) as e:
                info["errors"].append(f"{type(e).__name__}: {str(e)[:300]}")
                if "429" in str(e):
                    info["errors"].append("quota exceeded: stopped retrying; using fallback text")
                    break
    elif use_llm:
        info["errors"].append("GEMINI_API_KEY not set; used fallback text")
    errs = validate_level(level, known_skills)
    if errs:
        raise ValueError(f"generated level failed validation: {errs[:3]}")
    return level, info
