# Nova: content pipeline rules

## Principle
The LLM writes text and picks named options. It never draws, never outputs pixel coordinates, and never invents new asset names or question types. Code decides what is taught and checks that the output is correct.

## Who decides what
- **Code decides:** skill, difficulty tier, language, theme, which characters, number of scenes, and the answer to every math question.
- **LLM decides:** story wording and which catalogue items and moods fit each scene.

## Questions
- Math questions come from parameterized templates. Code picks the numbers and computes the correct answer, so it is right by construction. Distractors come from real mistakes (for example a forgotten carry).
- Language questions may be LLM-drafted, but must pass an independent check and a native Marathi speaker's review before they enter the verified bank.
- Question types are fixed: `voice_input`, `match_following`, `spot_item`, `fill_blanks`. Each has a strict payload schema.
- Difficulty tiers are defined by parameters (number range, carry, number of steps), not by LLM judgment.
- Every question carries a skill ID.

## Stories
- Follow a fixed arc: hook, problem, question, reaction, repeat, celebration. One beat and one question slot per scene.
- Enforce word limits per grade and simple language, in code, after generation.
- Generate Marathi and English natively. Do not translate one into the other.
- Stories are reusable across students, keyed by (skill, tier, theme, language).

## Validation (required)
Every generated level must pass the validator before it is stored or shown:
- matches the JSON schema;
- every asset, expression and motion name exists in the catalogue;
- at most 3 actors per scene;
- prop counts agree with the question's answer;
- the correct answer is among the options;
- both language fields are non-empty.

On failure, retry up to a fixed limit, then fall back to a verified bank level. Never show unvalidated output to a student.

## Weak internet
Prefetch the next two levels, cache them, keep at least one bundled fallback level, and queue gameplay logs for later sync.
