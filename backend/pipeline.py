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
    last = None
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
            last = RuntimeError(f"model {m}: HTTP {e.code} {detail}")
            if e.code not in (404, 400, 429, 500, 502, 503, 504):
                raise last
        except (TimeoutError, urllib.error.URLError) as e:   # slow or unreachable: try the next model
            last = RuntimeError(f"model {m}: {type(e).__name__}")
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


def generate_level(skill_id, grade, tier=1, kind=None, prop=None, seed=None, use_llm=True, retries=2, known_skills=None):
    """Returns (level, info). info says whether Gemini text or fallback text was used and why."""
    load_env()
    kind = kind or T.kind_from_skill(skill_id)
    info = {"source": "fallback", "attempts": 0, "errors": []}
    level, facts = T.build_level(kind, grade, tier, skill_id, prop, seed)
    if use_llm and os.environ.get("GEMINI_API_KEY"):
        for _ in range(retries + 1):
            info["attempts"] += 1
            try:
                raw = _gemini_text(_prompt(kind, grade, facts["a"], facts["b"], facts["answer"], facts["prop"]))
                raw = re.sub(r"^```(?:json)?|```$", "", raw.strip(), flags=re.M).strip()
                texts = json.loads(raw)
                if not _texts_ok(kind, facts["a"], facts["b"], texts):
                    info["errors"].append("gemini text missing keys or numbers"); continue
                cand, _ = T.build_level(kind, grade, tier, skill_id, facts["prop"], seed, texts)
                errs = validate_level(cand, known_skills)
                if errs:
                    info["errors"].append([e["code"] + "@" + e["path"] for e in errs][:5]); continue
                level, info["source"] = cand, "gemini"
                break
            except (urllib.error.URLError, TimeoutError, KeyError, ValueError, RuntimeError) as e:
                info["errors"].append(f"{type(e).__name__}: {str(e)[:120]}")
    elif use_llm:
        info["errors"].append("GEMINI_API_KEY not set; used fallback text")
    errs = validate_level(level, known_skills)
    if errs:  # should never happen: skeleton is valid by construction
        raise ValueError(f"generated level failed validation: {errs[:3]}")
    return level, info
