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


if __name__ == "__main__":
    unittest.main()
