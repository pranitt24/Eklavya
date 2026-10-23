# Nova App-Shell Consolidation Plan

Generated 2026-10-23 for task T0.5 against branch `docs/consolidation-plan` (base `chore/phase0-align`).
References: [`docs/DECISIONS.md`](DECISIONS.md), [`docs/HANDOVER.md`](HANDOVER.md) (sections 0-3 and T0.5).

---

## 1. Entry Points and Screen Reachability

### Which Entry Point Runs
- **Actual Runtime Entry**: [`lib/main.dart`](../lib/main.dart) (`MajheGaonApp`).
- **Verification**: Android manifest [`android/app/src/main/AndroidManifest.xml`](../android/app/src/main/AndroidManifest.xml) launches `.MainActivity` ([`android/app/src/main/kotlin/com/example/majhe_gaon/MainActivity.kt`](../android/app/src/main/kotlin/com/example/majhe_gaon/MainActivity.kt)), extending standard `FlutterActivity` which compiles and boots `lib/main.dart`.
- **Secondary Entry**: [`lib/nova_main/main.dart`](../lib/nova_main/main.dart) (`NovaApp`) is completely unreferenced by the Flutter runner and native hosts.

### Reachability Matrix

| Screen | File Path | Reachable from `lib/main.dart`? | Reachable from `NovaApp` routes? |
|---|---|---|---|
| **BootRouter** | [`lib/main.dart`](../lib/main.dart) | **YES** (Initial `home:`) | No |
| **ProfileScreen** | [`lib/features/screens/profile_screen.dart`](../lib/features/screens/profile_screen.dart) | **YES** (from BootRouter or HomeHub bottom nav/avatar) | Yes (`/profile`) |
| **HomeHubScreen** | [`lib/features/screens/home_hub_screen.dart`](../lib/features/screens/home_hub_screen.dart) | **YES** (from BootRouter or Profile save) | Yes (`/home`) |
| **ClassSelectionScreen** | [`lib/features/screens/class_selection_screen.dart`](../lib/features/screens/class_selection_screen.dart) | **YES** (from HomeHub "सुरू करा ->") | Yes (`/class-selection`) |
| **LevelRoadScreen** | [`lib/features/screens/level_road_screen.dart`](../lib/features/screens/level_road_screen.dart) | **YES** (from ClassSelection or HomeHub nav tab 1) | Yes (`/level-road`) |
| **StoryAdventureScreen** | [`lib/features/screens/story_adventure_screen.dart`](../lib/features/screens/story_adventure_screen.dart) | **YES** (from LevelRoad level launch) | Yes (`/story`) |
| **DuelLobbyScreen** | [`lib/features/duel/duel_lobby_screen.dart`](../lib/features/duel/duel_lobby_screen.dart) | **YES** (from HomeHub "दंगल सुरू करा 🥊") | No |
| **DuelArenaScreen** | [`lib/features/duel/duel_arena_screen.dart`](../lib/features/duel/duel_arena_screen.dart) | **YES** (from DuelLobby on connection) | No |
| **DuelResultScreen** | [`lib/features/duel/duel_result_screen.dart`](../lib/features/duel/duel_result_screen.dart) | **YES** (from DuelArena on game end) | No |
| **AccessibilitySettingsScreen** | [`lib/nova_main/screens/accessibility/accessibility_settings_screen.dart`](../lib/nova_main/screens/accessibility/accessibility_settings_screen.dart) | **YES** (from HomeHub top-bar accessibility button) | Yes (`/accessibility-settings`) |
| **ScreenOffSimulationScreen** | [`lib/nova_main/screens/accessibility/screen_off_simulation_screen.dart`](../lib/nova_main/screens/accessibility/screen_off_simulation_screen.dart) | **RUNTIME CRASH** (invoked via `pushNamed` from AccessibilitySettings) | Yes (`/screen-off-simulation`) |
| **SplashScreen** | [`lib/nova_main/screens/onboarding/splash_screen.dart`](../lib/nova_main/screens/onboarding/splash_screen.dart) | **NO** (Unreachable) | Yes (`/splash`) |
| **WelcomeScreen** | [`lib/nova_main/screens/onboarding/welcome_screen.dart`](../lib/nova_main/screens/onboarding/welcome_screen.dart) | **NO** (Unreachable) | Yes (`/welcome`) |
| **StudentSetupScreen** | [`lib/nova_main/screens/onboarding/student_setup_screen.dart`](../lib/nova_main/screens/onboarding/student_setup_screen.dart) | **NO** (Unreachable) | Yes (`/student-setup`) |
| **AssessmentIntroScreen** | [`lib/nova_main/screens/assessment/assessment_intro_screen.dart`](../lib/nova_main/screens/assessment/assessment_intro_screen.dart) | **NO** (Unreachable) | Yes (`/assessment-intro`) |
| **AssessmentQuestionScreen** | [`lib/nova_main/screens/assessment/assessment_question_screen.dart`](../lib/nova_main/screens/assessment/assessment_question_screen.dart) | **NO** (Unreachable) | Yes (`/assessment-question`) |
| **AssessmentResultScreen** | [`lib/nova_main/screens/assessment/assessment_result_screen.dart`](../lib/nova_main/screens/assessment/assessment_result_screen.dart) | **NO** (Unreachable) | Yes (`/assessment-result`) |
| **LevelRecommendationScreen** | [`lib/nova_main/screens/assessment/level_recommendation_screen.dart`](../lib/nova_main/screens/assessment/level_recommendation_screen.dart) | **NO** (Unreachable) | Yes (`/level-recommendation`) |
| **LevelDetailScreen** | [`lib/nova_main/screens/levels/level_detail_screen.dart`](../lib/nova_main/screens/levels/level_detail_screen.dart) | **NO** (Unreachable) | Yes (`/level-detail`) |
| **LevelCompleteScreen** | [`lib/nova_main/screens/levels/level_complete_screen.dart`](../lib/nova_main/screens/levels/level_complete_screen.dart) | **NO** (Unreachable) | Yes (`/level-complete`) |
| **AdventureMapScreen** | [`lib/nova_main/screens/home/adventure_map_screen.dart`](../lib/nova_main/screens/home/adventure_map_screen.dart) | **NO** (Unreachable) | No (Unused inside NovaApp) |
| **HomeShell** | [`lib/nova_main/screens/home/home_shell.dart`](../lib/nova_main/screens/home/home_shell.dart) | **NO** (Unreachable) | No (Unused inside NovaApp) |
| **ProfileJourneyScreen** | [`lib/nova_main/screens/progress/profile_journey_screen.dart`](../lib/nova_main/screens/progress/profile_journey_screen.dart) | **NO** (Unreachable) | No |
| **ProgressScreen** | [`lib/nova_main/screens/progress/progress_screen.dart`](../lib/nova_main/screens/progress/progress_screen.dart) | **NO** (Unreachable) | No |
| **StoryScreen** | [`lib/nova_main/screens/story/story_screen.dart`](../lib/nova_main/screens/story/story_screen.dart) | **NO** (Unreachable) | No |

> [!WARNING]
> [`lib/main.dart`](../lib/main.dart) does not configure named routes. Tapping `tryScreenOffBtn` in [`AccessibilitySettingsScreen`](../lib/nova_main/screens/accessibility/accessibility_settings_screen.dart) calls `Navigator.pushNamed(context, AppRoutes.screenOffSimulation)` which throws an unhandled route exception at runtime.

---

## 2. Inventory and Classification of `lib/nova_main/` (71 files)

| File Path | Purpose | Imported By | Imports Core / Features | Core/Features Equivalent | Verdict | Risk | Rationale |
|---|---|---|---|---|:---:|:---:|---|
| `app.dart` | Root NovaApp shell & routes | `main.dart` | `NovaTheme`, 5 `features/screens` | `lib/main.dart` | **DELETE** | Low | Dead entry shell. Route map to be consolidated. |
| `main.dart` | NovaApp entry point | None | None | `lib/main.dart` | **DELETE** | Low | Redundant `main()` entry. |
| `constants/app_strings.dart` | Text & audio prompt strings | 18 files | None | None | **KEEP -> `core/constants/`** | Low | Clean constants needed by accessibility and UI. |
| `data/assessment_data.dart` | 8 hardcoded assessment Qs | `assessment_question_screen` | None | None | **KEEP -> `features/placement/`** | Low | Temporary data until Phase 3 placement bank. |
| `data/badges_data.dart` | Static badge definitions | `app_state` | None | `nova_seed_catalog.dart` | **DELETE** | Low | Gamification catalog replaces hardcoded badges. |
| `data/curriculum_data.dart` | Static Class 1-6 curriculum | `app_state` | None | `nova_seed_catalog.dart` | **DELETE** | Med | Conflicts with DECISIONS.md (retire per-class trees). |
| `data/feedback_messages.dart` | Emotion feedback strings | `adaptive_engine`, `assessment_question` | None | `nova_seed_catalog.dart` | **DELETE** | Low | Outdated emojis; superseded by sound/contract. |
| `demo/demo_controls.dart` | Evaluator sheet & testing controls | 6 active screens | `bkt_game_master`, `llm_game_master`, `nova_schema_repo`, `story_adventure` | None | **KEEP -> `features/demo/`** | Med | Critical for evaluation; fix `pushNamed` calls. |
| `demo/demo_fab.dart` | Floating Action Button for demo sheet | 11 screens | None | None | **KEEP -> `features/demo/`** | Low | UI trigger for `demo_controls.dart`. |
| `models/accessibility_settings.dart` | Accessibility state data class | `welcome_screen`, `app_state` | None | None | **KEEP -> `core/models/`** | Low | Pure data model. |
| `models/answer_option.dart` | Question option structure | 8 files | None | `NovaQuestionOption` | **DELETE** | Low | Replaced by `NovaSchemaModels`. |
| `models/assessment_question.dart` | Diagnostic question model | 4 files | None | `NovaQuestionRecord` | **KEEP -> `features/placement/`** | Low | Scaffold for placement until Phase 1 schema v2. |
| `models/badge.dart` | Badge model | 7 files | None | `NovaGameAsset` | **DELETE** | Low | Redundant with schema asset models. |
| `models/class_course.dart` | Class-level container | `curriculum_data`, `app_state` | None | None | **DELETE** | Low | Conflicts with "no class-wise split". |
| `models/emotion_state.dart` | Emotion state enum | 6 files | None | `MascotMood` | **DELETE** | Low | Merged into `MascotMood`. |
| `models/level_model.dart` | Static level descriptor | 6 files | None | `GeneratedLevelContract` | **DELETE** | Low | Contract v2 replaces static level model. |
| `models/question_model.dart` | Static question structure | 6 files | None | `NovaQuestionRecord` | **DELETE** | Low | Redundant with schema models. |
| `models/skill_result.dart` | Diagnostic result container | None (0 callers) | None | None | **DELETE** | Low | Dead code. |
| `models/story_beat.dart` | MascotMood & StoryBeat model | 21 files (incl. core widgets) | None | None | **KEEP -> `core/models/`** | Med | `MascotMood` heavily used by core mascot widgets. |
| `models/student.dart` | Profile state container | `app_state` | None | Drift `StudentProfiles` / `NovaUser` | **DELETE** | Low | Redundant with database models. |
| `routes/app_routes.dart` | Route name constants | 13 files | None | None | **KEEP -> `core/routing/`** | Low | Keep route constants for navigation dispatching. |
| `routes/route_transitions.dart` | Custom page route animations | `app.dart` | None | None | **KEEP -> `core/routing/`** | Low | Clean transitions supporting `reduceMotion`. |
| `screens/accessibility/accessibility_settings_screen.dart` | Full accessibility settings | `home_hub_screen`, `app.dart` | None | None | **KEEP -> `features/accessibility/`** | Med | Linked from HomeHub; must decouple from `AppColors`. |
| `screens/accessibility/screen_off_simulation_screen.dart` | Screen-off audio simulator | `app.dart`, `accessibility_settings` | None | None | **KEEP -> `features/accessibility/`** | Low | Specialized accessibility demo screen. |
| `screens/assessment/assessment_intro_screen.dart` | Placement intro screen | `app.dart` | None | None | **KEEP -> `features/placement/`** | Low | Reusable for Task T3.1 placement flow. |
| `screens/assessment/assessment_question_screen.dart` | 8-question placement screen | `app.dart` | None | None | **KEEP -> `features/placement/`** | Med | Scaffold for Task T3.1 adaptive placement test. |
| `screens/assessment/assessment_result_screen.dart` | Placement summary screen | `app.dart` | None | None | **KEEP -> `features/placement/`** | Low | Reusable result screen for T3.1. |
| `screens/assessment/level_recommendation_screen.dart` | Starting level recommendation | `app.dart` | None | None | **KEEP -> `features/placement/`** | Low | Placement assignment screen. |
| `screens/home/adventure_map_screen.dart` | Old vertical level road | `home_shell` | None | `features/screens/level_road_screen.dart` | **DELETE** | Low | Redundant with `LevelRoadScreen`. |
| `screens/home/home_shell.dart` | 3-tab navigation shell | None (0 callers) | None | `features/screens/home_hub_screen.dart` | **DELETE** | Low | Dead scaffold; never displayed. |
| `screens/levels/level_detail_screen.dart` | Level preview dialog | `app.dart`, `adventure_map` | `features/.../std1_level1_story` | Handled inside `LevelRoadScreen` | **DELETE** | Low | Redundant level preview. |
| `screens/levels/level_complete_screen.dart` | Level completion reward screen | `app.dart` | None | Screen 11 in `StoryAdventureScreen` | **DELETE** | Low | Celebration is now inline in story scenes. |
| `screens/onboarding/splash_screen.dart` | Mascot splash screen | `app.dart` | None | `BootRouter` in `lib/main.dart` | **DELETE** | Low | Handled by Riverpod boot router. |
| `screens/onboarding/student_setup_screen.dart` | Onboarding profile setup | `app.dart` | None | `features/screens/profile_screen.dart` | **DELETE** | Low | Redundant profile creation screen. |
| `screens/onboarding/welcome_screen.dart` | Initial welcome screen | `onboarding_screen`, `app.dart` | `features/.../class_selection`, `duel_lobby` | `features/screens/profile_screen.dart` | **DELETE** | Low | Redundant welcome screen. |
| `screens/progress/profile_journey_screen.dart` | Progress overview screen | `home_shell` | None | `ProfileScreen` | **DELETE** | Low | Unused dead screen. |
| `screens/progress/progress_screen.dart` | Skill mastery screen | `home_shell` | None | None | **DELETE** | Low | Unused dead screen. |
| `screens/story/story_screen.dart` | Old 11-step story screen | `level_detail` | None | `features/screens/story_adventure_screen.dart` | **DELETE** | Low | Superseded by 4,360-line `StoryAdventureScreen`. |
| `services/adaptive_engine.dart` | Rule-based emotion engine | `story_adventure`, `app_state` | None | `core/services/bkt_game_master_engine.dart` | **DELETE** | Med | Duplicate engine; DECISIONS requires BKT only. |
| `services/app_state.dart` | Global state ChangeNotifier | 25 files across repo | None | Riverpod providers + Drift DB | **MIGRATE -> RETIRE** | High | Most coupled file; holds state across active screens. |
| `services/assessment_service.dart` | Placement scoring algorithm | `demo_controls`, `assessment_question`, `app_state` | None | None | **KEEP -> `features/placement/`** | Low | Temporary placement logic until BKT placement. |
| `services/haptics_service.dart` | Haptic feedback wrapper | 22 files | None | None | **KEEP -> `core/services/`** | Low | Clean standalone utility. |
| `services/voice_service.dart` | Old voice recorder | `story_screen`, `voice_button` | None | `core/services/nova_audio_service.dart` | **DELETE** | Low | Redundant with `NovaAudioService`. |
| `theme/app_colors.dart` | Color palette | 43 files | None | `core/design_system/nova_colors.dart` | **MERGE -> DELETE** | Med | Merge `hcBackground`/`hcText` into `NovaColors`. |
| `theme/app_spacing.dart` | Spacing & shadows | 34 files | `app_colors` | `core/design_system/nova_spacing.dart` | **MERGE -> DELETE** | Low | Merge missing constants into `NovaSpacing`. |
| `theme/app_text_styles.dart` | Typography | 34 files | `app_colors`, `app_spacing` | `core/design_system/nova_typography.dart` | **MERGE -> DELETE** | Low | Merge styles into `NovaTypography`. |
| `theme/app_theme.dart` | ThemeData builders | `app.dart` | `app_colors`, `app_spacing`, `app_text_styles` | `core/design_system/nova_theme.dart` | **MERGE -> DELETE** | Low | Merge `highContrastTheme` into `NovaTheme`. |
| `widgets/accessibility_toggle.dart` | Accessibility switch widget | `accessibility_settings` | None | None | **KEEP -> `features/accessibility/`** | Low | Clean accessibility component. |
| `widgets/adaptive_difficulty_stars.dart`| Star indicator | `story_screen` | None | None | **DELETE** | Low | Redundant widget. |
| `widgets/adventure_progress_indicator.dart`| Re-export stub (2 lines) | `assessment_question`, `story_screen` | None | None | **DELETE** | Low | Empty export stub. |
| `widgets/answer_option_widget.dart` | Interactive quiz option | `assessment_question`, `story_screen` | None | `NovaQuestionOption` widgets | **KEEP -> `features/placement/`** | Low | Keep with placement until Phase 3. |
| `widgets/badge_tile.dart` | Badge grid item | `progress_screen` | None | None | **DELETE** | Low | Unused screen widget. |
| `widgets/class_card.dart` | Class 1-6 selector card | `student_setup_screen` | None | None | **DELETE** | Low | Class selection to be retired. |
| `widgets/confetti_overlay.dart` | Confetti celebratory particle | `std1_level1_story`, 2 assessment | None | None | **KEEP -> `core/widgets/`** | Low | Reusable animation component. |
| `widgets/emotion_feedback_card.dart` | Emotion feedback card | `story_screen` | None | `NovaQuizFeedbackCard` | **DELETE** | Low | Redundant widget. |
| `widgets/fraction_visual.dart` | Pizza/fraction painter | `assessment_question`, `answer_option` | None | None | **KEEP -> `core/widgets/`** | Low | Valuable geometry/fraction painter. |
| `widgets/gesture_legend.dart` | Re-export stub (2 lines) | `screen_off_simulation` | None | None | **DELETE** | Low | Empty export stub. |
| `widgets/hint_card.dart` | Hint display card | `story_screen` | None | `StoryAdventureScreen` inline hints | **DELETE** | Low | Redundant widget. |
| `widgets/level_card.dart` | Level card widget | `level_recommendation` | None | None | **DELETE** | Low | Redundant widget. |
| `widgets/level_node.dart` | Map node circle | `adventure_map` | None | `LevelRoadScreen` painters | **DELETE** | Low | Redundant with `LevelRoadScreen`. |
| `widgets/mascot_widget.dart` | Animated vector mascot | 17 files across core/nova_main | None | `NovaRobotMascot` | **KEEP -> `core/widgets/`** | High | Critical shared visual component. |
| `widgets/offline_badge.dart` | "Offline Ready" pill | `splash`, `welcome`, `adventure_map` | None | None | **DELETE** | Low | Outdated static pill. |
| `widgets/primary_button.dart` | 3D beveled button | 13 files | None | `core/widgets/nova/nova_button.dart` | **DELETE** | Low | Replaced by `NovaButton`. |
| `widgets/progress_ring.dart` | Re-export stub (2 lines) | `progress_screen` | None | None | **DELETE** | Low | Empty export stub. |
| `widgets/secondary_button.dart` | Secondary button | 5 files | None | `NovaButton(variant: secondary)` | **DELETE** | Low | Replaced by `NovaButton`. |
| `widgets/shape_visual.dart` | Geometric shapes painter | `assessment_question`, `answer_option` | None | None | **KEEP -> `core/widgets/`** | Low | Valuable math shape painter. |
| `widgets/skill_bar.dart` | Re-export stub (2 lines) | `assessment_result` | None | None | **DELETE** | Low | Empty export stub. |
| `widgets/speech_bubble.dart` | Comic speech bubble | 4 screens | None | None | **KEEP -> `core/widgets/`** | Low | Reusable speech bubble with typewriter. |
| `widgets/star_reward.dart` | Star reward animation | `level_complete` | None | Inline celebration | **DELETE** | Low | Redundant with `StoryAdventureScreen`. |
| `widgets/story_card.dart` | Story dialog card | `story_screen` | None | Inline story views | **DELETE** | Low | Redundant widget. |
| `widgets/voice_button.dart` | Audio mic button | `story_screen` | None | `NovaSpeakerButton` | **DELETE** | Low | Redundant widget. |

---

## 3. Reverse Dependencies (core & features -> nova_main)

Files in `lib/core` and `lib/features` importing from `lib/nova_main`:

1. [`lib/main.dart`](../lib/main.dart):
   - Imports: `nova_main/services/app_state.dart`
   - Symbols: `AppState`, `AppStateScope` (wraps entire app tree).
2. [`lib/core/widgets/nova/nova_pause_modal.dart`](../lib/core/widgets/nova/nova_pause_modal.dart):
   - Imports: `nova_main/widgets/mascot_widget.dart`, `nova_main/models/story_beat.dart`
   - Symbols: `MascotWidget`, `MascotMood`.
3. [`lib/core/widgets/nova/nova_quiz_feedback_card.dart`](../lib/core/widgets/nova/nova_quiz_feedback_card.dart):
   - Imports: `nova_main/widgets/mascot_widget.dart`, `nova_main/models/story_beat.dart`
   - Symbols: `MascotWidget`, `MascotMood`.
4. [`lib/core/widgets/nova/nova_vector_character.dart`](../lib/core/widgets/nova/nova_vector_character.dart):
   - Imports: `nova_main/widgets/mascot_widget.dart`, `nova_main/models/story_beat.dart`
   - Symbols: `MascotMood`.
5. [`lib/features/screens/home_hub_screen.dart`](../lib/features/screens/home_hub_screen.dart):
   - Imports: `nova_main/demo/demo_controls.dart`, `nova_main/screens/accessibility/accessibility_settings_screen.dart`, `nova_main/services/app_state.dart`
   - Symbols: `AppStateScope`, `AppState`, `AccessibilitySettingsScreen`, `DemoControlsSheet`.
6. [`lib/features/screens/profile_screen.dart`](../lib/features/screens/profile_screen.dart):
   - Imports: `nova_main/demo/demo_controls.dart`, `nova_main/services/app_state.dart`
   - Symbols: `AppStateScope`, `AppState.setStudentName()`.
7. [`lib/features/screens/class_selection_screen.dart`](../lib/features/screens/class_selection_screen.dart):
   - Imports: `nova_main/demo/demo_controls.dart`, `nova_main/services/app_state.dart`
   - Symbols: `AppStateScope`, `AppState.setClassNumber()`.
8. [`lib/features/screens/level_road_screen.dart`](../lib/features/screens/level_road_screen.dart):
   - Imports: `nova_main/demo/demo_controls.dart`, `nova_main/services/app_state.dart`
   - Symbols: `AppStateScope`, `AppState.student`.
9. [`lib/features/screens/story_adventure_screen.dart`](../lib/features/screens/story_adventure_screen.dart):
   - Imports: `nova_main/demo/demo_controls.dart`, `nova_main/services/app_state.dart`, `nova_main/services/adaptive_engine.dart`
   - Symbols: `AppStateScope`, `AppState.completeLevel()`, `AdaptiveEngine`.
10. **Dead code cluster in `lib/features/`**:
    - [`lib/features/curriculum/presentation/class_selection_screen.dart`](../lib/features/curriculum/presentation/class_selection_screen.dart) (imports `app_state`, `app_colors`, `app_spacing`, `app_text_styles`, `adventure_map_screen`). Unused.
    - [`lib/features/curriculum/presentation/std1_level1_story_screen.dart`](../lib/features/curriculum/presentation/std1_level1_story_screen.dart) (imports `mascot_widget`, `confetti_overlay`, `app_state`, `story_beat`). Only imported by dead `level_detail_screen.dart`.
    - [`lib/features/curriculum/presentation/level_play_screen.dart`](../lib/features/curriculum/presentation/level_play_screen.dart) and [`village_dashboard_screen.dart`](../lib/features/curriculum/presentation/village_dashboard_screen.dart). Unused.
    - [`lib/features/onboarding/presentation/onboarding_screen.dart`](../lib/features/onboarding/presentation/onboarding_screen.dart) (imports `welcome_screen`). Unused.

---

## 4. Class Selection Dependencies

Per [`docs/DECISIONS.md`](DECISIONS.md) section "Product": **"No class-wise structure. A placement test at registration assigns the starting level."**

### Components Bound to Class Selection
- **Screens**:
  - [`lib/features/screens/class_selection_screen.dart`](../lib/features/screens/class_selection_screen.dart): 2x2 grid selecting Class 1 to 4; launched from HomeHub "सुरू करा ->".
  - [`lib/nova_main/screens/onboarding/student_setup_screen.dart`](../lib/nova_main/screens/onboarding/student_setup_screen.dart): 6-card class selector.
  - [`lib/features/curriculum/presentation/class_selection_screen.dart`](../lib/features/curriculum/presentation/class_selection_screen.dart): 3-column dead screen.
- **Routes**:
  - `AppRoutes.classSelection` in [`lib/nova_main/routes/app_routes.dart`](../lib/nova_main/routes/app_routes.dart).
- **Database & Drift Fields**:
  - `StudentProfiles.enrolledStandard` in [`lib/core/db/database.dart`](../lib/core/db/database.dart#L15).
  - `StudentProfiles.activeStandard` in [`lib/core/db/database.dart`](../lib/core/db/database.dart#L16).
- **Models**:
  - `Student.classNumber` in [`lib/nova_main/models/student.dart`](../lib/nova_main/models/student.dart).
  - `ClassCourse.classNumber` in [`lib/nova_main/models/class_course.dart`](../lib/nova_main/models/class_course.dart).
  - `AssessmentQuestion.targetClass` in [`lib/nova_main/models/assessment_question.dart`](../lib/nova_main/models/assessment_question.dart).
- **Services & Data**:
  - `AppState.setClassNumber(int num)` in [`lib/nova_main/services/app_state.dart`](../lib/nova_main/services/app_state.dart#L80).
  - `CurriculumData._courses` map keyed by class 1-6 in [`lib/nova_main/data/curriculum_data.dart`](../lib/nova_main/data/curriculum_data.dart).

> [!NOTE]
> When the adaptive placement test (Task T3.1) lands, `ClassSelectionScreen` will be replaced by the placement onboarding route. Database fields `enrolledStandard`/`activeStandard` will migrate to placement starting level and skill mastery records in Schema v2 (Task T1.2).

---

## 5. Legacy Per-Level Code to Retire Later (List Only)

Per project guidelines, the following hardcoded per-level artifacts are flagged to be retired in Phase 3 (Task T3.3 / T3.6):

1. **Per-Level Custom Painter Stage Widgets**:
   - [`lib/core/widgets/nova/banyan_grove_stage_widget.dart`](../lib/core/widgets/nova/banyan_grove_stage_widget.dart) (421 lines) — Hardcoded painter for Levels 1 & 2.
   - [`lib/core/widgets/nova/village_market_stage_widget.dart`](../lib/core/widgets/nova/village_market_stage_widget.dart) (517 lines) — Hardcoded painter for Level 3.
   - [`lib/core/widgets/nova/village_school_fair_stage_widget.dart`](../lib/core/widgets/nova/village_school_fair_stage_widget.dart) (829 lines) — Hardcoded painter for Level 4.
2. **Hardcoded Ternary Chains in LLM Service**:
   - [`lib/core/services/llm_game_master_service.dart`](../lib/core/services/llm_game_master_service.dart#L258-L350): 14 `levelNum ==` nested conditional blocks overriding titles, themes, backdrops, characters, questions, and hints.
3. **Hardcoded Static Curriculum Banks**:
   - [`lib/nova_main/data/curriculum_data.dart`](../lib/nova_main/data/curriculum_data.dart) (479 lines): Static class-level mock questions.
   - Hardcoded Level 1-4 question blocks inside [`lib/core/data/nova_seed_catalog.dart`](../lib/core/data/nova_seed_catalog.dart).

---

## 6. Proposed Ordered Migration Plan

Each step is independent, leaving the app compiling and passing `flutter analyze` with 0 issues.

```
Step 1: Foundational Utilities (Haptics, Strings, Colors)
   │
   ▼
Step 2: Shared Mascot & Visual Components (MascotMood, MascotWidget, Confetti)
   │
   ▼
Step 3: Relocate Accessibility Feature (Settings & Screen-Off Sim)
   │
   ▼
Step 4: Relocate Demo Tools & Fix Navigation Jumps (DemoFab, DemoControls)
   │
   ▼
Step 5: Decouple Survivor Screens from AppState (Riverpod Providers)
   │
   ▼
Step 6: Purge Dead Code & Delete lib/nova_main/
```

### Step 1: Foundational Utilities & Theme Extraction
- **What Moves**:
  - Move `haptics_service.dart` to `lib/core/services/haptics_service.dart`.
  - Move `app_strings.dart` to `lib/core/constants/app_strings.dart`.
  - Copy high-contrast color tokens from `app_colors.dart` into [`lib/core/design_system/nova_colors.dart`](../lib/core/design_system/nova_colors.dart).
  - Move `accessibility_settings.dart` to `lib/core/models/accessibility_settings.dart`.
- **Deletions**: None yet.
- **Verification**: `flutter analyze` passes with 0 issues.

### Step 2: Relocate Shared Mascot & Visual Widgets
- **What Moves**:
  - Extract `MascotMood` and move `mascot_widget.dart` to [`lib/core/widgets/nova/mascot_widget.dart`](../lib/core/widgets/nova/).
  - Move `confetti_overlay.dart`, `speech_bubble.dart`, `fraction_visual.dart`, `shape_visual.dart` to `lib/core/widgets/`.
  - Update imports in [`nova_pause_modal.dart`](../lib/core/widgets/nova/nova_pause_modal.dart), [`nova_quiz_feedback_card.dart`](../lib/core/widgets/nova/nova_quiz_feedback_card.dart), [`nova_vector_character.dart`](../lib/core/widgets/nova/nova_vector_character.dart).
- **Deletions**: `lib/nova_main/models/story_beat.dart`.
- **Verification**: `flutter analyze` passes with 0 issues.

### Step 3: Relocate Accessibility Screens & Fix Named Route
- **What Moves**:
  - Move `accessibility_settings_screen.dart` and `screen_off_simulation_screen.dart` to `lib/features/accessibility/presentation/`.
  - Move `accessibility_toggle.dart` to `lib/features/accessibility/widgets/`.
  - Replace `Navigator.pushNamed(context, AppRoutes.screenOffSimulation)` in `accessibility_settings_screen.dart` with `MaterialPageRoute(builder: (_) => const ScreenOffSimulationScreen())`.
  - Update import in [`lib/features/screens/home_hub_screen.dart`](../lib/features/screens/home_hub_screen.dart).
- **Verification**: Run `flutter analyze`. Tapping the accessibility icon in HomeHub opens settings without crashing.

### Step 4: Relocate Demo Controls & Stabilize Evaluator Navigation
- **What Moves**:
  - Move `demo_controls.dart` and `demo_fab.dart` to `lib/features/demo/`.
  - Replace broken `pushNamed` calls in `demo_controls.dart` (Welcome, Assessment, Screen-Off Sim) with explicit `MaterialPageRoute` builders.
  - Update imports in the 5 active screens under `lib/features/screens/`.
- **Verification**: `flutter analyze` passes with 0 issues.

### Step 5: Decouple Survivor Screens from AppState
- **What Changes**:
  - Introduce `accessibilityProvider` (StateNotifier/Notifier holding `AccessibilitySettings`).
  - Wire student name in `ProfileScreen` and `HomeHubScreen` exclusively to Drift's `activeStudentProvider`.
  - In [`lib/features/screens/story_adventure_screen.dart`](../lib/features/screens/story_adventure_screen.dart), replace `AdaptiveEngine` emotion tracking with `BktGameMasterEngine`.
  - Remove `AppStateScope` wrapper from [`lib/main.dart`](../lib/main.dart).
- **Verification**: `flutter analyze` passes with 0 issues. App builds and runs from `lib/main.dart` without `AppState`.

### Step 6: Scaffold Placement & Purge `lib/nova_main/`
- **What Moves**:
  - Move `assessment_intro_screen.dart`, `assessment_question_screen.dart`, `assessment_result_screen.dart`, `level_recommendation_screen.dart`, `assessment_service.dart`, and `assessment_data.dart` to `lib/features/placement/` as initial scaffold for Task T3.1.
- **What is Deleted**:
  - Delete `lib/features/curriculum/` (all 4 dead screen files).
  - Delete `lib/features/onboarding/presentation/onboarding_screen.dart`.
  - Delete remaining files in `lib/nova_main/`: `main.dart`, `app.dart`, `services/app_state.dart`, `theme/`, old onboarding/home/levels screens, and unused widgets.
  - Delete directory `lib/nova_main/`.
- **Verification**: `flutter analyze` passes with 0 issues. Run `flutter test`.

---

## 7. Risks and Unknowns

1. **Named Route Breakage**: `lib/main.dart` uses widget-based navigation (`home:` + `MaterialPageRoute`). Any residual `pushNamed` in moved code throws runtime exceptions. All navigation must be converted to `MaterialPageRoute` or `GoRouter` in Phase 3.
2. **AppState Hidden Side-Effects**: `AppState` triggers `FlutterTts` calls and sound effects on level starts. Decoupling requires verifying that audio does not fall silent.
3. **SQLite Native Asset Download on Windows**: As verified during Phase 0, `package:sqlite3` hook failed during `flutter test` on Windows due to dynamic certificate TLS handshakes. Tests must be executed with pre-cached DLLs or on Linux/CI.
4. **Hardware-Dependent Features**: Marathi speech synthesis (`mr-IN`) and recognition require physical device validation (Task T5.1); Android simulator lacks Marathi TTS voice packs.
