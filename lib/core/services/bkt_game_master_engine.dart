import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/nova_schema_models.dart';
import '../data/nova_seed_catalog.dart';
import 'nova_schema_repository.dart';

/// ============================================================================
/// RIVERPOD PROVIDERS
/// ============================================================================

/// Provider for BktMasteryEvaluator.
final bktMasteryEvaluatorProvider = Provider<BktMasteryEvaluator>((ref) {
  final repository = ref.watch(novaSchemaRepositoryProvider);
  return BktMasteryEvaluator(repository: repository);
});

/// Provider for GameMasterContextAssembler.
final gameMasterContextAssemblerProvider =
    Provider<GameMasterContextAssembler>((ref) {
  final repository = ref.watch(novaSchemaRepositoryProvider);
  return GameMasterContextAssembler(repository: repository);
});

/// ============================================================================
/// 1. BKT MASTERY EVALUATOR
/// ============================================================================

/// Evaluates student mastery probabilities using Bayesian Knowledge Tracing (BKT).
/// Implements exact Bayesian belief update equations with guessing and slipping
/// parameters, followed by state transition towards latent skill mastery.
class BktMasteryEvaluator {
  final NovaSchemaRepository repository;
  final List<GameplayLogRecord> _processedLogs = [];

  BktMasteryEvaluator({required this.repository});

  List<GameplayLogRecord> get processedLogs => List.unmodifiable(_processedLogs);

  /// Computes the BKT posterior observation probability P(L | obs):
  ///
  /// If isCorrect == true:
  ///   pPosterior = (pLearned * (1 - pSlip)) / ((pLearned * (1 - pSlip)) + ((1 - pLearned) * pGuess))
  /// If isCorrect == false:
  ///   pPosterior = (pLearned * pSlip) / ((pLearned * pSlip) + ((1 - pLearned) * (1 - pGuess)))
  static double computePosterior({
    required double pLearned,
    required double pGuess,
    required double pSlip,
    required bool isCorrect,
  }) {
    final double prior = pLearned.clamp(0.001, 0.999);
    if (isCorrect) {
      final double numerator = prior * (1.0 - pSlip);
      final double denominator = numerator + ((1.0 - prior) * pGuess);
      return denominator > 0 ? (numerator / denominator) : prior;
    } else {
      final double numerator = prior * pSlip;
      final double denominator = numerator + ((1.0 - prior) * (1.0 - pGuess));
      return denominator > 0 ? (numerator / denominator) : prior;
    }
  }

  /// Computes the BKT transition to the learned state:
  /// pLearnedNext = (pPosterior + ((1 - pPosterior) * pTransit)).clamp(0.01, 0.99)
  static double computeTransition({
    required double pPosterior,
    required double pTransit,
  }) {
    return (pPosterior + ((1.0 - pPosterior) * pTransit)).clamp(0.01, 0.99);
  }

  /// Combined BKT update formula returning the new pLearned:
  static double updatePLearned({
    required double pLearned,
    required double pGuess,
    required double pSlip,
    required double pTransit,
    required bool isCorrect,
  }) {
    final double posterior = computePosterior(
      pLearned: pLearned,
      pGuess: pGuess,
      pSlip: pSlip,
      isCorrect: isCorrect,
    );
    return computeTransition(
      pPosterior: posterior,
      pTransit: pTransit,
    );
  }

  /// Processes completed level logs:
  /// 1. Saves telemetry logs.
  /// 2. Updates UserBktState for each skill using exact BKT parameters.
  /// 3. Awards +25 coinsBalance to NovaUser.
  /// 4. Unlocks Level 2 when Level 1 finishes.
  void processCompletedLevelLogs(List<GameplayLogRecord> logs) {
    _processedLogs.addAll(logs);
    bool hasLevel1Questions = false;

    for (final log in logs) {
      // Find candidate question to resolve skillId and levelId
      QuestionCandidate? question;
      try {
        question = NovaSeedCatalog.questionCandidates.firstWhere(
          (q) => q.questionId == log.questionId,
        );
      } catch (_) {
        question = null;
      }

      final String skillId = question?.skillId ?? 'MATH_COMPARE_01';
      final int levelId = (question?.payloadData['level_id'] as int?) ?? 1;
      if (levelId == 1) {
        hasLevel1Questions = true;
      }

      // Update UserBktState via repository observation
      repository.recordObservation(skillId, isCorrect: log.isCorrect);
    }

    // Awards +25 coinsBalance to NovaUser
    repository.addCoins(25);

    // Unlocks Level 2 when Level 1 finishes
    if (repository.currentUser.currentLevel <= 1 || hasLevel1Questions) {
      repository.setCurrentLevel(2);
    }
  }

  /// Evaluates a single answered question immediately and returns the new difficulty tier.
  /// 1. Immediately updates pLearned in UserBktState via repository.recordObservation.
  /// 2. Returns the new difficultyTier:
  ///    - Tier 1 if pLearned < 0.40
  ///    - Tier 2 if 0.40 <= pLearned < 0.72
  ///    - Tier 3 if pLearned >= 0.72
  int evaluateSingleAnswerAndGetNextTier({
    required String skillId,
    required bool isCorrectFirstTry,
  }) {
    repository.recordObservation(skillId, isCorrect: isCorrectFirstTry);
    final double updatedP = repository.getBktState(skillId).pLearned;
    if (updatedP < 0.40) {
      return 1;
    } else if (updatedP < 0.72) {
      return 2;
    } else {
      return 3;
    }
  }
}

/// ============================================================================
/// 2. GAME MASTER CONTEXT ASSEMBLER
/// ============================================================================

/// Assembles user mastery, question candidates, and visual assets into a
/// comprehensive context package ready for LLM story generation.
class GameMasterContextAssembler {
  final NovaSchemaRepository repository;

  GameMasterContextAssembler({required this.repository});

  /// Dynamic Difficulty Adjustment (DDA) mapping:
  /// pLearned < 0.40          -> Tier 1 (Easy / Concrete)
  /// 0.40 <= pLearned < 0.72  -> Tier 2 (Medium / Guided)
  /// pLearned >= 0.72         -> Tier 3 (Hard / Autonomous)
  static int selectDifficultyTier(double pLearned) {
    if (pLearned < 0.40) {
      return 1;
    } else if (pLearned < 0.72) {
      return 2;
    } else {
      return 3;
    }
  }

  /// Assembles the complete prompt context for the LLM Game Master for a level.
  GameMasterPromptContext assembleContext({int levelNumber = 1}) {
    final NovaUser user = repository.currentUser;

    // 1. Pull candidate questions for the requested level
    // levelNumber == 1 -> Village Morning pool (Q_VILL_01..08)
    // levelNumber == 2 -> Banyan Grove & Dairy pool (Q_GROVE_01..08)
    final List<QuestionCandidate> levelQuestions =
        NovaSeedCatalog.getQuestionsByLevel(levelNumber);

    // 2. Read user's UserBktState from repository
    final Map<String, double> skillMasteryMap = {};
    final Set<String> relevantSkillIds = levelQuestions.map((q) => q.skillId).toSet();
    double totalP = 0.0;
    int count = 0;

    for (final skillId in relevantSkillIds) {
      final state = repository.getBktState(skillId);
      skillMasteryMap[skillId] = state.pLearned;
      totalP += state.pLearned;
      count++;
    }

    // Fallback if no specific skills discovered
    if (count == 0) {
      final allStates = repository.getAllBktStates();
      for (final entry in allStates.entries) {
        skillMasteryMap[entry.key] = entry.value.pLearned;
        totalP += entry.value.pLearned;
        count++;
      }
    }

    // Average pLearned for Dynamic Difficulty Adjustment
    final double avgPLearned = count > 0 ? (totalP / count) : 0.1000;
    final int targetTier = selectDifficultyTier(avgPLearned);

    // Filter questions by target difficulty tier
    final List<QuestionCandidate> tierQuestions = levelQuestions
        .where((q) => q.difficultyTier == targetTier)
        .toList();

    // Ensure adequate candidate questions; fallback to all level questions if pool is small
    final List<QuestionCandidate> candidateQuestions =
        tierQuestions.length >= 3 ? tierQuestions : levelQuestions;

    // Randomly shuffle candidate questions in the user's tier on every new story start
    candidateQuestions.shuffle(math.Random());

    // 3. Pull unlocked assets
    final List<String> unlockedIds = repository.unlockedAssetIds;
    final List<GameAssetRecord> availableAssets = NovaSeedCatalog.gameAssets
        .where((asset) => unlockedIds.contains(asset.assetId) || asset.unlockCost == 0)
        .toList();

    // 4. Level theme & title
    final String theme = levelNumber == 1 ? 'village_morning' : 'banyan_grove_dairy';
    final String levelTitle = levelNumber == 1
        ? 'पातळी १ • माझी सकाळ (Village Morning)'
        : 'पातळी २ • वडाचे झाड आणि डेअरी (Banyan Grove & Dairy)';

    // 5. Build structured system prompt for LLM Game Master
    final String prompt = _buildSystemPrompt(
      user: user,
      levelNumber: levelNumber,
      levelTitle: levelTitle,
      theme: theme,
      targetTier: targetTier,
      avgPLearned: avgPLearned,
      skills: skillMasteryMap,
      questions: candidateQuestions,
      assets: availableAssets,
    );

    return GameMasterPromptContext(
      user: user,
      levelNumber: levelNumber,
      levelTitle: levelTitle,
      theme: theme,
      targetDifficultyTier: targetTier,
      averagePLearned: avgPLearned,
      skillMastery: skillMasteryMap,
      candidateQuestions: candidateQuestions,
      availableAssets: availableAssets,
      systemPrompt: prompt,
    );
  }

  String _buildSystemPrompt({
    required NovaUser user,
    required int levelNumber,
    required String levelTitle,
    required String theme,
    required int targetTier,
    required double avgPLearned,
    required Map<String, double> skills,
    required List<QuestionCandidate> questions,
    required List<GameAssetRecord> assets,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('# ROLE: NOVA AI GAME MASTER (PRIMARY EDUCATION - GRADES 1-2)');
    buffer.writeln('You are the AI Game Master generating an interactive Marathi learning story level for student "${user.username}".');
    buffer.writeln();
    buffer.writeln('## STUDENT CONTEXT:');
    buffer.writeln('- Student Name: ${user.username}');
    buffer.writeln('- Current Level: ${user.currentLevel}');
    buffer.writeln('- Coins Balance: ${user.coinsBalance}');
    buffer.writeln('- Target Difficulty Tier: Tier $targetTier (Average Mastery: ${(avgPLearned * 100).toStringAsFixed(1)}%)');
    buffer.writeln('- Skills Mastery:');
    skills.forEach((k, v) {
      buffer.writeln('  * $k: ${(v * 100).toStringAsFixed(1)}%');
    });
    buffer.writeln();
    buffer.writeln('## LEVEL SPECIFICATIONS:');
    buffer.writeln('- Level: $levelNumber ($levelTitle)');
    buffer.writeln('- Theme: $theme');
    buffer.writeln();
    buffer.writeln('## CANDIDATE QUESTIONS POOL (Select & Embed into story scenes):');
    for (final q in questions) {
      buffer.writeln('- [${q.questionId}] (${q.questionType}, Tier ${q.difficultyTier}): ${q.coreLogicText}');
    }
    buffer.writeln();
    buffer.writeln('## AVAILABLE ASSETS (Use strictly approved IDs):');
    for (final a in assets) {
      buffer.writeln('- ${a.assetId} (${a.assetType}, tags: ${a.tags.join(", ")})');
    }
    buffer.writeln();
    buffer.writeln('## OUTPUT CONTRACT REQUIREMENT:');
    buffer.writeln('You MUST output a single valid JSON object strictly adhering to the `GeneratedLevelContract` schema.');
    buffer.writeln('Root keys: "level_id", "level_title", "theme", "scenes".');
    buffer.writeln('Each scene in "scenes" must contain: "scene_id", "narrative_text", "environment", "question_data".');
    return buffer.toString();
  }
}

/// ============================================================================
/// 3. GAME MASTER PROMPT CONTEXT
/// ============================================================================

/// Encapsulates the assembled prompt context for sending to the Gemini LLM service.
class GameMasterPromptContext {
  final NovaUser user;
  final int levelNumber;
  final String levelTitle;
  final String theme;
  final int targetDifficultyTier;
  final double averagePLearned;
  final Map<String, double> skillMastery;
  final List<QuestionCandidate> candidateQuestions;
  final List<GameAssetRecord> availableAssets;
  final String systemPrompt;

  GameMasterPromptContext({
    required this.user,
    required this.levelNumber,
    required this.levelTitle,
    required this.theme,
    required this.targetDifficultyTier,
    required this.averagePLearned,
    required this.skillMastery,
    required this.candidateQuestions,
    required this.availableAssets,
    required this.systemPrompt,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': user.userId,
      'username': user.username,
      'level_number': levelNumber,
      'level_title': levelTitle,
      'theme': theme,
      'target_difficulty_tier': targetDifficultyTier,
      'average_p_learned': averagePLearned,
      'skill_mastery': skillMastery,
      'candidate_questions_count': candidateQuestions.length,
      'candidate_questions': candidateQuestions.map((q) => q.toJson()).toList(),
      'available_assets_count': availableAssets.length,
      'available_assets': availableAssets.map((a) => a.toJson()).toList(),
      'system_prompt': systemPrompt,
    };
  }

  String toRawJson() => json.encode(toJson());

  @override
  String toString() =>
      'GameMasterPromptContext(level: $levelNumber, tier: $targetDifficultyTier, questions: ${candidateQuestions.length}, assets: ${availableAssets.length})';
}
