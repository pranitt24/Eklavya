import copy, json, sqlite3, unittest
from pathlib import Path
from backend.validator import validate_level
from backend.db.init_db import init, known_skill_ids

ROOT = Path(__file__).resolve().parents[2]
VALID = json.loads((ROOT / "contracts/examples/level_valid.json").read_text(encoding="utf-8"))
SKILLS = {"M1_COUNT_10"}


def codes(level, skills=SKILLS):
    return {e["code"] for e in validate_level(level, skills)}


def mut(fn):
    d = copy.deepcopy(VALID); fn(d); return d


class ValidatorTests(unittest.TestCase):
    def test_valid_passes(self):
        self.assertEqual(validate_level(VALID, SKILLS), [])

    def test_unknown_backdrop(self):
        self.assertIn("UNKNOWN_ASSET", codes(mut(lambda d: d["scenes"][0].update(backdrop="bg_moon"))))

    def test_unknown_character(self):
        self.assertIn("UNKNOWN_ASSET", codes(mut(lambda d: d["scenes"][0]["actors"][0].update(id="char_dragon"))))

    def test_unknown_expression(self):
        self.assertIn("UNKNOWN_EXPRESSION", codes(mut(lambda d: d["scenes"][0]["actors"][0].update(expression="angry"))))

    def test_unknown_motion(self):
        self.assertIn("UNKNOWN_MOTION", codes(mut(lambda d: d["scenes"][0]["actors"][0].update(enter="teleport"))))

    def test_too_many_actors(self):
        def f(d):
            d["scenes"][1]["actors"] = [{"id": "char_girl", "slot": "left"}, {"id": "char_grandmother", "slot": "center"},
                                        {"id": "char_boy", "slot": "right"}, {"id": "char_boy", "slot": "right"}]
        self.assertIn("TOO_MANY_ACTORS", codes(mut(f)))

    def test_slot_taken(self):
        self.assertIn("SLOT_TAKEN", codes(mut(lambda d: d["scenes"][1]["actors"][1].update(slot="left"))))

    def test_count_mismatch(self):
        self.assertIn("COUNT_MISMATCH", codes(mut(lambda d: d["scenes"][1]["props"][0].update(count=4))))

    def test_wrong_answer_not_in_options(self):
        def f(d):
            d["questions"][0].update(type="spot_item", options=[3, 4, 6], answer=5)
        self.assertIn("Q_ANSWER_NOT_IN_OPTIONS", codes(mut(f)))

    def test_voice_answer_not_numeric(self):
        self.assertIn("Q_ANSWER_INVALID", codes(mut(lambda d: d["questions"][0].update(answer="five"))))

    def test_unknown_question_type(self):
        self.assertIn("Q_UNKNOWN_TYPE", codes(mut(lambda d: d["questions"][0].update(type="essay"))))

    def test_empty_marathi(self):
        self.assertIn("TEXT_EMPTY", codes(mut(lambda d: d["scenes"][0]["text"].update(mr=""))))

    def test_marathi_not_devanagari(self):
        self.assertIn("MR_NOT_DEVANAGARI", codes(mut(lambda d: d["scenes"][0]["text"].update(mr="Chintu came"))))

    def test_too_long_for_grade(self):
        self.assertIn("TOO_LONG", codes(mut(lambda d: d["scenes"][0]["text"].update(en=" ".join(["word"] * 40)))))

    def test_banned_word(self):
        self.assertIn("BANNED_WORD", codes(mut(lambda d: d["scenes"][0]["text"].update(en="A scary ghost came."))))

    def test_unknown_question_ref(self):
        self.assertIn("UNKNOWN_QUESTION", codes(mut(lambda d: d["scenes"][1].update(question_ref="Q9"))))

    def test_orphan_question(self):
        def f(d):
            d["questions"].append({"id": "Q2", "type": "voice_input", "prompt": d["questions"][0]["prompt"], "answer": 2})
        self.assertIn("ORPHAN_QUESTION", codes(mut(f)))

    def test_missing_reaction(self):
        self.assertIn("MISSING_REACTION", codes(mut(lambda d: d["scenes"][1].pop("on_wrong"))))

    def test_reaction_actor_not_in_scene(self):
        self.assertIn("ACTOR_NOT_IN_SCENE", codes(mut(lambda d: d["scenes"][1]["on_correct"].update(actor="char_boy"))))

    def test_show_question_missing(self):
        self.assertIn("NO_SHOW_QUESTION", codes(mut(lambda d: d["scenes"][1]["timeline"].pop())))

    def test_timeline_order(self):
        self.assertIn("BAD_TIME", codes(mut(lambda d: d["scenes"][1]["timeline"][1].update(at=-1))))

    def test_unknown_skill(self):
        self.assertIn("UNKNOWN_SKILL", codes(VALID, {"OTHER"}))

    def test_bad_grade_and_tier(self):
        c = codes(mut(lambda d: d.update(grade=9, difficulty_tier=7)))
        self.assertTrue({"BAD_GRADE", "BAD_TIER"} <= c)


class DbTests(unittest.TestCase):
    def test_init_and_seed(self):
        con = init(":memory:")
        n = con.execute("SELECT COUNT(*) FROM skills").fetchone()[0]
        self.assertGreaterEqual(n, 18)
        self.assertEqual(con.execute("SELECT COUNT(*) FROM skill_tiers").fetchone()[0], n * 3)
        self.assertIn("M1_COUNT_10", known_skill_ids(con))

    def test_valid_example_with_db_skills(self):
        self.assertEqual(validate_level(VALID, known_skill_ids(init(":memory:"))), [])


if __name__ == "__main__":
    unittest.main()


class CatalogTests(unittest.TestCase):
    def test_pose_map_covers_all_expressions_and_poses_exist(self):
        from backend import catalog as C
        for aid, a in C.ACTORS.items():
            self.assertEqual(set(a["pose_map"]), C.EXPRESSIONS, aid)
            for pose in a["pose_map"].values():
                self.assertIn(pose, a["poses"], (aid, pose))

    def test_every_catalog_id_exists_in_manifest_assets(self):
        from backend import catalog as C
        have = {a["id"] for a in C.MANIFEST["assets"]}
        for b in C.BACKDROPS: self.assertIn(b, have)
        for p in C.PROPS: self.assertIn(p, have)
        for aid, a in C.ACTORS.items():
            for pose in a["poses"]: self.assertIn(f"{aid}_{pose}", have)

    def test_countable_props_subset_of_props(self):
        from backend import catalog as C
        self.assertTrue(C.COUNTABLE_PROPS <= C.PROPS)

    def test_counts_prop_must_be_countable(self):
        def f(d):
            d["questions"][0]["counts_prop"] = "env_well"
            d["scenes"][1]["props"][0].update(id="env_well")
        self.assertIn("PROP_NOT_COUNTABLE", codes(mut(f)))
