import 'dart:convert';

/// ============================================================================
/// 1. DATABASE ENTITIES (Nova Database Schema)
/// ============================================================================

/// Represents a student profile, progression state, and currency.
class NovaUser {
  final String userId;
  final String username;
  final int currentLevel;
  final int coinsBalance;
  final DateTime createdAt;
  final DateTime updatedAt;

  NovaUser({
    required this.userId,
    required this.username,
    this.currentLevel = 1,
    this.coinsBalance = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory NovaUser.fromJson(Map<String, dynamic> json) {
    return NovaUser(
      userId: json['user_id'] ?? json['userId'] ?? '',
      username: json['username'] ?? '',
      currentLevel: json['current_level'] ?? json['currentLevel'] ?? 1,
      coinsBalance: json['coins_balance'] ?? json['coinsBalance'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : (json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
              : DateTime.now()),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now()
          : (json['updatedAt'] != null
              ? DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now()
              : DateTime.now()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'username': username,
      'current_level': currentLevel,
      'coins_balance': coinsBalance,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  NovaUser copyWith({
    String? userId,
    String? username,
    int? currentLevel,
    int? coinsBalance,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NovaUser(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      currentLevel: currentLevel ?? this.currentLevel,
      coinsBalance: coinsBalance ?? this.coinsBalance,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() =>
      'NovaUser(userId: $userId, username: $username, level: $currentLevel, coins: $coinsBalance)';
}

/// Tracks latent probability of mastery P(L_t) for a student per skill (BKT Engine).
class UserBktState {
  final String userId;
  final String skillId;
  final double pLearned;
  final DateTime updatedAt;

  UserBktState({
    required this.userId,
    required this.skillId,
    this.pLearned = 0.1000,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  factory UserBktState.fromJson(Map<String, dynamic> json) {
    return UserBktState(
      userId: json['user_id'] ?? json['userId'] ?? '',
      skillId: json['skill_id'] ?? json['skillId'] ?? '',
      pLearned: (json['p_learned'] ?? json['pLearned'] ?? 0.1000).toDouble(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now()
          : (json['updatedAt'] != null
              ? DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now()
              : DateTime.now()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'skill_id': skillId,
      'p_learned': pLearned,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  UserBktState copyWith({
    String? userId,
    String? skillId,
    double? pLearned,
    DateTime? updatedAt,
  }) {
    return UserBktState(
      userId: userId ?? this.userId,
      skillId: skillId ?? this.skillId,
      pLearned: pLearned ?? this.pLearned,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() =>
      'UserBktState(userId: $userId, skillId: $skillId, pLearned: ${pLearned.toStringAsFixed(4)})';
}

/// Master record for a curriculum skill / learning outcome.
class SkillRecord {
  final String skillId;
  final String skillName;
  final String subject;
  final double pGuess;
  final double pSlip;
  final double pTransit;

  SkillRecord({
    required this.skillId,
    required this.skillName,
    required this.subject,
    this.pGuess = 0.2,
    this.pSlip = 0.1,
    this.pTransit = 0.15,
  });

  factory SkillRecord.fromJson(Map<String, dynamic> json) {
    return SkillRecord(
      skillId: json['skill_id'] ?? json['skillId'] ?? '',
      skillName: json['skill_name'] ?? json['skillName'] ?? '',
      subject: json['subject'] ?? '',
      pGuess: (json['p_guess'] ?? json['pGuess'] ?? 0.2).toDouble(),
      pSlip: (json['p_slip'] ?? json['pSlip'] ?? 0.1).toDouble(),
      pTransit: (json['p_transit'] ?? json['pTransit'] ?? 0.15).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'skill_id': skillId,
      'skill_name': skillName,
      'subject': subject,
      'p_guess': pGuess,
      'p_slip': pSlip,
      'p_transit': pTransit,
    };
  }

  SkillRecord copyWith({
    String? skillId,
    String? skillName,
    String? subject,
    double? pGuess,
    double? pSlip,
    double? pTransit,
  }) {
    return SkillRecord(
      skillId: skillId ?? this.skillId,
      skillName: skillName ?? this.skillName,
      subject: subject ?? this.subject,
      pGuess: pGuess ?? this.pGuess,
      pSlip: pSlip ?? this.pSlip,
      pTransit: pTransit ?? this.pTransit,
    );
  }

  @override
  String toString() => 'SkillRecord(skillId: $skillId, name: $skillName, subject: $subject)';
}

/// Candidate questions pulled by the backend and fed to the LLM Game Master.
class QuestionCandidate {
  final String questionId;
  final String skillId;
  final int difficultyTier; // 1 (Easy), 2 (Medium), 3 (Hard)
  final String questionType; // voice_input, match_following, spot_item, fill_blanks
  final String coreLogicText;
  final Map<String, dynamic> payloadData;
  final String requiredBackdropId;
  final String requiredCharacterLottie;
  final String requiredPropLottie;
  final String storyBridgeIntro;
  final String ttsMarathiText;

  QuestionCandidate({
    required this.questionId,
    required this.skillId,
    required this.difficultyTier,
    required this.questionType,
    required this.coreLogicText,
    required this.payloadData,
    this.requiredBackdropId = 'bg_village_morning',
    this.requiredCharacterLottie = 'assets/lottie/Hand Waving Animation.json',
    this.requiredPropLottie = '',
    this.storyBridgeIntro = '',
    this.ttsMarathiText = '',
  });

  factory QuestionCandidate.fromJson(Map<String, dynamic> json) {
    return QuestionCandidate(
      questionId: json['question_id'] ?? json['questionId'] ?? '',
      skillId: json['skill_id'] ?? json['skillId'] ?? '',
      difficultyTier: json['difficulty_tier'] ?? json['difficultyTier'] ?? 1,
      questionType: json['question_type'] ?? json['questionType'] ?? 'spot_item',
      coreLogicText: json['core_logic_text'] ?? json['coreLogicText'] ?? '',
      payloadData: json['payload_data'] != null
          ? Map<String, dynamic>.from(json['payload_data'])
          : (json['payloadData'] != null
              ? Map<String, dynamic>.from(json['payloadData'])
              : {}),
      requiredBackdropId: json['required_backdrop_id'] ??
          json['requiredBackdropId'] ??
          'bg_village_morning',
      requiredCharacterLottie: json['required_character_lottie'] ??
          json['requiredCharacterLottie'] ??
          'assets/lottie/Hand Waving Animation.json',
      requiredPropLottie: json['required_prop_lottie'] ??
          json['requiredPropLottie'] ??
          '',
      storyBridgeIntro: json['story_bridge_intro'] ??
          json['storyBridgeIntro'] ??
          '',
      ttsMarathiText: json['tts_marathi_text'] ??
          json['ttsMarathiText'] ??
          '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question_id': questionId,
      'skill_id': skillId,
      'difficulty_tier': difficultyTier,
      'question_type': questionType,
      'core_logic_text': coreLogicText,
      'payload_data': payloadData,
      'required_backdrop_id': requiredBackdropId,
      'required_character_lottie': requiredCharacterLottie,
      'required_prop_lottie': requiredPropLottie,
      'story_bridge_intro': storyBridgeIntro,
      'tts_marathi_text': ttsMarathiText,
    };
  }

  QuestionCandidate copyWith({
    String? questionId,
    String? skillId,
    int? difficultyTier,
    String? questionType,
    String? coreLogicText,
    Map<String, dynamic>? payloadData,
    String? requiredBackdropId,
    String? requiredCharacterLottie,
    String? requiredPropLottie,
    String? storyBridgeIntro,
    String? ttsMarathiText,
  }) {
    return QuestionCandidate(
      questionId: questionId ?? this.questionId,
      skillId: skillId ?? this.skillId,
      difficultyTier: difficultyTier ?? this.difficultyTier,
      questionType: questionType ?? this.questionType,
      coreLogicText: coreLogicText ?? this.coreLogicText,
      payloadData: payloadData ?? this.payloadData,
      requiredBackdropId: requiredBackdropId ?? this.requiredBackdropId,
      requiredCharacterLottie:
          requiredCharacterLottie ?? this.requiredCharacterLottie,
      requiredPropLottie: requiredPropLottie ?? this.requiredPropLottie,
      storyBridgeIntro: storyBridgeIntro ?? this.storyBridgeIntro,
      ttsMarathiText: ttsMarathiText ?? this.ttsMarathiText,
    );
  }

  @override
  String toString() =>
      'QuestionCandidate(id: $questionId, type: $questionType, tier: $difficultyTier)';
}

/// Catalog of approved artwork & audio assets available for scene composition.
class GameAssetRecord {
  final String assetId;
  final String assetType; // backdrop, character, prop, audio
  final List<String> tags;
  final int unlockCost;
  final String localAssetPath;

  GameAssetRecord({
    required this.assetId,
    required this.assetType,
    required this.tags,
    this.unlockCost = 0,
    required this.localAssetPath,
  });

  factory GameAssetRecord.fromJson(Map<String, dynamic> json) {
    return GameAssetRecord(
      assetId: json['asset_id'] ?? json['assetId'] ?? '',
      assetType: json['asset_type'] ?? json['assetType'] ?? 'prop',
      tags: json['tags'] != null
          ? List<String>.from(json['tags'])
          : <String>[],
      unlockCost: json['unlock_cost'] ?? json['unlockCost'] ?? 0,
      localAssetPath: json['local_asset_path'] ?? json['localAssetPath'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'asset_id': assetId,
      'asset_type': assetType,
      'tags': tags,
      'unlock_cost': unlockCost,
      'local_asset_path': localAssetPath,
    };
  }

  GameAssetRecord copyWith({
    String? assetId,
    String? assetType,
    List<String>? tags,
    int? unlockCost,
    String? localAssetPath,
  }) {
    return GameAssetRecord(
      assetId: assetId ?? this.assetId,
      assetType: assetType ?? this.assetType,
      tags: tags ?? this.tags,
      unlockCost: unlockCost ?? this.unlockCost,
      localAssetPath: localAssetPath ?? this.localAssetPath,
    );
  }

  @override
  String toString() =>
      'GameAssetRecord(id: $assetId, type: $assetType, cost: $unlockCost, path: $localAssetPath)';
}

/// Unlocked premium asset inventory per student.
class UserUnlockedAsset {
  final String userId;
  final String assetId;
  final DateTime unlockedAt;

  UserUnlockedAsset({
    required this.userId,
    required this.assetId,
    DateTime? unlockedAt,
  }) : unlockedAt = unlockedAt ?? DateTime.now();

  factory UserUnlockedAsset.fromJson(Map<String, dynamic> json) {
    return UserUnlockedAsset(
      userId: json['user_id'] ?? json['userId'] ?? '',
      assetId: json['asset_id'] ?? json['assetId'] ?? '',
      unlockedAt: json['unlocked_at'] != null
          ? DateTime.tryParse(json['unlocked_at'].toString()) ?? DateTime.now()
          : (json['unlockedAt'] != null
              ? DateTime.tryParse(json['unlockedAt'].toString()) ?? DateTime.now()
              : DateTime.now()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'asset_id': assetId,
      'unlocked_at': unlockedAt.toIso8601String(),
    };
  }

  @override
  String toString() => 'UserUnlockedAsset(userId: $userId, assetId: $assetId)';
}

/// Telemetry and action log synced from gameplay to update BKT state.
class GameplayLogRecord {
  final String logId;
  final String userId;
  final String questionId;
  final bool isCorrect;
  final int attempts;
  final int timeTakenSec;
  final DateTime timestamp;

  GameplayLogRecord({
    required this.logId,
    required this.userId,
    required this.questionId,
    required this.isCorrect,
    required this.attempts,
    required this.timeTakenSec,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory GameplayLogRecord.fromJson(Map<String, dynamic> json) {
    return GameplayLogRecord(
      logId: json['log_id'] ?? json['logId'] ?? '',
      userId: json['user_id'] ?? json['userId'] ?? '',
      questionId: json['question_id'] ?? json['questionId'] ?? '',
      isCorrect: json['is_correct'] ?? json['isCorrect'] ?? false,
      attempts: json['attempts'] ?? 1,
      timeTakenSec: json['time_taken_sec'] ?? json['timeTakenSec'] ?? 0,
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'log_id': logId,
      'user_id': userId,
      'question_id': questionId,
      'is_correct': isCorrect,
      'attempts': attempts,
      'time_taken_sec': timeTakenSec,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  String toString() =>
      'GameplayLogRecord(logId: $logId, qId: $questionId, correct: $isCorrect, attempts: $attempts)';
}

/// ============================================================================
/// 2. PRIMARY BACKEND -> CLIENT JSON SCHEMA CONTRACT
/// ============================================================================

/// Top-level contract for a dynamically generated story level from the LLM Game Master.
class GeneratedLevelContract {
  final String levelId;
  final String levelTitle;
  final String theme;
  final List<GeneratedSceneContract> scenes;

  GeneratedLevelContract({
    required this.levelId,
    required this.levelTitle,
    required this.theme,
    required this.scenes,
  });

  factory GeneratedLevelContract.fromJson(Map<String, dynamic> json) {
    return GeneratedLevelContract(
      levelId: json['level_id'] ?? json['levelId'] ?? '',
      levelTitle: json['level_title'] ?? json['levelTitle'] ?? '',
      theme: json['theme'] ?? '',
      scenes: json['scenes'] != null
          ? (json['scenes'] as List)
              .map((s) => GeneratedSceneContract.fromJson(Map<String, dynamic>.from(s)))
              .toList()
          : <GeneratedSceneContract>[],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'level_id': levelId,
      'level_title': levelTitle,
      'theme': theme,
      'scenes': scenes.map((s) => s.toJson()).toList(),
    };
  }

  GeneratedLevelContract copyWith({
    String? levelId,
    String? levelTitle,
    String? theme,
    List<GeneratedSceneContract>? scenes,
  }) {
    return GeneratedLevelContract(
      levelId: levelId ?? this.levelId,
      levelTitle: levelTitle ?? this.levelTitle,
      theme: theme ?? this.theme,
      scenes: scenes ?? this.scenes,
    );
  }

  String toRawJson() => json.encode(toJson());
  factory GeneratedLevelContract.fromRawJson(String str) =>
      GeneratedLevelContract.fromJson(json.decode(str));

  @override
  String toString() =>
      'GeneratedLevelContract(id: $levelId, title: $levelTitle, scenes: ${scenes.length})';
}

/// Individual step/scene within a generated level.
class GeneratedSceneContract {
  final int sceneId;
  final String narrativeText;
  final SceneEnvironmentContract environment;
  final SceneQuestionContract questionData;

  GeneratedSceneContract({
    required this.sceneId,
    required this.narrativeText,
    required this.environment,
    required this.questionData,
  });

  factory GeneratedSceneContract.fromJson(Map<String, dynamic> json) {
    return GeneratedSceneContract(
      sceneId: json['scene_id'] ?? json['sceneId'] ?? 0,
      narrativeText: json['narrative_text'] ?? json['narrativeText'] ?? '',
      environment: json['environment'] != null
          ? SceneEnvironmentContract.fromJson(Map<String, dynamic>.from(json['environment']))
          : SceneEnvironmentContract.defaultVillage(),
      questionData: json['question_data'] != null
          ? SceneQuestionContract.fromJson(Map<String, dynamic>.from(json['question_data']))
          : (json['questionData'] != null
              ? SceneQuestionContract.fromJson(Map<String, dynamic>.from(json['questionData']))
              : SceneQuestionContract.empty()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'scene_id': sceneId,
      'narrative_text': narrativeText,
      'environment': environment.toJson(),
      'question_data': questionData.toJson(),
    };
  }

  GeneratedSceneContract copyWith({
    int? sceneId,
    String? narrativeText,
    SceneEnvironmentContract? environment,
    SceneQuestionContract? questionData,
  }) {
    return GeneratedSceneContract(
      sceneId: sceneId ?? this.sceneId,
      narrativeText: narrativeText ?? this.narrativeText,
      environment: environment ?? this.environment,
      questionData: questionData ?? this.questionData,
    );
  }

  @override
  String toString() =>
      'GeneratedSceneContract(id: $sceneId, narrative: $narrativeText, question: ${questionData.questionType})';
}

/// Environment / visual binding of assets in the scene.
class SceneEnvironmentContract {
  final String backdrop;
  final String character;
  final String characterExpressionDefault;
  final String prop;

  SceneEnvironmentContract({
    required this.backdrop,
    required this.character,
    this.characterExpressionDefault = 'idle',
    required this.prop,
  });

  factory SceneEnvironmentContract.defaultVillage() {
    return SceneEnvironmentContract(
      backdrop: 'bg_village_morning',
      character: 'char_chintu',
      characterExpressionDefault: 'happy',
      prop: 'prop_bird',
    );
  }

  factory SceneEnvironmentContract.fromJson(Map<String, dynamic> json) {
    return SceneEnvironmentContract(
      backdrop: json['backdrop'] ?? 'bg_village_morning',
      character: json['character'] ?? 'char_chintu',
      characterExpressionDefault: json['character_expression_default'] ??
          json['characterExpressionDefault'] ??
          'idle',
      prop: json['prop'] ?? 'prop_bird',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'backdrop': backdrop,
      'character': character,
      'character_expression_default': characterExpressionDefault,
      'prop': prop,
    };
  }

  SceneEnvironmentContract copyWith({
    String? backdrop,
    String? character,
    String? characterExpressionDefault,
    String? prop,
  }) {
    return SceneEnvironmentContract(
      backdrop: backdrop ?? this.backdrop,
      character: character ?? this.character,
      characterExpressionDefault:
          characterExpressionDefault ?? this.characterExpressionDefault,
      prop: prop ?? this.prop,
    );
  }

  @override
  String toString() =>
      'SceneEnvironmentContract(backdrop: $backdrop, char: $character, prop: $prop)';
}

/// Educational question payload embedded within the scene narrative.
class SceneQuestionContract {
  final String questionType; // voice_input, match_following, spot_item, fill_blanks
  final String originalQuestionId;
  final String storyQuestionText;
  final List<String>? options;
  final String correctAnswer;
  final String? explanationHint;
  final Map<String, dynamic>? payloadData;
  final String? storyBridgeIntro;
  final String? ttsMarathiText;

  SceneQuestionContract({
    required this.questionType,
    required this.originalQuestionId,
    required this.storyQuestionText,
    this.options,
    required this.correctAnswer,
    this.explanationHint,
    this.payloadData,
    this.storyBridgeIntro,
    this.ttsMarathiText,
  });

  factory SceneQuestionContract.empty() {
    return SceneQuestionContract(
      questionType: 'spot_item',
      originalQuestionId: '',
      storyQuestionText: '',
      correctAnswer: '',
    );
  }

  factory SceneQuestionContract.fromJson(Map<String, dynamic> json) {
    return SceneQuestionContract(
      questionType: json['question_type'] ?? json['questionType'] ?? 'spot_item',
      originalQuestionId:
          json['original_question_id'] ?? json['originalQuestionId'] ?? '',
      storyQuestionText:
          json['story_question_text'] ?? json['storyQuestionText'] ?? '',
      options: json['options'] != null ? List<String>.from(json['options']) : null,
      correctAnswer: json['correct_answer'] ?? json['correctAnswer'] ?? '',
      explanationHint:
          json['explanation_hint'] ?? json['explanationHint'] as String?,
      payloadData: json['payload_data'] != null
          ? Map<String, dynamic>.from(json['payload_data'])
          : (json['payloadData'] != null
              ? Map<String, dynamic>.from(json['payloadData'])
              : null),
      storyBridgeIntro:
          json['story_bridge_intro'] ?? json['storyBridgeIntro'] as String?,
      ttsMarathiText:
          json['tts_marathi_text'] ?? json['ttsMarathiText'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question_type': questionType,
      'original_question_id': originalQuestionId,
      'story_question_text': storyQuestionText,
      if (options != null) 'options': options,
      'correct_answer': correctAnswer,
      if (explanationHint != null) 'explanation_hint': explanationHint,
      if (payloadData != null) 'payload_data': payloadData,
      if (storyBridgeIntro != null) 'story_bridge_intro': storyBridgeIntro,
      if (ttsMarathiText != null) 'tts_marathi_text': ttsMarathiText,
    };
  }

  SceneQuestionContract copyWith({
    String? questionType,
    String? originalQuestionId,
    String? storyQuestionText,
    List<String>? options,
    String? correctAnswer,
    String? explanationHint,
    Map<String, dynamic>? payloadData,
    String? storyBridgeIntro,
    String? ttsMarathiText,
  }) {
    return SceneQuestionContract(
      questionType: questionType ?? this.questionType,
      originalQuestionId: originalQuestionId ?? this.originalQuestionId,
      storyQuestionText: storyQuestionText ?? this.storyQuestionText,
      options: options ?? this.options,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      explanationHint: explanationHint ?? this.explanationHint,
      payloadData: payloadData ?? this.payloadData,
      storyBridgeIntro: storyBridgeIntro ?? this.storyBridgeIntro,
      ttsMarathiText: ttsMarathiText ?? this.ttsMarathiText,
    );
  }

  @override
  String toString() =>
      'SceneQuestionContract(type: $questionType, id: $originalQuestionId, answer: $correctAnswer)';
}
