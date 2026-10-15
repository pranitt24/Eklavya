import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/local_api_keys.dart';
import '../models/nova_schema_models.dart';
import '../data/nova_seed_catalog.dart';
import 'bkt_game_master_engine.dart';

/// Available LLM backend providers for dynamic story level generation.
enum LlmBackendProvider {
  gemini25Flash,
  groqUltraFast,
  dynamicLocalOffline,
}

/// Riverpod provider exposing LlmGameMasterService.
final llmGameMasterProvider = Provider<LlmGameMasterService>((ref) {
  final assembler = ref.watch(gameMasterContextAssemblerProvider);
  return LlmGameMasterService(assembler: assembler);
});

/// Backwards-compatible alias for llmGameMasterProvider.
final llmGameMasterServiceProvider = llmGameMasterProvider;

/// Swappable LLM Game Master Service providing dynamic level generation
/// using Google Gemini 2.5 Flash, Groq LLaMA 3.3 Ultra-Fast inference,
/// and a resilient offline deterministic fallback generator.
class LlmGameMasterService {
  final GameMasterContextAssembler assembler;

  LlmBackendProvider activeProvider;
  String? overrideGeminiApiKey;
  String? overrideGroqApiKey;
  String lastUsedAdapter = 'none';

  static const Duration _httpTimeout = Duration(milliseconds: 3000);

  LlmGameMasterService({
    required this.assembler,
    this.activeProvider = LlmBackendProvider.gemini25Flash,
    this.overrideGeminiApiKey,
    this.overrideGroqApiKey,
  });

  String get effectiveGeminiApiKey =>
      overrideGeminiApiKey ?? LocalApiKeys.geminiApiKey;

  String get effectiveGroqApiKey =>
      overrideGroqApiKey ?? LocalApiKeys.groqApiKey;

  void setProvider(LlmBackendProvider provider) {
    activeProvider = provider;
  }

  void setApiKeys({String? geminiKey, String? groqKey}) {
    if (geminiKey != null && geminiKey.isNotEmpty) {
      overrideGeminiApiKey = geminiKey;
    }
    if (groqKey != null && groqKey.isNotEmpty) {
      overrideGroqApiKey = groqKey;
    }
  }

  /// Generates a complete 5-scene GeneratedLevelContract for levelNumber.
  /// Enforces automatic fallback chain with 4500ms timeout:
  /// gemini25Flash -> groqUltraFast -> dynamicLocalOffline.
  Future<GeneratedLevelContract> generateLevel({required int levelNumber}) async {
    final context = assembler.assembleContext(levelNumber: levelNumber);

    switch (activeProvider) {
      case LlmBackendProvider.gemini25Flash:
        try {
          final level = await _callGemini25Flash(context);
          lastUsedAdapter = 'gemini25Flash';
          return level;
        } catch (geminiError) {
          debugPrint('Gemini 2.5 Flash failed: $geminiError. Cascading to Groq Ultra Fast...');
        }

        try {
          final level = await _callGroqUltraFast(context);
          lastUsedAdapter = 'groqUltraFast';
          return level;
        } catch (groqError) {
          debugPrint('Groq Ultra Fast failed: $groqError. Cascading to Dynamic Local Offline...');
        }

        lastUsedAdapter = 'dynamicLocalOffline';
        return _generateDynamicLocalOffline(context);

      case LlmBackendProvider.groqUltraFast:
        try {
          final level = await _callGroqUltraFast(context);
          lastUsedAdapter = 'groqUltraFast';
          return level;
        } catch (groqError) {
          debugPrint('Groq Ultra Fast failed: $groqError. Cascading to Dynamic Local Offline...');
        }

        lastUsedAdapter = 'dynamicLocalOffline';
        return _generateDynamicLocalOffline(context);

      case LlmBackendProvider.dynamicLocalOffline:
        lastUsedAdapter = 'dynamicLocalOffline';
        return _generateDynamicLocalOffline(context);
    }
  }

  // ===========================================================================
  // ADAPTER 1: GEMINI 2.5 FLASH (Primary Default)
  // ===========================================================================

  Future<GeneratedLevelContract> _callGemini25Flash(
    GameMasterPromptContext context,
  ) async {
    final client = HttpClient()..connectionTimeout = _httpTimeout;
    final geminiKey = effectiveGeminiApiKey;

    try {
      final uri = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$geminiKey',
      );

      final request = await client.postUrl(uri).timeout(_httpTimeout);
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('x-goog-api-key', geminiKey);

      final promptText = _buildLevelPrompt(context);

      final requestPayload = json.encode({
        'contents': [
          {
            'parts': [
              {'text': promptText}
            ]
          }
        ],
        'generationConfig': {
          'responseMimeType': 'application/json',
          'temperature': 0.6,
          'thinkingConfig': {
            'thinkingBudget': 0,
          },
        },
      });

      request.write(requestPayload);
      final response = await request.close().timeout(_httpTimeout);

      final responseBody =
          await response.transform(utf8.decoder).join().timeout(_httpTimeout);

      if (response.statusCode != 200) {
        throw HttpException(
          'Gemini 2.5 Flash returned status ${response.statusCode}: $responseBody',
        );
      }

      final Map<String, dynamic> responseJson = json.decode(responseBody);
      final candidates = responseJson['candidates'] as List?;
      if (candidates == null || candidates.isEmpty) {
        throw const FormatException('No candidates in Gemini response');
      }

      final content = candidates[0]['content'];
      final parts = content?['parts'] as List?;
      final rawText = parts?[0]?['text'] as String?;

      if (rawText == null || rawText.isEmpty) {
        throw const FormatException('Empty text content in Gemini response');
      }

      final parsed = _cleanAndParseJson(rawText);
      return GeneratedLevelContract.fromJson(parsed);
    } finally {
      client.close();
    }
  }

  // ===========================================================================
  // ADAPTER 2: GROQ ULTRA-FAST (LLaMA 3.3 70B Versatile)
  // ===========================================================================

  Future<GeneratedLevelContract> _callGroqUltraFast(
    GameMasterPromptContext context,
  ) async {
    final client = HttpClient()..connectionTimeout = _httpTimeout;
    final groqKey = effectiveGroqApiKey;

    try {
      final uri = Uri.parse('https://api.groq.com/openai/v1/chat/completions');

      final request = await client.postUrl(uri).timeout(_httpTimeout);
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('Authorization', 'Bearer $groqKey');

      final promptText = _buildLevelPrompt(context);

      final requestPayload = json.encode({
        'model': 'llama-3.3-70b-versatile',
        'temperature': 0.6,
        'response_format': {'type': 'json_object'},
        'messages': [
          {
            'role': 'system',
            'content':
                'You are Nova AI Game Master generating primary grade educational games in Marathi and English. '
                'You must output ONLY valid JSON adhering strictly to the GeneratedLevelContract schema.',
          },
          {
            'role': 'user',
            'content': promptText,
          }
        ],
      });

      request.write(requestPayload);
      final response = await request.close().timeout(_httpTimeout);

      final responseBody =
          await response.transform(utf8.decoder).join().timeout(_httpTimeout);

      if (response.statusCode != 200) {
        throw HttpException(
          'Groq API returned status ${response.statusCode}: $responseBody',
        );
      }

      final Map<String, dynamic> responseJson = json.decode(responseBody);
      final choices = responseJson['choices'] as List?;
      if (choices == null || choices.isEmpty) {
        throw const FormatException('No choices in Groq response');
      }

      final message = choices[0]['message'];
      final rawContent = message?['content'] as String?;

      if (rawContent == null || rawContent.isEmpty) {
        throw const FormatException('Empty content in Groq message');
      }

      final parsed = _cleanAndParseJson(rawContent);
      return GeneratedLevelContract.fromJson(parsed);
    } finally {
      client.close();
    }
  }

  // ===========================================================================
  // ADAPTER 3: DYNAMIC LOCAL OFFLINE (Instant Deterministic Fallback)
  // ===========================================================================

  GeneratedLevelContract _generateDynamicLocalOffline(
    GameMasterPromptContext context,
  ) {
    final int levelNum = context.levelNumber;
    final int targetTier = context.targetDifficultyTier;
    final String levelTitle = levelNum == 1
        ? 'पातळी १ • माझी सकाळ • My Morning'
        : 'पातळी २ • वडाचे झाड आणि डेअरी • Banyan Grove & Dairy';
    final String theme = levelNum == 1 ? 'village_morning' : 'banyan_grove_dairy';

    // Map screen indices 0..4 to story beats:
    // Screen 6 (idx 0): Beat 1 intro
    // Screen 7 (idx 1): Beat 2 quiz
    // Screen 8 (idx 2): Beat 1 spot item
    // Screen 9 (idx 3): Beat 3 voice activity
    // Screen 10 (idx 4): Beat 4 matching
    final List<int> beatMapping = [1, 2, 1, 3, 4];

    final List<GeneratedSceneContract> scenes = [];

    for (int i = 0; i < 5; i++) {
      final int beatIndex = beatMapping[i];
      final QuestionCandidate? candidate = NovaSeedCatalog.getQuestionForBeat(
        levelId: levelNum,
        beatIndex: beatIndex,
        difficultyTier: targetTier,
      );

      final QuestionCandidate q = candidate ??
          NovaSeedCatalog.questionCandidates.firstWhere(
            (item) => item.payloadData['level_id'] == levelNum,
            orElse: () => NovaSeedCatalog.questionCandidates.first,
          );

      final String backdrop = q.requiredBackdropId.isNotEmpty
          ? q.requiredBackdropId
          : (levelNum == 1 ? 'bg_village_morning' : 'bg_banyan_grove');

      final String character = levelNum == 1
          ? (i % 2 == 0 ? 'char_chintu' : 'char_nova')
          : (i % 2 == 0 ? 'char_tiger' : 'char_nova');

      final List<String>? options = q.payloadData['options'] != null
          ? List<String>.from(q.payloadData['options'])
          : null;

      final String correctAnswer = (q.payloadData['correct_answer'] ??
              q.payloadData['expected_phrase'] ??
              'correct')
          .toString();

      final String? explanationHint =
          q.payloadData['explanation_hint']?.toString();

      scenes.add(
        GeneratedSceneContract(
          sceneId: i + 6,
          narrativeText: q.storyBridgeIntro.isNotEmpty
              ? q.storyBridgeIntro
              : (i > 0
                  ? NovaSeedCatalog.buildMarathiFillerBridge(
                      levelId: levelNum,
                      fromBeat: beatMapping[i - 1],
                      toBeat: beatIndex,
                      gotPreviousCorrect: true,
                    )
                  : (levelNum == 1
                      ? 'सूर्याची सोनेरी किरणे आली... गाव जागे झाले! चिवताई छतावर गाऊ लागली!'
                      : 'वडाच्या झाडाखाली वाघोबा आणि नोव्हा भेटले आहेत! चला डेअरीकडे जाऊया.')),
          environment: SceneEnvironmentContract(
            backdrop: backdrop,
            character: character,
            characterExpressionDefault: 'happy',
            prop: q.requiredPropLottie,
          ),
          questionData: SceneQuestionContract(
            questionType: q.questionType,
            originalQuestionId: q.questionId,
            storyQuestionText: q.coreLogicText,
            options: options,
            correctAnswer: correctAnswer,
            explanationHint: explanationHint,
            payloadData: q.payloadData,
            storyBridgeIntro: q.storyBridgeIntro,
            ttsMarathiText: q.ttsMarathiText,
          ),
        ),
      );
    }

    return GeneratedLevelContract(
      levelId: 'lvl_0${levelNum}_dynamic_offline_${DateTime.now().millisecondsSinceEpoch}',
      levelTitle: levelTitle,
      theme: theme,
      scenes: scenes,
    );
  }

  // ===========================================================================
  // PROMPT BUILDER & JSON PARSER HELPERS
  // ===========================================================================

  String _buildLevelPrompt(GameMasterPromptContext context) {
    final buffer = StringBuffer();
    buffer.writeln(context.systemPrompt);
    buffer.writeln();
    buffer.writeln('### EXACT INSTRUCTION:');
    buffer.writeln(
      'Generate an interactive learning level story for Level ${context.levelNumber} '
      '("${context.levelTitle}") in bilingual Marathi + English for primary students.',
    );
    buffer.writeln('Difficulty Tier: Tier ${context.targetDifficultyTier}');
    buffer.writeln('You must output EXACTLY 5 scenes in the "scenes" array.');
    buffer.writeln('Each scene MUST map to one of the candidate questions:');
    for (final q in context.candidateQuestions) {
      buffer.writeln('- [${q.questionId}] (${q.questionType}): ${q.coreLogicText}');
    }
    buffer.writeln();
    buffer.writeln('STORY PROGRESSION BRIDGES: In "narrative_text" for each scene, generate a rich, lively Marathi narrative filler bridge with English context that connects what just happened to the upcoming question so the story progresses smoothly like an authentic children\'s storybook!');
    buffer.writeln('Use ONLY approved asset IDs in the environment object:');
    for (final a in context.availableAssets) {
      buffer.writeln('- ${a.assetId} (${a.assetType})');
    }
    buffer.writeln();
    buffer.writeln('OUTPUT FORMAT: Strict single JSON object with no markdown fences, matching GeneratedLevelContract:');
    buffer.writeln('{"level_id": string, "level_title": string, "theme": string, "scenes": [{"scene_id": int, "narrative_text": string, "environment": {"backdrop": string, "character": string, "character_expression_default": string, "prop": string}, "question_data": {"question_type": string, "original_question_id": string, "story_question_text": string, "options": string[] or null, "correct_answer": string, "explanation_hint": string, "payload_data": object or null}}]}');
    return buffer.toString();
  }

  Map<String, dynamic> _cleanAndParseJson(String raw) {
    String clean = raw.trim();
    if (clean.startsWith('```json')) {
      clean = clean.substring(7);
    } else if (clean.startsWith('```')) {
      clean = clean.substring(3);
    }
    if (clean.endsWith('```')) {
      clean = clean.substring(0, clean.length - 3);
    }
    clean = clean.trim();
    return json.decode(clean) as Map<String, dynamic>;
  }
}
