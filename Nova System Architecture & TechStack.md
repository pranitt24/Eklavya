# Nova: System Architecture & Tech Stack Details

## 1. System Overview
Nova is a dynamic, LLM-driven educational game for primary students. The application dynamically generates levels based on a student's real-time skill mastery, weaving educational questions into interactive, generative storylines. The architecture shifts from an offline-first static JSON model to an online, server-authoritative model with a Cloud-based Bayesian Knowledge Tracing (BKT) engine.

## 2. Tech Stack

### Frontend (Mobile Application)
* **Framework:** Flutter (Dart)
* **State Management:** Provider or Riverpod (for managing dynamic scene states and BKT syncing queues)
* **Core Packages:**
  * `speech_to_text`: For voice input question mechanics.
  * `just_audio` / `audioplayers`: For background music (BGM) and sound effects (SFX).
  * Standard Flutter `Draggable` / `DragTarget` for drag-and-drop mechanics.
  * Standard Flutter `Stack` / `Positioned` for layered dynamic scene rendering.

### Backend (Server & API Gateway)
* **Framework:** Python (FastAPI) or Node.js (Express)
  * *(Recommendation: Python/FastAPI is highly recommended here to easily run the statistical BKT engine, manage database routing, and seamlessly integrate LLM SDKs).*
* **AI/LLM:** Gemini API (Utilizing "Structured Outputs" / JSON response mode for deterministic story and asset generation).

### Database & Storage
* **Relational Database:** PostgreSQL (Stores User Profiles, BKT Mastery States, and the Master Question/Asset Pool).
* **Object Storage / BaaS:** Firebase (Used for User Authentication, and Cloud Storage for hosting dynamic image/audio assets if they aren't pre-bundled in the app).

---

## 3. Core System Components

### A. The "Game Master" Pipeline (LLM + DB)
1. **BKT State Evaluator:** Analyzes the student's current mastery probabilities.
2. **Context Assembler:** Queries PostgreSQL for:
   * Target Learning Outcome (e.g., Single-Digit Addition).
   * A pool of 20 validated questions.
   * An active "Asset Palette" (available backdrops, Indian context props, characters).
3. **LLM Generator:** Takes the context and outputs a strictly typed JSON structure containing a 10-step story narrative, assigned assets, and selected questions.

### B. Dynamic Asset Compositor (Frontend UI)
Instead of static screens, the Flutter UI utilizes a Factory Pattern. 
* It parses the LLM JSON payload.
* Maps the `environment` keys to a `Stack` widget.
* Maps the `question_type` (e.g., `voice_input`, `match_following`, `spot_item`) to the respective interactive widget component.

### C. Cloud BKT Engine (Backend Logic)
Tracks latent probability of mastery $P(L_t)$. When a student submits a level, the backend recalculates their mastery based on Guess $P(G)$, Slip $P(S)$, and Learn $P(T)$ rates, which determines the difficulty and topic of the next dynamically generated level.

---

## 4. High-Level Data Flow Pipeline

### Level Generation Flow
1. **Client:** Requests "Start Next Level" via REST API.
2. **Backend API:** Calculates current BKT gaps -> queries PostgreSQL for 20 relevant questions.
3. **Backend API:** Sends System Prompt + Questions + Asset Manifest to Gemini API.
4. **Gemini API:** Returns generated JSON story (10 selected questions + asset bindings).
5. **Backend API:** Validates the JSON schema and sends it to the Client.
6. **Client (Flutter):** Pre-caches necessary image/audio assets, renders Scene 1 via the UI Stack.

### Gameplay & Assessment Flow
1. **Client:** User interacts with a question (Voice, Drag, Tap).
2. **Client:** Evaluates answer locally against the JSON `correct_answer`.
3. **Client:** Triggers local feedback (SFX, character expression change to `_happy` or `_encouraging`, local hint display).
4. **Client:** Queues result (Correct/Incorrect, Time Taken, Attempts).
5. **Client:** Upon level completion, POSTs the entire action queue to the Backend API.
6. **Backend API:** Updates the user's BKT state in PostgreSQL and returns the updated Level/Currency stats.

---

## 5. Primary JSON Schema Contract (Backend -> Client)

```json
{
  "level_id": "lvl_98234",
  "level_title": "The Mystery of the Banyan Grove",
  "theme": "indian_forest_adventure",
  "scenes": [
    {
      "scene_id": 1,
      "narrative_text": "Tiger cub needs help counting the fallen mangoes!",
      "environment": {
        "backdrop": "bg_banyan_grove",
        "character": "char_tiger",
        "character_expression_default": "idle",
        "prop": "prop_mango"
      },
      "question_data": {
        "question_type": "voice_input",
        "original_question_id": "Q_COUNT_05",
        "story_question_text": "How many mangoes are on the ground? Say the number out loud!",
        "options": null,
        "correct_answer": "5",
        "explanation_hint": "Count them one by one starting from the left."
      }
    }
  ]
}