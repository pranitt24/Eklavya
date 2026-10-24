import unittest, os
from backend import templates as T
from backend.pipeline import generate_level
from backend.validator import validate_level


class TestTemplates(unittest.TestCase):
    def test_every_kind_grade_tier_prop_validates(self):
        n = 0
        for kind in T.KINDS:
            for grade in (1, 2, 3, 4):
                for tier in (1, 2, 3):
                    for prop in T.THEMES:
                        lv, _ = T.build_level(kind, grade, tier, "M_TEST", prop, seed=n)
                        self.assertEqual(validate_level(lv), [], (kind, grade, tier, prop))
                        n += 1
        self.assertGreater(n, 600)

    def test_new_props_are_countable_themes(self):
        for p in ("prop_mango", "prop_apple", "prop_banana", "prop_ball", "prop_flower", "prop_basket",
                  "prop_book", "prop_star", "prop_pencil", "prop_laddu", "prop_chocolate"):
            self.assertIn(p, T.THEMES)

    def test_fallback_pipeline_works_without_key(self):
        os.environ.pop("GEMINI_API_KEY", None)
        lv, info = generate_level("M1_ADD_10", 1, 1, seed=7)
        self.assertEqual(info["source"], "fallback")
        self.assertEqual(validate_level(lv), [])

    def test_duel_seed_is_deterministic(self):
        self.assertEqual(T.duel_questions(42), T.duel_questions(42))
        self.assertNotEqual(T.duel_questions(42), T.duel_questions(43))
        for q in T.duel_questions(5, 10, 3):
            self.assertIn(q["answer"], q["options"])
            self.assertEqual(len(set(q["options"])), 4)

    def test_count_answer_matches_props(self):
        lv, f = T.build_level("add", 1, 2, "M_X", "prop_mango", seed=3)
        total = sum(p["count"] for p in lv["scenes"][1]["props"])
        self.assertEqual(total, lv["questions"][0]["answer"])



class TestStories(unittest.TestCase):
    def test_every_story_validates(self):
        from backend.templates import build_story_level, STORY_KINDS, THEMES
        n = 0
        for grade in (1, 2, 3, 4):
            for tier in (1, 2, 3):
                for prop in THEMES:
                    for kinds in (STORY_KINDS[grade], ("add",) * 3, ("sub",) * 4, ("mul",) * 3):
                        lv, _ = build_story_level(list(kinds), grade, tier, "M_T", prop, seed=n)
                        self.assertEqual(validate_level(lv), [], (grade, tier, prop, kinds))
                        self.assertEqual(len(lv["questions"]), len(kinds))
                        n += 1
        self.assertGreater(n, 800)

    def test_rebuild_with_same_seed_keeps_numbers(self):
        from backend.templates import build_story_level
        a, meta = build_story_level(["add", "sub", "count"], 1, 2, "M_T", None, seed=11)
        b, _ = build_story_level(["add", "sub", "count"], 1, 2, "M_T", meta["prop"], seed=11)
        self.assertEqual([q["answer"] for q in a["questions"]], [q["answer"] for q in b["questions"]])

    def test_generate_default_is_story_with_three_tasks(self):
        os.environ.pop("GEMINI_API_KEY", None)
        lv, info = generate_level("M1_STORY", 1, 1, seed=3, use_llm=False)
        self.assertEqual(info["mode"], "story")
        self.assertEqual(len(lv["questions"]), 3)
        self.assertEqual(len(lv["scenes"]), 5)


class TestStudents(unittest.TestCase):
    def setUp(self):
        import sqlite3
        from backend import students as S
        self.S, self.con = S, sqlite3.connect(":memory:")
        S.init(self.con)

    def test_create_and_place(self):
        st = self.S.create_student(self.con, {"name": "Minu", "age": 7})
        self.assertEqual((st["grade"], st["tier"]), (2, 1))
        r = self.S.record_placement(self.con, st["id"], 3, 3)
        self.assertEqual((r["grade"], r["tier"]), (3, 1))
        r = self.S.record_placement(self.con, st["id"], 1, 5)
        self.assertEqual(r["grade"], 1)
        self.assertEqual(self.S.get_student(self.con, st["id"])["grade"], 1)

    def test_validation_and_progress(self):
        with self.assertRaises(ValueError):
            self.S.create_student(self.con, {"name": " "})
        with self.assertRaises(ValueError):
            self.S.create_student(self.con, {"name": "A", "age": 40})
        st = self.S.create_student(self.con, {"name": "Raj", "age": 6})
        self.assertEqual(self.S.record_progress(self.con, st["id"], "L1", 3, 3)["stars"], 3)
        self.assertEqual(len(self.S.get_progress(self.con, st["id"])), 1)


if __name__ == "__main__":
    unittest.main()
