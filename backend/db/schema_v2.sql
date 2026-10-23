-- Nova schema v2. SQLite first; types/constraints kept Postgres-compatible (TEXT ids, no AUTOINCREMENT).
-- JSON columns are TEXT in SQLite (use JSONB when moving to Postgres).
PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS skills (
  skill_id      TEXT PRIMARY KEY,
  subject       TEXT NOT NULL DEFAULT 'math',
  grade         INTEGER NOT NULL CHECK (grade BETWEEN 1 AND 7),
  level_band    INTEGER NOT NULL,                 -- global teaching order
  name_en       TEXT NOT NULL,
  name_mr       TEXT NOT NULL,
  question_type TEXT NOT NULL CHECK (question_type IN ('voice_input','match_following','spot_item','fill_blanks'))
);
CREATE TABLE IF NOT EXISTS skill_prerequisites (
  skill_id        TEXT NOT NULL REFERENCES skills(skill_id),
  prerequisite_id TEXT NOT NULL REFERENCES skills(skill_id),
  PRIMARY KEY (skill_id, prerequisite_id)
);
CREATE TABLE IF NOT EXISTS skill_tiers (            -- difficulty defined by parameters, not LLM judgment
  skill_id TEXT NOT NULL REFERENCES skills(skill_id),
  tier     INTEGER NOT NULL CHECK (tier BETWEEN 1 AND 3),
  params   TEXT NOT NULL,                          -- JSON
  PRIMARY KEY (skill_id, tier)
);

CREATE TABLE IF NOT EXISTS questions (
  question_id   TEXT PRIMARY KEY,
  skill_id      TEXT NOT NULL REFERENCES skills(skill_id),
  difficulty_tier INTEGER NOT NULL CHECK (difficulty_tier BETWEEN 1 AND 3),
  question_type TEXT NOT NULL CHECK (question_type IN ('voice_input','match_following','spot_item','fill_blanks')),
  language      TEXT NOT NULL CHECK (language IN ('mr','en','both')),
  payload       TEXT NOT NULL,                     -- JSON: question object from the contract
  source        TEXT NOT NULL CHECK (source IN ('template','llm','seed')),
  status        TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft','verified','rejected')),
  created_at    TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_questions_lookup ON questions(skill_id, difficulty_tier, status);

CREATE TABLE IF NOT EXISTS levels (
  level_id        TEXT PRIMARY KEY,
  skill_id        TEXT NOT NULL REFERENCES skills(skill_id),
  grade           INTEGER NOT NULL,
  difficulty_tier INTEGER NOT NULL CHECK (difficulty_tier BETWEEN 1 AND 3),
  theme           TEXT NOT NULL,
  language        TEXT NOT NULL CHECK (language IN ('mr','en','both')),
  contract_json   TEXT NOT NULL,                   -- full validated level v2 JSON
  validation_status TEXT NOT NULL DEFAULT 'pending' CHECK (validation_status IN ('pending','valid','rejected')),
  validation_errors TEXT,                          -- JSON list from validator
  source          TEXT NOT NULL CHECK (source IN ('seed','llm')),
  created_at      TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS level_skills (           -- a level may cover a skill group
  level_id TEXT NOT NULL REFERENCES levels(level_id),
  skill_id TEXT NOT NULL REFERENCES skills(skill_id),
  PRIMARY KEY (level_id, skill_id)
);
CREATE TABLE IF NOT EXISTS level_questions (
  level_id    TEXT NOT NULL REFERENCES levels(level_id),
  question_id TEXT NOT NULL REFERENCES questions(question_id),
  position    INTEGER NOT NULL,
  PRIMARY KEY (level_id, question_id)
);
-- cache key: stories are reusable, keyed by (skill, tier, theme, language), never by student
CREATE TABLE IF NOT EXISTS generated_level_cache (
  skill_id TEXT NOT NULL REFERENCES skills(skill_id),
  tier     INTEGER NOT NULL,
  theme    TEXT NOT NULL,
  language TEXT NOT NULL,
  level_id TEXT NOT NULL REFERENCES levels(level_id),
  hits     INTEGER NOT NULL DEFAULT 0,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (skill_id, tier, theme, language, level_id)
);

CREATE TABLE IF NOT EXISTS users (                  -- no real names (children): nickname + device only
  user_id   TEXT PRIMARY KEY,
  nickname  TEXT NOT NULL,
  avatar    TEXT,
  language  TEXT NOT NULL DEFAULT 'mr' CHECK (language IN ('mr','en')),
  device_id TEXT NOT NULL UNIQUE,
  start_level_band INTEGER,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS user_skill_mastery (     -- per-user BKT state
  user_id  TEXT NOT NULL REFERENCES users(user_id),
  skill_id TEXT NOT NULL REFERENCES skills(skill_id),
  p_known  REAL NOT NULL CHECK (p_known BETWEEN 0 AND 1),
  attempts INTEGER NOT NULL DEFAULT 0,
  correct  INTEGER NOT NULL DEFAULT 0,
  updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id, skill_id)
);
CREATE TABLE IF NOT EXISTS placement_results (
  placement_id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL REFERENCES users(user_id),
  taken_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  questions_asked INTEGER NOT NULL,
  start_level_band INTEGER NOT NULL,
  mastery_json TEXT NOT NULL                       -- {skill_id: p_known}
);
CREATE TABLE IF NOT EXISTS gameplay_logs (          -- queued on device, synced later
  log_id      TEXT PRIMARY KEY,                    -- client-generated, makes sync idempotent
  user_id     TEXT NOT NULL REFERENCES users(user_id),
  level_id    TEXT,
  question_id TEXT,
  skill_id    TEXT REFERENCES skills(skill_id),
  correct     INTEGER NOT NULL CHECK (correct IN (0,1)),
  response_ms INTEGER,
  answered_at TEXT NOT NULL,
  synced_at   TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_logs_user ON gameplay_logs(user_id, answered_at);
CREATE TABLE IF NOT EXISTS question_stats (         -- feeds the quality loop (T2.5)
  question_id TEXT PRIMARY KEY REFERENCES questions(question_id),
  attempts INTEGER NOT NULL DEFAULT 0,
  correct  INTEGER NOT NULL DEFAULT 0,
  flagged  INTEGER NOT NULL DEFAULT 0
);
