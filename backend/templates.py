"""B2: deterministic math question templates + level skeleton builder.
The skeleton (scenes, actors, props, counts, answers) is built in code, so it is valid by construction.
Gemini (pipeline.py) only rewrites the TEXT fields; if it fails we use the fallback text below."""
import random
from . import catalog as C

# prop id -> (marathi plural noun, english plural noun, backdrop)
PROPS_INFO = {
    "prop_mango": ("आंबे", "mangoes", "bg_mango_trees"),
    "prop_apple": ("सफरचंदे", "apples", "bg_market"),
    "prop_banana": ("केळी", "bananas", "bg_market"),
    "prop_ball": ("चेंडू", "balls", "bg_village_road"),
    "prop_flower": ("फुले", "flowers", "bg_house_courtyard"),
    "prop_basket": ("टोपल्या", "baskets", "bg_market"),
    "prop_book": ("पुस्तके", "books", "bg_school"),
    "prop_star": ("तारे", "stars", "bg_village_overview"),
    "prop_pencil": ("पेन्सिली", "pencils", "bg_school"),
    "prop_laddu": ("लाडू", "laddus", "bg_house_courtyard"),
    "prop_chocolate": ("चॉकलेट", "chocolates", "bg_market"),
    "prop_coin_gold": ("नाणी", "coins", "bg_market"),
    "prop_pots": ("मडकी", "pots", "bg_house_courtyard"),
    "prop_lantern": ("कंदील", "lanterns", "bg_temple"),
    "animal_fish_normal": ("मासे", "fish", "bg_river"),
    "animal_parrot_perched": ("पोपट", "parrots", "bg_banyan_tree"),
    "animal_sparrow_perched": ("चिमण्या", "sparrows", "bg_banyan_tree"),
}
THEMES = [p for p in PROPS_INFO if p in C.COUNTABLE_PROPS]
ACTOR_PAIRS = [("char_nova", "char_boy"), ("char_nova", "char_girl"), ("char_nova", "char_mother"), ("char_nova", "char_grandmother")]  # Nova = guide, always on the left
KINDS = ("count", "add", "sub", "mul")


def kind_from_skill(skill_id, default="count"):
    s = (skill_id or "").upper()
    for key, kind in (("ADD", "add"), ("SUB", "sub"), ("MUL", "mul"), ("COUNT", "count")):
        if key in s:
            return kind
    return default


def _limit(kind, grade, tier):
    base = {1: 5, 2: 10, 3: 20}[tier] if grade == 1 else {1: 20, 2: 50, 3: 100}[tier] if grade == 2 \
        else {1: 100, 2: 500, 3: 999}[tier]
    return base


def make_numbers(kind, grade, tier, rng):
    m = _limit(kind, grade, tier)
    if kind == "count":
        a = rng.randint(2, min(m, 20))
        return a, None, a
    if kind == "add":
        a = rng.randint(1, max(1, m // 2)); b = rng.randint(1, max(1, m - a))
        return a, b, a + b
    if kind == "sub":
        a = rng.randint(2, m); b = rng.randint(1, a - 1)
        return a, b, a - b
    a = rng.randint(2, 5 if grade <= 3 else 9); b = rng.randint(2, 5 if tier == 1 else 9)
    return a, b, a * b


def fallback_text(kind, a, b, prop):
    mr_n, en_n, _ = PROPS_INFO[prop]
    T = lambda mr, en: {"mr": mr, "en": en}
    if kind == "count":
        q = T(f"चित्रात किती {mr_n} आहेत? मोजा आणि सांगा.", f"How many {en_n} are in the picture? Count and tell me.")
    elif kind == "add":
        q = T(f"एका बाजूला {a} आणि दुसऱ्या बाजूला {b} {mr_n} आहेत. एकूण किती?",
              f"There are {a} {en_n} on one side and {b} on the other. How many in all?")
    elif kind == "sub":
        q = T(f"{a} {mr_n} होते. {b} कमी झाले. आता किती उरले?",
              f"There were {a} {en_n}. {b} went away. How many are left?")
    else:
        q = T(f"{a} गट आहेत. प्रत्येक गटात {b} {mr_n} आहेत. एकूण किती?",
              f"There are {a} groups with {b} {en_n} in each group. How many in all?")
    return {
        "title": T(f"नोव्हा आणि {mr_n}", f"Nova and the {en_n}"),
        "summary": T(f"{mr_n} वापरून गणित शिकूया.", f"Let us learn math with {en_n}."),
        "intro": T(f"आज आपण {mr_n} घेऊन गणित शिकूया. नोव्हा मदत करेल!",
                   f"Today we learn math with {en_n}. Nova will help!"),
        "question_scene": q,
        "prompt": q,
        "wrap": T("शाब्बास! तुम्ही खूप छान केलं.", "Well done! You did a great job."),
    }


def build_level(kind, grade, tier, skill_id, prop=None, seed=None, texts=None):
    rng = random.Random(seed)
    _pick = rng.choice(THEMES)          # always draw, so passing prop= later does not shift the numbers
    prop = prop or _pick
    a, b, ans = make_numbers(kind, grade, tier, rng)
    txt = texts or fallback_text(kind, a, b, prop)
    _, _, bg = PROPS_INFO[prop]
    left, right = rng.choice(ACTOR_PAIRS)
    lid = f"{skill_id}_{kind}_g{grade}t{tier}_{rng.randrange(10**6):06d}"

    q = {"id": "q1", "type": "voice_input", "prompt": txt["prompt"], "answer": ans}
    if kind == "count":
        props = [{"id": prop, "slot": "ground_center", "count": a, "enter": "pop_in_staggered"}]
        q["counts_prop"] = prop
    elif kind == "add":
        props = [{"id": prop, "slot": "ground_left", "count": a, "enter": "pop_in_staggered"},
                 {"id": prop, "slot": "ground_right", "count": b, "enter": "pop_in_staggered"}]
        q["counts_prop"] = prop
    elif kind == "sub":
        props = [{"id": prop, "slot": "ground_center", "count": min(a, 20), "enter": "pop_in_staggered"}]
    else:
        props = [{"id": prop, "slot": "ground_center", "count": b, "enter": "pop_in_staggered"}]
    if kind in ("add", "count") and (a > 20 or (b or 0) > 20):  # cannot draw >20: drop visual count link
        q.pop("counts_prop", None)
        for p in props:
            p["count"] = min(p["count"], 20)

    actors = [{"id": left, "slot": "left", "expression": "idle", "enter": "walk_in_left", "loop": "idle_bounce"},
              {"id": right, "slot": "right", "expression": "curious", "enter": "walk_in_right"}]
    scenes = [
        {"scene_id": "s1", "text": txt["intro"], "backdrop": bg, "actors": actors, "props": [],
         "timeline": [{"at": 0, "do": "narrate"}, {"at": 1.5, "do": "play", "actor": left, "play": "wave"}]},
        {"scene_id": "s2", "text": txt["question_scene"], "backdrop": bg, "actors": actors, "props": props,
         "question_ref": "q1",
         "timeline": [{"at": 0, "do": "narrate"}, {"at": 2.5, "do": "show_question"}],
         "on_correct": {"actor": left, "expression": "happy", "play": "jump", "sfx": "sfx_cheer"},
         "on_wrong": {"actor": left, "expression": "encouraging", "play": "head_tilt", "sfx": "sfx_oops"}},
        {"scene_id": "s3", "text": txt["wrap"], "backdrop": bg, "actors": actors, "props": [],
         "timeline": [{"at": 0, "do": "narrate"}, {"at": 1.0, "do": "set_expression", "actor": right, "expression": "happy"}]},
    ]
    return {"schema_version": "2.0", "level_id": lid, "skill_id": skill_id, "grade": grade,
            "difficulty_tier": tier, "theme": prop, "title": txt["title"], "summary": txt["summary"],
            "questions": [q], "scenes": scenes}, {"a": a, "b": b, "answer": ans, "prop": prop}


def duel_questions(seed, n=10, grade=2):
    """Same seed -> same questions on both phones (A4)."""
    rng = random.Random(seed)
    out = []
    for i in range(n):
        kind = rng.choice(("add", "sub", "mul") if grade >= 2 else ("add", "sub"))
        a, b, ans = make_numbers(kind, grade, rng.choice((1, 2)), rng)
        sym = {"add": "+", "sub": "-", "mul": "×"}[kind]
        opts = {ans}
        while len(opts) < 4:
            opts.add(max(0, ans + rng.choice((-10, -3, -2, -1, 1, 2, 3, 10))))
        opts = sorted(opts); rng.shuffle(opts)
        expr = f"{a} {sym} {b} = ?"
        out.append({"id": f"d{i+1}", "type": "fill_blanks", "prompt": {"mr": expr, "en": expr},
                    "options": opts, "answer": ans})
    return out


# ---------------------------------------------------------------- multi-task STORY levels
STORY_KINDS = {1: ("count", "add", "sub"), 2: ("add", "sub", "mul"), 3: ("add", "sub", "mul"), 4: ("add", "sub", "mul")}
LEADS = [("चला सुरू करूया!", "Let us begin!"), ("छान! आता पुढे चला.", "Great! Now let us go on."),
         ("शाब्बास! आणखी एक.", "Well done! One more."), ("शेवटचा प्रश्न!", "Last one!")]


def fallback_story_text(facts, prop):
    mr_n, en_n, _ = PROPS_INFO[prop]
    tasks = []
    for i, f in enumerate(facts):
        q = fallback_text(f["kind"], f["a"], f["b"], prop)["question_scene"]
        lm, le = LEADS[min(i, len(LEADS) - 1)]
        tasks.append({"mr": f"{lm} {q['mr']}", "en": f"{le} {q['en']}"})
    return {
        "title": {"mr": f"नोव्हा आणि {mr_n}", "en": f"Nova and the {en_n}"},
        "summary": {"mr": f"{mr_n} वापरून गोष्ट आणि गणित.", "en": f"A story and math with {en_n}."},
        "intro": {"mr": f"आज नोव्हा आणि मित्र {mr_n} घेऊन गंमत करणार आहेत!",
                  "en": f"Today Nova and a friend will have fun with {en_n}!"},
        "tasks": tasks,
        "wrap": {"mr": "शाब्बास! तुम्ही सगळे प्रश्न सोडवले.", "en": "Well done! You solved every question."},
    }


def _props_for(kind, a, b, prop):
    """-> (props list, whether the visual count equals the answer)."""
    mk = lambda slot, n: {"id": prop, "slot": slot, "count": n, "enter": "pop_in_staggered"}
    if kind == "count":
        return [mk("ground_center", a)], True
    if kind == "add":
        if a <= 20 and b <= 20:
            return [mk("ground_left", a), mk("ground_right", b)], True
        return [], False
    if kind == "sub":
        return ([mk("ground_center", a)] if a <= 20 else []), False
    return ([mk("ground_center", b)] if b <= 20 else []), False


def build_story_level(kinds, grade, tier, skill_id, prop=None, seed=None, texts=None):
    """One story: intro scene, one scene per task (each with its own question), happy ending."""
    rng = random.Random(seed)
    _pick = rng.choice(THEMES)
    prop = prop or _pick
    left, right = rng.choice(ACTOR_PAIRS)
    _, _, bg = PROPS_INFO[prop]
    facts = []
    for kind in kinds:
        a, b, ans = make_numbers(kind, grade, tier, rng)
        facts.append({"kind": kind, "a": a, "b": b, "answer": ans})
    txt = texts or fallback_story_text(facts, prop)
    actors = [{"id": left, "slot": "left", "expression": "idle", "enter": "walk_in_left", "loop": "idle_bounce"},
              {"id": right, "slot": "right", "expression": "curious", "enter": "walk_in_right"}]
    questions, scenes = [], [
        {"scene_id": "s1", "text": txt["intro"], "backdrop": bg, "actors": actors, "props": [],
         "timeline": [{"at": 0, "do": "narrate"}, {"at": 1.5, "do": "play", "actor": left, "play": "wave"}]}]
    for i, f in enumerate(facts):
        qid = f"q{i+1}"
        props, linked = _props_for(f["kind"], f["a"], f["b"], prop)
        q = {"id": qid, "type": "voice_input", "prompt": txt["tasks"][i], "answer": f["answer"]}
        if linked:
            q["counts_prop"] = prop
        questions.append(q)
        scenes.append({"scene_id": f"s{i+2}", "text": txt["tasks"][i], "backdrop": bg, "actors": actors,
                       "props": props, "question_ref": qid,
                       "timeline": [{"at": 0, "do": "narrate"}, {"at": 2.5, "do": "show_question"}],
                       "on_correct": {"actor": left, "expression": "happy", "play": "jump", "sfx": "sfx_cheer"},
                       "on_wrong": {"actor": left, "expression": "encouraging", "play": "head_tilt", "sfx": "sfx_oops"}})
    scenes.append({"scene_id": f"s{len(facts)+2}", "text": txt["wrap"], "backdrop": bg, "actors": actors, "props": [],
                   "timeline": [{"at": 0, "do": "narrate"},
                                {"at": 1.0, "do": "set_expression", "actor": left, "expression": "happy"}]})
    lid = f"{skill_id}_story_g{grade}t{tier}_{rng.randrange(10**6):06d}"
    level = {"schema_version": "2.0", "level_id": lid, "skill_id": skill_id, "grade": grade,
             "difficulty_tier": tier, "theme": prop, "title": txt["title"], "summary": txt["summary"],
             "questions": questions, "scenes": scenes}
    return level, {"facts": facts, "prop": prop}
