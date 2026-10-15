# Nova: Database Schema (PostgreSQL)

This schema is designed to separate the static curriculum logic (Skills & Questions) from the dynamic user progression (BKT State & Logs). It utilizes `JSONB` columns for flexible data structures required by different interactive question types.

---

## 1. Core User & Progression Tables

### `users`
Stores player profiles, overall gamification state, and currency.
* `user_id` (UUID, Primary Key)
* `username` (VARCHAR)
* `current_level` (INT, Default: 1) - Represents the purely gamified level number.
* `coins_balance` (INT, Default: 0) - In-game currency for unlocking assets.
* `created_at` (TIMESTAMP)
* `updated_at` (TIMESTAMP)

### `user_bkt_state`
The core of the adaptive engine. Tracks the probability of mastery $P(L_t)$ for every skill a student has encountered.
* `user_id` (UUID, Foreign Key -> `users.user_id`)
* `skill_id` (VARCHAR, Foreign Key -> `skills.skill_id`)
* `p_learned` (DECIMAL 5,4, Default: 0.1000) - Current probability the student has mastered this skill (ranges from 0.0 to 1.0).
* `updated_at` (TIMESTAMP)
* **Primary Key:** Composite (`user_id`, `skill_id`)

---

## 2. Curriculum & Question Pool Tables

### `skills` (Learning Outcomes)
Maps to specific, granular concepts (e.g., `ADD_1_DIGIT_CARRY`, `ID_SHAPE_TRIANGLE`).
* `skill_id` (VARCHAR, Primary Key) - e.g., 'MATH_ADD_01'
* `skill_name` (VARCHAR) - e.g., 'Single Digit Addition'
* `subject` (VARCHAR) - e.g., 'Math', 'Language'
* `p_guess` (DECIMAL 5,4) - Probability a student guesses correctly without knowing the skill (Default: ~0.2).
* `p_slip` (DECIMAL 5,4) - Probability a student makes a mistake despite knowing the skill (Default: ~0.1).
* `p_transit` (DECIMAL 5,4) - Probability the student learns the skill after one practice opportunity.

### `questions`
The validated candidate pool of questions pulled by the backend and sent to the LLM.
* `question_id` (VARCHAR, Primary Key)
* `skill_id` (VARCHAR, Foreign Key -> `skills.skill_id`)
* `difficulty_tier` (INT) - 1 (Easy), 2 (Medium), 3 (Hard). Used for Dynamic Difficulty Adjustment (DDA).
* `question_type` (VARCHAR) - Enum: `voice_input`, `match_following`, `spot_item`, `fill_blanks`.
* `core_logic_text` (TEXT) - The pure educational intent (e.g., "Find the sum of 4 and 3"). The LLM reskins this into the story.
* `payload_data` (JSONB) - Holds the exact answers and distractors based on type.
  * *Example (Match):* `{"pairs": [{"a": "4", "b": "****"}, {"a": "2", "b": "**"}]}`
  * *Example (Voice):* `{"correct_answer": "7"}`

---

## 3. Game Assets & LLM Context Tables

### `assets`
The catalog of approved artwork and audio the LLM is allowed to assign to scenes. 
* `asset_id` (VARCHAR, Primary Key) - e.g., 'bg_banyan_grove', 'char_tiger'
* `asset_type` (VARCHAR) - Enum: `backdrop`, `character`, `prop`, `audio`
* `tags` (JSONB) - Array of string tags (e.g., `["indian", "forest", "nature"]`). The backend uses these tags to filter a thematic "Palette" before sending it to the LLM prompt.
* `unlock_cost` (INT, Default: 0) - If > 0, the asset must be purchased by the user in the store before the LLM can use it in their stories.

### `user_unlocked_assets`
Tracks which premium/purchased assets a user has added to their collection.
* `user_id` (UUID, Foreign Key -> `users.user_id`)
* `asset_id` (VARCHAR, Foreign Key -> `assets.asset_id`)
* `unlocked_at` (TIMESTAMP)
* **Primary Key:** Composite (`user_id`, `asset_id`)

---

## 4. Telemetry & Analytics Table

### `gameplay_logs`
The queue of actions synced from the Flutter frontend. This data is used to update the `user_bkt_state` and track engagement.
* `log_id` (UUID, Primary Key)
* `user_id` (UUID, Foreign Key -> `users.user_id`)
* `question_id` (VARCHAR, Foreign Key -> `questions.question_id`)
* `is_correct` (BOOLEAN) - Did they get it right on the first try? (Crucial for BKT update).
* `attempts` (INT) - Total tries before succeeding.
* `time_taken_sec` (INT)
* `timestamp` (TIMESTAMP)