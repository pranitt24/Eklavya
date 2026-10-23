import 'dart:math' as math;
import '../models/nova_schema_models.dart';

/// Seed catalog containing verified Lottie asset mappings, curriculum skills,
/// and 16 validated question candidates for Levels 1 and 2.
class NovaSeedCatalog {
  NovaSeedCatalog._();

  // ===========================================================================
  // 1. GAME ASSETS CATALOG (Approved Lottie & 3D Artwork Assets)
  // ===========================================================================
  static final List<GameAssetRecord> gameAssets = [
    // Nova Sprites (7 poses)
    GameAssetRecord(
      assetId: 'char_nova_standing',
      assetType: 'character',
      tags: ['guide', 'nova', 'robot'],
      unlockCost: 0,
      localAssetPath: 'assets/nova/characters/char_nova_standing.webp',
    ),
    GameAssetRecord(
      assetId: 'char_nova_happy',
      assetType: 'character',
      tags: ['guide', 'nova', 'robot'],
      unlockCost: 0,
      localAssetPath: 'assets/nova/characters/char_nova_happy.webp',
    ),
    GameAssetRecord(
      assetId: 'char_nova_thinking',
      assetType: 'character',
      tags: ['guide', 'nova', 'robot'],
      unlockCost: 0,
      localAssetPath: 'assets/nova/characters/char_nova_thinking.webp',
    ),
    GameAssetRecord(
      assetId: 'char_nova_pointing',
      assetType: 'character',
      tags: ['guide', 'nova', 'robot'],
      unlockCost: 0,
      localAssetPath: 'assets/nova/characters/char_nova_pointing.webp',
    ),
    GameAssetRecord(
      assetId: 'char_nova_reading',
      assetType: 'character',
      tags: ['guide', 'nova', 'robot'],
      unlockCost: 0,
      localAssetPath: 'assets/nova/characters/char_nova_reading.webp',
    ),
    GameAssetRecord(
      assetId: 'char_nova_namaste',
      assetType: 'character',
      tags: ['guide', 'nova', 'robot'],
      unlockCost: 0,
      localAssetPath: 'assets/nova/characters/char_nova_namaste.webp',
    ),
    GameAssetRecord(
      assetId: 'char_nova_waving',
      assetType: 'character',
      tags: ['guide', 'nova', 'robot'],
      unlockCost: 0,
      localAssetPath: 'assets/nova/characters/char_nova_waving.webp',
    ),

    // Countable Props (11 items)
    GameAssetRecord(
      assetId: 'prop_apple',
      assetType: 'prop',
      tags: ['countable', 'fruit'],
      unlockCost: 0,
      localAssetPath: 'assets/nova/props/prop_apple.webp',
    ),
    GameAssetRecord(
      assetId: 'prop_ball',
      assetType: 'prop',
      tags: ['countable', 'toy'],
      unlockCost: 0,
      localAssetPath: 'assets/nova/props/prop_ball.webp',
    ),
    GameAssetRecord(
      assetId: 'prop_banana',
      assetType: 'prop',
      tags: ['countable', 'fruit'],
      unlockCost: 0,
      localAssetPath: 'assets/nova/props/prop_banana.webp',
    ),
    GameAssetRecord(
      assetId: 'prop_basket',
      assetType: 'prop',
      tags: ['countable', 'container'],
      unlockCost: 0,
      localAssetPath: 'assets/nova/props/prop_basket.webp',
    ),
    GameAssetRecord(
      assetId: 'prop_book',
      assetType: 'prop',
      tags: ['countable', 'school'],
      unlockCost: 0,
      localAssetPath: 'assets/nova/props/prop_book.webp',
    ),
    GameAssetRecord(
      assetId: 'prop_chocolate',
      assetType: 'prop',
      tags: ['countable', 'sweet'],
      unlockCost: 0,
      localAssetPath: 'assets/nova/props/prop_chocolate.webp',
    ),
    GameAssetRecord(
      assetId: 'prop_flower',
      assetType: 'prop',
      tags: ['countable', 'nature'],
      unlockCost: 0,
      localAssetPath: 'assets/nova/props/prop_flower.webp',
    ),
    GameAssetRecord(
      assetId: 'prop_laddu',
      assetType: 'prop',
      tags: ['countable', 'sweet'],
      unlockCost: 0,
      localAssetPath: 'assets/nova/props/prop_laddu.webp',
    ),
    GameAssetRecord(
      assetId: 'prop_mango_webp',
      assetType: 'prop',
      tags: ['countable', 'fruit'],
      unlockCost: 0,
      localAssetPath: 'assets/nova/props/prop_mango.webp',
    ),
    GameAssetRecord(
      assetId: 'prop_pencil',
      assetType: 'prop',
      tags: ['countable', 'school'],
      unlockCost: 0,
      localAssetPath: 'assets/nova/props/prop_pencil.webp',
    ),
    GameAssetRecord(
      assetId: 'prop_star',
      assetType: 'prop',
      tags: ['countable', 'reward'],
      unlockCost: 0,
      localAssetPath: 'assets/nova/props/prop_star.webp',
    ),
    // Characters
    GameAssetRecord(
      assetId: 'char_nova',
      assetType: 'character',
      tags: ['village', 'forest', 'dairy'],
      unlockCost: 0,
      localAssetPath: 'assets/lottie/Robot says hello.json',
    ),
    GameAssetRecord(
      assetId: 'char_chintu',
      assetType: 'character',
      tags: ['village', 'morning'],
      unlockCost: 0,
      localAssetPath: 'assets/lottie/Hand Waving Animation.json',
    ),
    GameAssetRecord(
      assetId: 'char_tiger',
      assetType: 'character',
      tags: ['indian', 'forest', 'nature'],
      unlockCost: 0,
      localAssetPath: 'assets/lottie/Cute Tiger.json',
    ),
    GameAssetRecord(
      assetId: 'char_cow',
      assetType: 'character',
      tags: ['village', 'dairy', 'nature'],
      unlockCost: 0,
      localAssetPath: 'assets/lottie/cow.json',
    ),

    // Props
    GameAssetRecord(
      assetId: 'prop_bird',
      assetType: 'prop',
      tags: ['village', 'morning', 'nature'],
      unlockCost: 0,
      localAssetPath: 'assets/lottie/Blue Bird.json',
    ),
    GameAssetRecord(
      assetId: 'prop_tractor',
      assetType: 'prop',
      tags: ['village', 'farm'],
      unlockCost: 0,
      localAssetPath: 'assets/lottie/tractor.json',
    ),
    GameAssetRecord(
      assetId: 'prop_mango',
      assetType: 'prop',
      tags: ['indian', 'forest', 'nature'],
      unlockCost: 0,
      localAssetPath: 'assets/lottie/Mango Tree Animation.json',
    ),
    GameAssetRecord(
      assetId: 'prop_milk',
      assetType: 'prop',
      tags: ['village', 'dairy'],
      unlockCost: 0,
      localAssetPath: 'assets/lottie/Eda region 1.json',
    ),

    GameAssetRecord(
      assetId: 'prop_weighing_scale',
      assetType: 'prop',
      tags: ['market', 'math', 'weight'],
      unlockCost: 0,
      localAssetPath: 'assets/lottie/weighing_scale.json',
    ),
    GameAssetRecord(
      assetId: 'char_farmer',
      assetType: 'character',
      tags: ['market', 'village', 'farmer'],
      unlockCost: 0,
      localAssetPath: 'assets/lottie/farmer_waving.json',
    ),
    GameAssetRecord(
      assetId: 'prop_bicycle',
      assetType: 'prop',
      tags: ['village', 'morning', 'market'],
      unlockCost: 0,
      localAssetPath: 'assets/lottie/bicycle.json',
    ),
    GameAssetRecord(
      assetId: 'prop_piggy_bank',
      assetType: 'prop',
      tags: ['market', 'coins', 'savings'],
      unlockCost: 0,
      localAssetPath: 'assets/lottie/piggy_bank.json',
    ),
    GameAssetRecord(
      assetId: 'prop_fruit_basket',
      assetType: 'prop',
      tags: ['market', 'fruits', 'harvest'],
      unlockCost: 0,
      localAssetPath: 'assets/lottie/fruit_basket.json',
    ),
    GameAssetRecord(
      assetId: 'prop_food_stall',
      assetType: 'prop',
      tags: ['market', 'shop', 'bazaar'],
      unlockCost: 0,
      localAssetPath: 'assets/lottie/food stall.json',
    ),

    // Level 4: Village School & Evening Fair Props & Shapes
    GameAssetRecord(
      assetId: 'prop_bus',
      assetType: 'prop',
      tags: ['school', 'vehicle', 'morning'],
      unlockCost: 0,
      localAssetPath: 'assets/lottie/bus.json',
    ),
    GameAssetRecord(
      assetId: 'prop_school_bag',
      assetType: 'prop',
      tags: ['school', 'study', 'bag'],
      unlockCost: 0,
      localAssetPath: 'assets/lottie/school_bag.json',
    ),
    GameAssetRecord(
      assetId: 'shape_triangle',
      assetType: 'shape',
      tags: ['school', 'shape', 'math'],
      unlockCost: 0,
      localAssetPath: 'assets/lottie/triangle.json',
    ),
    GameAssetRecord(
      assetId: 'shape_square',
      assetType: 'shape',
      tags: ['school', 'shape', 'math'],
      unlockCost: 0,
      localAssetPath: 'assets/lottie/square.json',
    ),
    GameAssetRecord(
      assetId: 'shape_rectangle',
      assetType: 'shape',
      tags: ['school', 'shape', 'math'],
      unlockCost: 0,
      localAssetPath: 'assets/lottie/rectangle.json',
    ),
    GameAssetRecord(
      assetId: 'shape_circle',
      assetType: 'shape',
      tags: ['school', 'shape', 'math'],
      unlockCost: 0,
      localAssetPath: 'assets/lottie/circle.json',
    ),
    GameAssetRecord(
      assetId: 'prop_ferris_wheel',
      assetType: 'prop',
      tags: ['fair', 'jatra', 'wheel'],
      unlockCost: 0,
      localAssetPath: 'assets/lottie/ferris_wheel.json',
    ),
    GameAssetRecord(
      assetId: 'prop_balloons',
      assetType: 'prop',
      tags: ['fair', 'jatra', 'count'],
      unlockCost: 0,
      localAssetPath: 'assets/lottie/balloons.json',
    ),
    GameAssetRecord(
      assetId: 'prop_trophy',
      assetType: 'reward',
      tags: ['reward', 'champion', 'finale'],
      unlockCost: 50,
      localAssetPath: 'assets/lottie/trophy.json',
    ),

    // Backdrops
    GameAssetRecord(
      assetId: 'bg_village_morning',
      assetType: 'backdrop',
      tags: ['village', 'morning'],
      unlockCost: 0,
      localAssetPath: 'assets/images/village_story_bg.png',
    ),
    GameAssetRecord(
      assetId: 'bg_banyan_grove',
      assetType: 'backdrop',
      tags: ['indian', 'forest', 'nature'],
      unlockCost: 0,
      localAssetPath: 'assets/lottie/Mango Tree Animation.json',
    ),
    GameAssetRecord(
      assetId: 'bg_village_market',
      assetType: 'backdrop',
      tags: ['market', 'village', 'bazaar'],
      unlockCost: 0,
      localAssetPath: 'assets/lottie/food stall.json',
    ),
    GameAssetRecord(
      assetId: 'bg_village_school',
      assetType: 'backdrop',
      tags: ['school', 'fair', 'village'],
      unlockCost: 0,
      localAssetPath: 'assets/lottie/bus.json',
    ),
  ];

  // ===========================================================================
  // 2. CURRICULUM SKILLS (Learning Outcomes)
  // ===========================================================================
  static final List<SkillRecord> skills = [
    SkillRecord(
      skillId: 'MATH_COMPARE_01',
      skillName: 'मोठे आणि छोटे (Size Comparison)',
      subject: 'Math',
      pGuess: 0.20,
      pSlip: 0.10,
      pTransit: 0.15,
    ),
    SkillRecord(
      skillId: 'LANG_MARATHI_01',
      skillName: 'मराठी संवाद व संभाषण (Vocabulary & Greetings)',
      subject: 'Language',
      pGuess: 0.25,
      pSlip: 0.10,
      pTransit: 0.20,
    ),
    SkillRecord(
      skillId: 'MATH_COUNT_01',
      skillName: 'वस्तू मोजणे १ ते १० (Counting 1 to 10)',
      subject: 'Math',
      pGuess: 0.20,
      pSlip: 0.10,
      pTransit: 0.15,
    ),
    SkillRecord(
      skillId: 'MATH_ADD_01',
      skillName: 'एक अंकी बेरीज (Single Digit Addition)',
      subject: 'Math',
      pGuess: 0.15,
      pSlip: 0.10,
      pTransit: 0.12,
    ),
    SkillRecord(
      skillId: 'MATH_MARKET_SUB_01',
      skillName: 'बाजारातील मोजणी, तुलना व वजाबाकी (Market Counting & Subtraction)',
      subject: 'Math',
      pGuess: 0.20,
      pSlip: 0.10,
      pTransit: 0.15,
    ),
    SkillRecord(
      skillId: 'MATH_SHAPES_ZERO_01',
      skillName: 'भूमितीचे आकार, मोजणी व शून्य (Shapes, Counting & Zero)',
      subject: 'Math',
      pGuess: 0.20,
      pSlip: 0.10,
      pTransit: 0.15,
    ),
  ];

  // ===========================================================================
  // 3. 24 VALIDATED SCENE-LOCKED TIERED QUESTION CANDIDATES
  // ===========================================================================
  static final List<QuestionCandidate> questionCandidates = [
    // -------------------------------------------------------------------------
    // LEVEL 1: "माझी सकाळ" (Village Morning) - 12 Candidates (4 Beats x 3 Tiers)
    // -------------------------------------------------------------------------
    // Beat 1: Spot Chiu on Roof (Visual: Blue Bird.json / Roof Bird)
    QuestionCandidate(
      questionId: 'Q_VILL_01_T1',
      skillId: 'LANG_MARATHI_01',
      difficultyTier: 1,
      questionType: 'spot_item',
      coreLogicText: 'छतावर कोण बसले आहे? गाणे गाणाऱ्या चिवताईला टॅप करा.',
      requiredBackdropId: 'bg_village_morning',
      requiredCharacterLottie: 'assets/lottie/Hand Waving Animation.json',
      requiredPropLottie: 'assets/lottie/Blue Bird.json',
      storyBridgeIntro: 'सकाळ झाली! सूर्याची सोनेरी किरणे गावावर पडली आहेत. बघा, छतावर चिवताई गाणे गात आहे!',
      ttsMarathiText: 'सकाळ झाली छतावर गाणे गाणाऱ्या चिवताईला टॅप करा',
      payloadData: {
        'level_id': 1,
        'beat_index': 1,
        'target_asset': 'prop_bird',
        'location': 'roof_apex',
        'correct_answer': 'चिवताई',
        'explanation_hint': 'घराच्या कौलारू छतावर बसलेली चिमणी पहा.',
      },
    ),
    QuestionCandidate(
      questionId: 'Q_VILL_01_T2',
      skillId: 'MATH_COMPARE_01',
      difficultyTier: 2,
      questionType: 'fill_blanks',
      coreLogicText: 'चिवताई छतावर कुठे बसली आहे? वर की खाली?',
      requiredBackdropId: 'bg_village_morning',
      requiredCharacterLottie: 'assets/lottie/Hand Waving Animation.json',
      requiredPropLottie: 'assets/lottie/Blue Bird.json',
      storyBridgeIntro: 'सकाळ झाली! सूर्याची सोनेरी किरणे गावावर पडली आहेत. बघा, छतावर चिवताई गाणे गात आहे!',
      ttsMarathiText: 'चिवताई छतावर कुठे बसली आहे वर की खाली',
      payloadData: {
        'level_id': 1,
        'beat_index': 1,
        'options': ['वर', 'खाली'],
        'correct_answer': 'वर',
        'explanation_hint': 'चिवताई छताच्या वर बसलेली आहे.',
      },
    ),
    QuestionCandidate(
      questionId: 'Q_VILL_01_T3',
      skillId: 'MATH_COUNT_01',
      difficultyTier: 3,
      questionType: 'fill_blanks',
      coreLogicText: 'छतावर १ चिवताई आहे आणि आणखी १ मित्र पक्षी आला. एकूण किती पक्षी झाले? (१ + १ = ___)',
      requiredBackdropId: 'bg_village_morning',
      requiredCharacterLottie: 'assets/lottie/Hand Waving Animation.json',
      requiredPropLottie: 'assets/lottie/Blue Bird.json',
      storyBridgeIntro: 'सकाळ झाली! सूर्याची सोनेरी किरणे गावावर पडली आहेत. बघा, छतावर चिवताई गाणे गात आहे!',
      ttsMarathiText: 'छतावर एक चिवताई आहे आणि आणखी एक पक्षी आला एकूण किती पक्षी झाले',
      payloadData: {
        'level_id': 1,
        'beat_index': 1,
        'options': ['१', '२', '३'],
        'correct_answer': '२',
        'explanation_hint': 'एक अधिक एक मिळून दोन होतात.',
      },
    ),

    // Beat 2: Farm Work Begins (Visual: tractor.json vs Bicycle / cow.json)
    QuestionCandidate(
      questionId: 'Q_VILL_02_T1',
      skillId: 'MATH_COMPARE_01',
      difficultyTier: 1,
      questionType: 'fill_blanks',
      coreLogicText: 'ट्रॅक्टर आणि सायकलमध्ये मोठे वाहन कोणते? मोठे वाहन ओळखा.',
      requiredBackdropId: 'bg_village_morning',
      requiredCharacterLottie: 'assets/lottie/Robot says hello.json',
      requiredPropLottie: 'assets/lottie/tractor.json',
      storyBridgeIntro: 'चिवताईचे गाणे ऐकून चिंटू जागा झाला. आता शेतात जाण्याची वेळ झाली! शेताबाहेर काय उभे आहे बघा!',
      ttsMarathiText: 'ट्रॅक्टर आणि सायकलमध्ये मोठे वाहन कोणते मोठे वाहन ओळखा',
      payloadData: {
        'level_id': 1,
        'beat_index': 2,
        'options': ['ट्रॅक्टर', 'सायकल'],
        'correct_answer': 'ट्रॅक्टर',
        'explanation_hint': 'शेतात काम करणारे मोठे वाहन ट्रॅक्टर आहे.',
        'display_art': {'big': 'prop_tractor', 'small': 'bicycle'},
      },
    ),
    QuestionCandidate(
      questionId: 'Q_VILL_02_T2',
      skillId: 'MATH_COMPARE_01',
      difficultyTier: 2,
      questionType: 'fill_blanks',
      coreLogicText: 'कोणत्या गाडीला जास्त चाके आहेत? (४ चाके की २ चाके?)',
      requiredBackdropId: 'bg_village_morning',
      requiredCharacterLottie: 'assets/lottie/Robot says hello.json',
      requiredPropLottie: 'assets/lottie/tractor.json',
      storyBridgeIntro: 'चिवताईचे गाणे ऐकून चिंटू अंगणात आला. आता शेतात जाण्यासाठी ट्रॅक्टर आणि सायकल तयार आहेत!',
      ttsMarathiText: 'कोणत्या गाडीला जास्त चाके आहेत चार चाके की दोन चाके',
      payloadData: {
        'level_id': 1,
        'beat_index': 2,
        'options': ['ट्रॅक्टर', 'सायकल'],
        'correct_answer': 'ट्रॅक्टर',
        'explanation_hint': 'ट्रॅक्टरला ४ चाके असतात, म्हणून ट्रॅक्टरला जास्त चाके आहेत!',
        'english_text': 'Which vehicle has more wheels? Tractor (4) or Bicycle (2)?',
      },
    ),
    QuestionCandidate(
      questionId: 'Q_VILL_02_T3',
      skillId: 'MATH_COMPARE_01',
      difficultyTier: 3,
      questionType: 'fill_blanks',
      coreLogicText: 'शेतात नांगरणी करण्यासाठी जास्त ताकदीची गाडी कोणती? ट्रॅक्टर की सायकल?',
      requiredBackdropId: 'bg_village_morning',
      requiredCharacterLottie: 'assets/lottie/Robot says hello.json',
      requiredPropLottie: 'assets/lottie/tractor.json',
      storyBridgeIntro: 'चिवताईचे गाणे ऐकून चिंटू अंगणात आला. आता शेतात जाण्यासाठी ट्रॅक्टर आणि सायकल तयार आहेत!',
      ttsMarathiText: 'शेतात नांगरणी करण्यासाठी जास्त ताकदीची गाडी कोणती ट्रॅक्टर की सायकल',
      payloadData: {
        'level_id': 1,
        'beat_index': 2,
        'options': ['ट्रॅक्टर', 'सायकल'],
        'correct_answer': 'ट्रॅक्टर',
        'explanation_hint': 'ट्रॅक्टरमध्ये शेतीची अवजड कामे करण्याचे मोठे सामर्थ्य असते!',
        'english_text': 'Which vehicle is more powerful for plowing? Tractor or Bicycle?',
      },
    ),

    // Beat 3: Morning Greeting Voice Activity (Visual: Hand Waving Animation.json + Mic)
    QuestionCandidate(
      questionId: 'Q_VILL_03_T1',
      skillId: 'LANG_MARATHI_01',
      difficultyTier: 1,
      questionType: 'voice_input',
      coreLogicText: 'मित्राला भेटल्यावर काय म्हणायचे? माईकमध्ये "शुभ प्रभात" बोला.',
      requiredBackdropId: 'bg_village_morning',
      requiredCharacterLottie: 'assets/lottie/Hand Waving Animation.json',
      requiredPropLottie: 'assets/lottie/Robot says hello.json',
      storyBridgeIntro: 'चिंटू आता शाळेच्या वाटेवर निघाला. वाटेत त्याला NOVA भेटला! चला, त्यांना प्रेमाने नमस्कार करूया!',
      ttsMarathiText: 'मित्राला भेटल्यावर काय म्हणायचे माईकमध्ये शुभ प्रभात बोला',
      payloadData: {
        'level_id': 1,
        'beat_index': 3,
        'expected_phrase': 'शुभ प्रभात',
        'alternatives': ['सुप्रभात', 'Good Morning', 'शुभप्रभात'],
        'correct_answer': 'शुभ प्रभात',
        'explanation_hint': 'माईक दाबून स्पष्ट आवाजात "शुभ प्रभात" म्हणा.',
      },
    ),
    QuestionCandidate(
      questionId: 'Q_VILL_03_T2',
      skillId: 'LANG_MARATHI_01',
      difficultyTier: 2,
      questionType: 'voice_input',
      coreLogicText: 'मित्राला पाहिल्यावर हात जोडून काय म्हणायचे? माईकमध्ये "नमस्कार" बोला.',
      requiredBackdropId: 'bg_village_morning',
      requiredCharacterLottie: 'assets/lottie/Hand Waving Animation.json',
      requiredPropLottie: 'assets/lottie/Robot says hello.json',
      storyBridgeIntro: 'चिंटू आता शाळेच्या वाटेवर निघाला. वाटेत त्याला NOVA भेटला! चला, त्यांना प्रेमाने नमस्कार करूया!',
      ttsMarathiText: 'मित्राला पाहिल्यावर हात जोडून काय म्हणायचे माईकमध्ये नमस्कार बोला',
      payloadData: {
        'level_id': 1,
        'beat_index': 3,
        'expected_phrase': 'नमस्कार',
        'alternatives': ['Namaskar', 'नमस्ते', 'नमस्कार नोव्हा'],
        'correct_answer': 'नमस्कार',
        'explanation_hint': 'माईक दाबून प्रेमाने "नमस्कार" म्हणा.',
      },
    ),
    QuestionCandidate(
      questionId: 'Q_VILL_03_T3',
      skillId: 'MATH_COUNT_01',
      difficultyTier: 3,
      questionType: 'voice_input',
      coreLogicText: 'रस्त्यावर चिंटू आणि नोव्हा हात हलवत आहेत. किती मित्र आहेत? माईकमध्ये संख्या बोला: "दोन".',
      requiredBackdropId: 'bg_village_morning',
      requiredCharacterLottie: 'assets/lottie/Hand Waving Animation.json',
      requiredPropLottie: 'assets/lottie/Robot says hello.json',
      storyBridgeIntro: 'चिंटू आता शाळेच्या वाटेवर निघाला. वाटेत त्याला NOVA भेटला! चला, त्यांना प्रेमाने नमस्कार करूया!',
      ttsMarathiText: 'रस्त्यावर चिंटू आणि नोव्हा हात हलवत आहेत किती मित्र आहेत माईकमध्ये संख्या दोन बोला',
      payloadData: {
        'level_id': 1,
        'beat_index': 3,
        'expected_phrase': 'दोन',
        'alternatives': ['2', 'Two', 'Don', 'दोन मित्र'],
        'correct_answer': 'दोन',
        'explanation_hint': 'चिंटू आणि नोव्हा मिळून दोन मित्र आहेत, म्हणा "दोन".',
      },
    ),

    // Beat 4: Morning Wrap-Up Match (Visual: Linked Morning Pairs)
    QuestionCandidate(
      questionId: 'Q_VILL_04_T1',
      skillId: 'LANG_MARATHI_01',
      difficultyTier: 1,
      questionType: 'match_following',
      coreLogicText: 'सकाळच्या गोष्टींच्या योग्य जोड्या लावा.',
      requiredBackdropId: 'bg_village_morning',
      requiredCharacterLottie: 'assets/lottie/Hand Waving Animation.json',
      requiredPropLottie: 'assets/lottie/Blue Bird.json',
      storyBridgeIntro: 'शाब्बास! चिंटूने सकाळची सगळी कामे पूर्ण केली. आता आपण सकाळी पाहिलेल्या गोष्टींच्या जोड्या जुळवूया!',
      ttsMarathiText: 'सकाळच्या गोष्टींच्या योग्य जोड्या लावा सूर्य ट्रॅक्टर आणि चिवताई',
      payloadData: {
        'level_id': 1,
        'beat_index': 4,
        'pairs': [
          {'a': 'सूर्य', 'b': 'सकाळ'},
          {'a': 'ट्रॅक्टर', 'b': 'मोठा'},
          {'a': 'चिवताई', 'b': 'छत'},
        ],
        'correct_answer': 'matched_all',
        'explanation_hint': 'सूर्य सकाळी उगवतो आणि चिवताई छतावर बसते.',
      },
    ),
    QuestionCandidate(
      questionId: 'Q_VILL_04_T2',
      skillId: 'MATH_COMPARE_01',
      difficultyTier: 2,
      questionType: 'match_following',
      coreLogicText: 'सकाळच्या साथीदारांच्या आणि स्वरूपाच्या जोड्या लावा.',
      requiredBackdropId: 'bg_village_morning',
      requiredCharacterLottie: 'assets/lottie/Hand Waving Animation.json',
      requiredPropLottie: 'assets/lottie/Blue Bird.json',
      storyBridgeIntro: 'शाब्बास! चिंटूने सकाळची सगळी कामे पूर्ण केली. आता आपण सकाळी पाहिलेल्या गोष्टींच्या जोड्या जुळवूया!',
      ttsMarathiText: 'सकाळच्या साथीदारांच्या आणि स्वरूपाच्या जोड्या लावा',
      payloadData: {
        'level_id': 1,
        'beat_index': 4,
        'pairs': [
          {'a': 'मोठा', 'b': 'ट्रॅक्टर'},
          {'a': 'लहान', 'b': 'सायकल'},
          {'a': 'वर', 'b': 'चिवताई'},
        ],
        'correct_answer': 'matched_all',
        'explanation_hint': 'ट्रॅक्टर मोठा आहे आणि सायकल लहान आहे.',
      },
    ),
    QuestionCandidate(
      questionId: 'Q_VILL_04_T3',
      skillId: 'MATH_COMPARE_01',
      difficultyTier: 3,
      questionType: 'match_following',
      coreLogicText: 'विरुद्धार्थी शब्दांच्या जोड्या लावा.',
      requiredBackdropId: 'bg_village_morning',
      requiredCharacterLottie: 'assets/lottie/Hand Waving Animation.json',
      requiredPropLottie: 'assets/lottie/Blue Bird.json',
      storyBridgeIntro: 'शाब्बास! चिंटूने सकाळची सगळी कामे पूर्ण केली. आता आपण सकाळी पाहिलेल्या गोष्टींच्या जोड्या जुळवूया!',
      ttsMarathiText: 'विरुद्धार्थी शब्दांच्या जोड्या लावा मोठे वर आणि सकाळ',
      payloadData: {
        'level_id': 1,
        'beat_index': 4,
        'pairs': [
          {'a': 'मोठे', 'b': 'छोटे'},
          {'a': 'वर', 'b': 'खाली'},
          {'a': 'सकाळ', 'b': 'संध्याकाळ'},
        ],
        'correct_answer': 'matched_all',
        'explanation_hint': 'विरुद्ध अर्थ असणाऱ्या शब्दांच्या जोड्या जुळवा.',
      },
    ),

    // -------------------------------------------------------------------------
    // LEVEL 2: "वडाचे झाड आणि डेअरी" (Banyan Grove & Dairy) - 12 Candidates
    // -------------------------------------------------------------------------
    // Beat 1: Under the Banyan Tree (Visual: Mango Tree Animation.json + Cute Tiger.json)
    QuestionCandidate(
      questionId: 'Q_GROVE_01_T1',
      skillId: 'MATH_COUNT_01',
      difficultyTier: 1,
      questionType: 'spot_item',
      coreLogicText: 'झाडाखाली बसलेल्या गोंडस वाघोबाला शोधा आणि टॅप करा.',
      requiredBackdropId: 'bg_banyan_grove',
      requiredCharacterLottie: 'assets/lottie/Cute Tiger.json',
      requiredPropLottie: 'assets/lottie/Mango Tree Animation.json',
      storyBridgeIntro: 'चिंटू आणि NOVA गावाजवळच्या मोठ्या आंब्याच्या आणि वडाच्या बागेत पोहोचले! तिथे एक छोटा वाघोबा आंबे मोजत बसला आहे!',
      ttsMarathiText: 'झाडाखाली बसलेल्या गोंडस वाघोबाला शोधा आणि टॅप करा',
      payloadData: {
        'level_id': 2,
        'beat_index': 1,
        'target_asset': 'char_tiger',
        'location': 'tree_shade',
        'correct_answer': 'वाघोबा',
        'explanation_hint': 'मोठ्या झाडाच्या सावलीत बसलेला पिवळा वाघोबा पहा.',
      },
    ),
    QuestionCandidate(
      questionId: 'Q_GROVE_01_T2',
      skillId: 'MATH_COUNT_01',
      difficultyTier: 2,
      questionType: 'fill_blanks',
      coreLogicText: 'झाडावर ३ पिकलेले आंबे होते. १ आंबा खाली पडला. आता झाडावर किती आंबे राहिले? (३ - १ = ___)',
      requiredBackdropId: 'bg_banyan_grove',
      requiredCharacterLottie: 'assets/lottie/Cute Tiger.json',
      requiredPropLottie: 'assets/lottie/Mango Tree Animation.json',
      storyBridgeIntro: 'चिंटू आणि NOVA गावाजवळच्या मोठ्या आंब्याच्या आणि वडाच्या बागेत पोहोचले! तिथे एक छोटा वाघोबा आंबे मोजत बसला आहे!',
      ttsMarathiText: 'झाडावर तीन पिकलेले आंबे होते एक आंबा खाली पडला आता झाडावर किती आंबे राहिले',
      payloadData: {
        'level_id': 2,
        'beat_index': 1,
        'options': ['१', '२', '३'],
        'correct_answer': '२',
        'explanation_hint': 'तीन मधून एक कमी केल्यावर दोन शिल्लक राहतात.',
      },
    ),
    QuestionCandidate(
      questionId: 'Q_GROVE_01_T3',
      skillId: 'MATH_ADD_01',
      difficultyTier: 3,
      questionType: 'fill_blanks',
      coreLogicText: 'वाघोबाला झाडाखाली ४ आंबे सापडले आणि ३ आंबे आणखी खाली पडले. एकूण किती आंबे झाले? (४ + ३ = ___)',
      requiredBackdropId: 'bg_banyan_grove',
      requiredCharacterLottie: 'assets/lottie/Cute Tiger.json',
      requiredPropLottie: 'assets/lottie/Mango Tree Animation.json',
      storyBridgeIntro: 'चिंटू आणि NOVA गावाजवळच्या मोठ्या आंब्याच्या आणि वडाच्या बागेत पोहोचले! तिथे एक छोटा वाघोबा आंबे मोजत बसला आहे!',
      ttsMarathiText: 'वाघोबाला झाडाखाली चार आंबे सापडले आणि तीन आंबे आणखी खाली पडले एकूण किती आंबे झाले',
      payloadData: {
        'level_id': 2,
        'beat_index': 1,
        'options': ['६', '७', '८'],
        'correct_answer': '७',
        'explanation_hint': 'चार अधिक तीन बरोबर सात आंबे होतात.',
      },
    ),

    // Beat 2: Visiting the Village Dairy (Visual: cow.json & Eda region 1.json Milk Carton)
    QuestionCandidate(
      questionId: 'Q_GROVE_02_T1',
      skillId: 'MATH_COMPARE_01',
      difficultyTier: 1,
      questionType: 'fill_blanks',
      coreLogicText: 'गोठ्यातील गाय आणि दुधाचा डबा यात मोठे कोण आहे? मोठी वस्तू ओळखा.',
      requiredBackdropId: 'bg_banyan_grove',
      requiredCharacterLottie: 'assets/lottie/cow.json',
      requiredPropLottie: 'assets/lottie/Eda region 1.json',
      storyBridgeIntro: 'वाघोबाला भेटल्यावर चिंटू गावातील डेअरीमध्ये पोहोचला. तिथे कपिला गाय आणि ताजे दूध आहे!',
      ttsMarathiText: 'गोठ्यातील गाय आणि दुधाचा डबा यात मोठे कोण आहे मोठी वस्तू ओळखा',
      payloadData: {
        'level_id': 2,
        'beat_index': 2,
        'options': ['गाय', 'दुधाचा डबा'],
        'correct_answer': 'गाय',
        'explanation_hint': 'गाय आकाराने दुधाच्या डब्यापेक्षा मोठी असते.',
        'english_text': 'Which one is bigger? Cow or Milk Carton?',
      },
    ),
    QuestionCandidate(
      questionId: 'Q_GROVE_02_T2',
      skillId: 'MATH_COMPARE_01',
      difficultyTier: 2,
      questionType: 'fill_blanks',
      coreLogicText: 'आपल्याला ताजे आणि सकस दूध कोणाकडून मिळते? गाय की दुधाचा डबा?',
      requiredBackdropId: 'bg_banyan_grove',
      requiredCharacterLottie: 'assets/lottie/cow.json',
      requiredPropLottie: 'assets/lottie/Eda region 1.json',
      storyBridgeIntro: 'वाघोबाला भेटल्यावर चिंटू गावातील डेअरीमध्ये पोहोचला. तिथे कपिला गाय आणि ताजे दूध आहे!',
      ttsMarathiText: 'आपल्याला ताजे आणि सकस दूध कोणाकडून मिळते गाय की दुधाचा डबा',
      payloadData: {
        'level_id': 2,
        'beat_index': 2,
        'options': ['गाय', 'दुधाचा डबा'],
        'correct_answer': 'गाय',
        'explanation_hint': 'गोठ्यातील कपिला गाय आपल्याला ताजे आणि गोड दूध देते!',
        'english_text': 'Who gives us fresh healthy milk? Cow or Milk Carton?',
      },
    ),
    QuestionCandidate(
      questionId: 'Q_GROVE_02_T3',
      skillId: 'MATH_COMPARE_01',
      difficultyTier: 3,
      questionType: 'fill_blanks',
      coreLogicText: 'कोणते वजन जास्त जड आहे? कपिला गाय की १ दुधाचा डबा?',
      requiredBackdropId: 'bg_banyan_grove',
      requiredCharacterLottie: 'assets/lottie/cow.json',
      requiredPropLottie: 'assets/lottie/Eda region 1.json',
      storyBridgeIntro: 'वाघोबाला भेटल्यावर चिंटू गावातील डेअरीमध्ये पोहोचला. तिथे कपिला गाय आणि ताजे दूध आहे!',
      ttsMarathiText: 'कोणते वजन जास्त जड आहे कपिला गाय की एक दुधाचा डबा',
      payloadData: {
        'level_id': 2,
        'beat_index': 2,
        'options': ['गाय', 'दुधाचा डबा'],
        'correct_answer': 'गाय',
        'explanation_hint': 'मोठ्या कपिला गाईचे वजन १ दुधाच्या डब्यापेक्षा खूप जास्त असते!',
        'english_text': 'Which one is heavier? Kapila Cow or 1 Milk Can?',
      },
    ),

    // Beat 3: Spoken Dairy & Grove Counting (Visual: Eda region 1.json / Cute Tiger.json + Mic)
    QuestionCandidate(
      questionId: 'Q_GROVE_03_T1',
      skillId: 'MATH_COUNT_01',
      difficultyTier: 1,
      questionType: 'voice_input',
      coreLogicText: 'आपल्याला ३ दुधाचे डबे हवे आहेत. माईकमध्ये संख्या बोला: "तीन".',
      requiredBackdropId: 'bg_banyan_grove',
      requiredCharacterLottie: 'assets/lottie/Cute Tiger.json',
      requiredPropLottie: 'assets/lottie/Eda region 1.json',
      storyBridgeIntro: 'डेअरी काकांनी विचारले की आपल्याला किती दुधाचे डबे हवे आहेत! चला, माईकमध्ये आवाज देऊन उत्तर सांगूया!',
      ttsMarathiText: 'आपल्याला तीन दुधाचे डबे हवे आहेत माईकमध्ये संख्या तीन बोला',
      payloadData: {
        'level_id': 2,
        'beat_index': 3,
        'expected_phrase': 'तीन',
        'alternatives': ['3', 'Three', 'Tin', 'तीन डबे'],
        'correct_answer': 'तीन',
        'explanation_hint': 'माईक दाबून स्पष्ट म्हणा: "तीन".',
      },
    ),
    QuestionCandidate(
      questionId: 'Q_GROVE_03_T2',
      skillId: 'MATH_ADD_01',
      difficultyTier: 2,
      questionType: 'voice_input',
      coreLogicText: '२ अधिक ३ किती होतात? बेरीज करून माईकमध्ये उत्तर बोला: "पाच".',
      requiredBackdropId: 'bg_banyan_grove',
      requiredCharacterLottie: 'assets/lottie/Cute Tiger.json',
      requiredPropLottie: 'assets/lottie/Eda region 1.json',
      storyBridgeIntro: 'डेअरी काकांनी विचारले की आपल्याला किती दुधाचे डबे हवे आहेत! चला, माईकमध्ये आवाज देऊन उत्तर सांगूया!',
      ttsMarathiText: 'दोन अधिक तीन किती होतात बेरीज करून माईकमध्ये पाच बोला',
      payloadData: {
        'level_id': 2,
        'beat_index': 3,
        'expected_phrase': 'पाच',
        'alternatives': ['5', 'Five', 'Pach', 'पाच डबे'],
        'correct_answer': 'पाच',
        'explanation_hint': 'दोन अधिक तीन बरोबर पाच होतात, म्हणा "पाच".',
      },
    ),
    QuestionCandidate(
      questionId: 'Q_GROVE_03_T3',
      skillId: 'MATH_ADD_01',
      difficultyTier: 3,
      questionType: 'voice_input',
      coreLogicText: '४ अधिक ३ किती होतात? बेरीज करून माईकमध्ये उत्तर बोला: "सात".',
      requiredBackdropId: 'bg_banyan_grove',
      requiredCharacterLottie: 'assets/lottie/Cute Tiger.json',
      requiredPropLottie: 'assets/lottie/Eda region 1.json',
      storyBridgeIntro: 'डेअरी काकांनी विचारले की आपल्याला किती दुधाचे डबे हवे आहेत! चला, माईकमध्ये आवाज देऊन उत्तर सांगूया!',
      ttsMarathiText: 'चार अधिक तीन किती होतात बेरीज करून माईकमध्ये सात बोला',
      payloadData: {
        'level_id': 2,
        'beat_index': 3,
        'expected_phrase': 'सात',
        'alternatives': ['7', 'Seven', 'Sat', 'सात डबे'],
        'correct_answer': 'सात',
        'explanation_hint': 'चार अधिक तीन बरोबर सात होतात, म्हणा "सात".',
      },
    ),

    // Beat 4: Banyan & Dairy Match (Visual: Mango, Tiger, Cow, Milk Pairs)
    QuestionCandidate(
      questionId: 'Q_GROVE_04_T1',
      skillId: 'LANG_MARATHI_01',
      difficultyTier: 1,
      questionType: 'match_following',
      coreLogicText: 'बाग आणि डेअरीतील साथीदारांच्या जोड्या लावा.',
      requiredBackdropId: 'bg_banyan_grove',
      requiredCharacterLottie: 'assets/lottie/Cute Tiger.json',
      requiredPropLottie: 'assets/lottie/cow.json',
      storyBridgeIntro: 'खूप छान! आता बागेतील आणि डेअरीतील गोष्टींच्या योग्य जोड्या लावूया!',
      ttsMarathiText: 'बाग आणि डेअरीतील साथीदारांच्या जोड्या लावा वाघ गाय आणि आंबा',
      payloadData: {
        'level_id': 2,
        'beat_index': 4,
        'pairs': [
          {'a': 'वाघ', 'b': 'जंगल'},
          {'a': 'गाय', 'b': 'दूध'},
          {'a': 'आंबा', 'b': 'झाड'},
        ],
        'correct_answer': 'matched_all',
        'explanation_hint': 'वाघ जंगलात राहतो, गाय दूध देते आणि आंबा झाडावर येतो.',
      },
    ),
    QuestionCandidate(
      questionId: 'Q_GROVE_04_T2',
      skillId: 'MATH_ADD_01',
      difficultyTier: 2,
      questionType: 'match_following',
      coreLogicText: 'बेरीज आणि योग्य उत्तरांच्या जोड्या लावा.',
      requiredBackdropId: 'bg_banyan_grove',
      requiredCharacterLottie: 'assets/lottie/Cute Tiger.json',
      requiredPropLottie: 'assets/lottie/cow.json',
      storyBridgeIntro: 'खूप छान! आता बागेतील आणि डेअरीतील गोष्टींच्या योग्य जोड्या लावूया!',
      ttsMarathiText: 'बेरीज आणि योग्य उत्तरांच्या जोड्या लावा',
      payloadData: {
        'level_id': 2,
        'beat_index': 4,
        'pairs': [
          {'a': '२ + १', 'b': '३'},
          {'a': '२ + २', 'b': '४'},
          {'a': '३ + २', 'b': '५'},
        ],
        'correct_answer': 'matched_all',
        'explanation_hint': 'प्रत्येक बेरजेचे योग्य उत्तर ओळखून जोडी लावा.',
      },
    ),
    QuestionCandidate(
      questionId: 'Q_GROVE_04_T3',
      skillId: 'MATH_ADD_01',
      difficultyTier: 3,
      questionType: 'match_following',
      coreLogicText: 'मोठ्या बेरजांच्या योग्य जोड्या लावा.',
      requiredBackdropId: 'bg_banyan_grove',
      requiredCharacterLottie: 'assets/lottie/Cute Tiger.json',
      requiredPropLottie: 'assets/lottie/cow.json',
      storyBridgeIntro: 'खूप छान! आता बागेतील आणि डेअरीतील गोष्टींच्या योग्य जोड्या लावूया!',
      ttsMarathiText: 'मोठ्या बेरजांच्या योग्य जोड्या लावा',
      payloadData: {
        'level_id': 2,
        'beat_index': 4,
        'pairs': [
          {'a': '४ + ३', 'b': '७'},
          {'a': '५ + ३', 'b': '८'},
          {'a': '५ + ४', 'b': '९'},
        ],
        'correct_answer': 'matched_all',
        'explanation_hint': 'मोठ्या संख्यांची बेरीज करून योग्य जोडी लावा.',
      },
    ),

    // -------------------------------------------------------------------------
    // LEVEL 3: "गावाचा आठवडी बाजार" (Village Weekly Market) - 12 Candidates (4 Beats x 3 Tiers)
    // -------------------------------------------------------------------------
    // Beat 1: Setting Up the Village Food Stall (Visual: food stall.json / fruit_basket.json / farmer_waving.json / bicycle.json)
    QuestionCandidate(
      questionId: 'Q_MKT_01_T1',
      skillId: 'MATH_MARKET_SUB_01',
      difficultyTier: 1,
      questionType: 'spot_item',
      coreLogicText: 'बाजारातील खाऊचे आणि फळांचे दुकान कुठे आहे? त्या चमकणाऱ्या दुकानावर टॅप कर!',
      requiredBackdropId: 'bg_village_market',
      requiredCharacterLottie: 'assets/lottie/farmer_waving.json',
      requiredPropLottie: 'assets/lottie/food stall.json',
      storyBridgeIntro: 'आज गावात आठवडी बाजार भरला आहे! शेतकरी दादांनी ताज्या फळांचे आणि खाऊचे दुकान लावले आहे. चला, बाजारातील मुख्य दुकान शोधूया!',
      ttsMarathiText: 'बाजारातील खाऊचे आणि फळांचे दुकान कुठे आहे त्या चमकणाऱ्या दुकानावर टॅप कर',
      payloadData: {
        'level_id': 3,
        'beat_index': 1,
        'target_asset': 'prop_food_stall',
        'correct_answer': 'खाऊचे दुकान',
        'explanation_hint': 'समोर दिसणारे खाऊचे आणि फळांचे चमकणारे दुकान पहा.',
        'english_text': 'Where is the village food stall? Tap on the glowing stall!',
        'wrong_feedback_marathi': 'तिथे नाही! समोर दिसणाऱ्या खाऊच्या दुकानावर टॅप कर!',
        'wrong_feedback_english': 'Not there! Tap on the food stall!',
      },
    ),
    QuestionCandidate(
      questionId: 'Q_MKT_01_T2',
      skillId: 'MATH_MARKET_SUB_01',
      difficultyTier: 2,
      questionType: 'spot_item',
      coreLogicText: 'दुकानाजवळ उभे राहून हात हलवणारे शेतकरी दादा आणि त्यांचे दुकान शोधा व टॅप करा!',
      requiredBackdropId: 'bg_village_market',
      requiredCharacterLottie: 'assets/lottie/farmer_waving.json',
      requiredPropLottie: 'assets/lottie/food stall.json',
      storyBridgeIntro: 'आज गावात आठवडी बाजार भरला आहे! शेतकरी दादांनी ताज्या फळांचे आणि खाऊचे दुकान लावले आहे. चला, बाजारातील मुख्य दुकान शोधूया!',
      ttsMarathiText: 'दुकानाजवळ उभे राहून हात हलवणारे शेतकरी दादा आणि त्यांचे दुकान शोधा व टॅप करा',
      payloadData: {
        'level_id': 3,
        'beat_index': 1,
        'target_asset': 'prop_food_stall',
        'correct_answer': 'खाऊचे दुकान',
        'explanation_hint': 'शेतकरी दादांच्या शेजारी असलेले दुकान पहा.',
        'english_text': 'Spot the food stall where the waving farmer is standing and tap it!',
        'wrong_feedback_marathi': 'तिथे नाही! समोर दिसणाऱ्या खाऊच्या दुकानावर टॅप कर!',
        'wrong_feedback_english': 'Not there! Tap on the food stall!',
      },
    ),
    QuestionCandidate(
      questionId: 'Q_MKT_01_T3',
      skillId: 'MATH_MARKET_SUB_01',
      difficultyTier: 3,
      questionType: 'spot_item',
      coreLogicText: 'ज्या दुकानात फळांची टोपली ठेवली आहे, त्या आठवडी बाजाराच्या दुकानावर टॅप करा!',
      requiredBackdropId: 'bg_village_market',
      requiredCharacterLottie: 'assets/lottie/farmer_waving.json',
      requiredPropLottie: 'assets/lottie/food stall.json',
      storyBridgeIntro: 'आज गावात आठवडी बाजार भरला आहे! शेतकरी दादांनी ताज्या फळांचे आणि खाऊचे दुकान लावले आहे. चला, बाजारातील मुख्य दुकान शोधूया!',
      ttsMarathiText: 'ज्या दुकानात फळांची टोपली ठेवली आहे त्या आठवडी बाजाराच्या दुकानावर टॅप करा',
      payloadData: {
        'level_id': 3,
        'beat_index': 1,
        'target_asset': 'prop_food_stall',
        'correct_answer': 'खाऊचे दुकान',
        'explanation_hint': 'फळांची टोपली ठेवलेले सुंदर दुकान पहा.',
        'english_text': 'Tap on the market stall where the fresh fruit basket is kept!',
        'wrong_feedback_marathi': 'तिथे नाही! समोर दिसणाऱ्या खाऊच्या दुकानावर टॅप कर!',
        'wrong_feedback_english': 'Not there! Tap on the food stall!',
      },
    ),

    // Beat 2: Weighing Fruits on the Scale & Market Subtraction (Visual: fruit_basket.json vs milk / piggy_bank)
    QuestionCandidate(
      questionId: 'Q_MKT_02_T1',
      skillId: 'MATH_MARKET_SUB_01',
      difficultyTier: 1,
      questionType: 'fill_blanks',
      coreLogicText: 'तराजूवर ठेवल्यास कोणती गोष्ट जास्त जड आणि मोठी भरेल — पूर्ण भरलेली फळांची टोपली की एक छोटा दुधाचा डबा?',
      requiredBackdropId: 'bg_village_market',
      requiredCharacterLottie: 'assets/lottie/farmer_waving.json',
      requiredPropLottie: 'assets/lottie/weighing_scale.json',
      storyBridgeIntro: 'शेतकरी दादांनी तराजू काढला आहे! आता आपण फळांची टोपली आणि दुधाचे डबे मोजूया आणि कोणती वस्तू जड किंवा जास्त आहे ते पाहूया!',
      ttsMarathiText: 'तराजूवर ठेवल्यास कोणती गोष्ट जास्त जड भरेल पूर्ण भरलेली फळांची टोपली की छोटा दुधाचा डबा',
      payloadData: {
        'level_id': 3,
        'beat_index': 2,
        'options': ['फळांची टोपली', 'दुधाचा डबा'],
        'correct_answer': 'फळांची टोपली',
        'explanation_hint': 'पूर्ण भरलेल्या फळांच्या टोपलीचे वजन एका दुधाच्या डब्यापेक्षा जास्त असते!',
        'english_text': 'On the weighing scale, which is heavier — the full Fruit Basket or a single Milk Carton? Tap your answer.',
        'correct_feedback_marathi': 'फळांची टोपली जड आहे!',
        'correct_feedback_english': 'Yes! The fruit basket is heavier.',
        'wrong_feedback_marathi': 'दुधाचा डबा हलका आहे! जड वस्तू कोणती ते पुन्हा निवड!',
        'wrong_feedback_english': 'The milk can is lighter. Tap the fruit basket!',
      },
    ),
    QuestionCandidate(
      questionId: 'Q_MKT_02_T2',
      skillId: 'MATH_MARKET_SUB_01',
      difficultyTier: 2,
      questionType: 'fill_blanks',
      coreLogicText: 'टोपलीत ६ फळे होती, त्यातील २ फळे विकली गेली (६ - २ = ४). आणि दुधाचे २ डबे आहेत. आता कोणती वस्तू जास्त उरली आहे?',
      requiredBackdropId: 'bg_village_market',
      requiredCharacterLottie: 'assets/lottie/farmer_waving.json',
      requiredPropLottie: 'assets/lottie/weighing_scale.json',
      storyBridgeIntro: 'शेतकरी दादांनी तराजू काढला आहे! आता आपण फळांची टोपली आणि दुधाचे डबे मोजूया आणि कोणती वस्तू जड किंवा जास्त आहे ते पाहूया!',
      ttsMarathiText: 'टोपलीत सहा फळे होती दोन विकली चार उरली आणि दुधाचे दोन डबे आहेत कोणती वस्तू जास्त उरली आहे',
      payloadData: {
        'level_id': 3,
        'beat_index': 2,
        'options': ['फळांची टोपली (४)', 'दुधाचे डबे (२)'],
        'correct_answer': 'फळांची टोपली (४)',
        'explanation_hint': '४ फळे ही २ दुधाच्या डब्यांपेक्षा जास्त आहेत (४ > २).',
        'english_text': 'The basket had 6 fruits and 2 were sold (6 - 2 = 4 left). There are 2 milk cartons. Which has MORE left now?',
        'correct_feedback_marathi': 'टोपलीत ४ फळे जास्त उरली आहेत!',
        'correct_feedback_english': 'Yes! 4 fruits are more than 2 milk cans.',
        'wrong_feedback_marathi': 'दुधाचे फक्त २ डबे आहेत! जास्त संख्या कोणती ते पुन्हा निवड!',
        'wrong_feedback_english': 'There are only 2 milk cans. Tap the fruits (4)!',
      },
    ),
    QuestionCandidate(
      questionId: 'Q_MKT_02_T3',
      skillId: 'MATH_MARKET_SUB_01',
      difficultyTier: 3,
      questionType: 'fill_blanks',
      coreLogicText: 'दुकानात ८ फळांच्या टोपल्या होत्या, त्यातील ३ विकल्या गेल्या (८ - ३ = ५). आणि दुधाचे ४ डबे आहेत. आता कोणाची संख्या जास्त आहे?',
      requiredBackdropId: 'bg_village_market',
      requiredCharacterLottie: 'assets/lottie/farmer_waving.json',
      requiredPropLottie: 'assets/lottie/weighing_scale.json',
      storyBridgeIntro: 'शेतकरी दादांनी तराजू काढला आहे! आता आपण फळांची टोपली आणि दुधाचे डबे मोजूया आणि कोणती वस्तू जड किंवा जास्त आहे ते पाहूया!',
      ttsMarathiText: 'दुकानात आठ टोपल्या होत्या तीन विकल्या पाच उरल्या आणि दुधाचे चार डबे आहेत कोणाची संख्या जास्त आहे',
      payloadData: {
        'level_id': 3,
        'beat_index': 2,
        'options': ['फळांची टोपली (५)', 'दुधाचे डबे (४)'],
        'correct_answer': 'फळांची टोपली (५)',
        'explanation_hint': '५ टोपल्या या ४ डब्यांपेक्षा जास्त आहेत (५ > ४).',
        'english_text': 'There were 8 fruit baskets and 3 were sold (8 - 3 = 5 left). There are 4 milk cartons. Which item has more left?',
        'correct_feedback_marathi': '५ टोपल्या जास्त आहेत!',
        'correct_feedback_english': 'Yes! 5 fruit baskets are more than 4 milk cans.',
        'wrong_feedback_marathi': 'दुधाचे ४ डबे कमी आहेत! ५ टोपल्या जास्त आहेत, पुन्हा निवड!',
        'wrong_feedback_english': '4 is less than 5. Tap the fruit baskets (5)!',
      },
    ),

    // Beat 3: Counting Coins for the Piggy Bank with the Waving Farmer (Visual: farmer_waving.json / piggy_bank.json)
    QuestionCandidate(
      questionId: 'Q_MKT_03_T1',
      skillId: 'MATH_MARKET_SUB_01',
      difficultyTier: 1,
      questionType: 'voice_input',
      coreLogicText: 'पिगी बँकेत ४ नाणी आहेत. माईक दाबून स्पष्ट आवाजात म्हण: "चार" किंवा "Four"!',
      requiredBackdropId: 'bg_village_market',
      requiredCharacterLottie: 'assets/lottie/farmer_waving.json',
      requiredPropLottie: 'assets/lottie/piggy_bank.json',
      storyBridgeIntro: 'विक्रीतून मिळालेले नाणे आता आपण पिगी बँकेत टाकणार आहोत! शेतकरी दादा विचारत आहेत की किती नाणी झाली? चला माईकमध्ये उत्तर बोलून सांगूया!',
      ttsMarathiText: 'पिगी बँकेत चार नाणी आहेत माईक दाबून स्पष्ट आवाजात चार किंवा फोर म्हणा',
      payloadData: {
        'level_id': 3,
        'beat_index': 3,
        'expected_phrase': 'चार',
        'alternatives': ['4', '४', 'char', 'chaar', 'four', 'Four', 'चार नाणी'],
        'correct_answer': 'चार',
        'explanation_hint': 'माईक दाबून स्पष्ट म्हणा: "चार".',
      },
    ),
    QuestionCandidate(
      questionId: 'Q_MKT_03_T2',
      skillId: 'MATH_MARKET_SUB_01',
      difficultyTier: 2,
      questionType: 'voice_input',
      coreLogicText: 'आधी ३ नाणी होती आणि शेतकरी दादांनी आणखी २ नाणी दिली (३ + २ = ५). माईकमध्ये "पाच" किंवा "Five" बोल!',
      requiredBackdropId: 'bg_village_market',
      requiredCharacterLottie: 'assets/lottie/farmer_waving.json',
      requiredPropLottie: 'assets/lottie/piggy_bank.json',
      storyBridgeIntro: 'विक्रीतून मिळालेले नाणे आता आपण पिगी बँकेत टाकणार आहोत! शेतकरी दादा विचारत आहेत की किती नाणी झाली? चला माईकमध्ये उत्तर बोलून सांगूया!',
      ttsMarathiText: 'आधी तीन नाणी होती आणि शेतकरी दादांनी आणखी दोन नाणी दिली तीन अधिक दोन बरोबर पाच माईकमध्ये पाच किंवा फाईव्ह बोला',
      payloadData: {
        'level_id': 3,
        'beat_index': 3,
        'expected_phrase': 'पाच',
        'alternatives': ['5', '५', 'paach', 'pach', 'five', 'Five', 'पाच नाणी'],
        'correct_answer': 'पाच',
        'explanation_hint': 'तीन अधिक दोन बरोबर पाच होतात, म्हणा "पाच".',
      },
    ),
    QuestionCandidate(
      questionId: 'Q_MKT_03_T3',
      skillId: 'MATH_MARKET_SUB_01',
      difficultyTier: 3,
      questionType: 'voice_input',
      coreLogicText: 'पिगी बँकेत ९ नाणी होती, त्यातील ३ नाणी फळांसाठी दिली (९ - ३ = ६). माईकमध्ये "सहा" किंवा "Six" बोल!',
      requiredBackdropId: 'bg_village_market',
      requiredCharacterLottie: 'assets/lottie/farmer_waving.json',
      requiredPropLottie: 'assets/lottie/piggy_bank.json',
      storyBridgeIntro: 'विक्रीतून मिळालेले नाणे आता आपण पिगी बँकेत टाकणार आहोत! शेतकरी दादा विचारत आहेत की किती नाणी झाली? चला माईकमध्ये उत्तर बोलून सांगूया!',
      ttsMarathiText: 'पिगी बँकेत नऊ नाणी होती तीन फळांसाठी दिली नऊ वजा तीन बरोबर सहा माईकमध्ये सहा किंवा सिक्स बोला',
      payloadData: {
        'level_id': 3,
        'beat_index': 3,
        'expected_phrase': 'सहा',
        'alternatives': ['6', '६', 'saha', 'chhah', 'six', 'Six', 'सहा नाणी'],
        'correct_answer': 'सहा',
        'explanation_hint': 'नऊ वजा तीन बरोबर सहा होतात, म्हणा "सहा".',
      },
    ),

    // Beat 4: Market Day Wrap-Up Matching (Visual: Fruit Basket, Weighing Scale, Piggy Bank)
    QuestionCandidate(
      questionId: 'Q_MKT_04_T1',
      skillId: 'MATH_MARKET_SUB_01',
      difficultyTier: 1,
      questionType: 'match_following',
      coreLogicText: 'आठवडी बाजारातील वस्तू आणि त्यांच्या योग्य जोड्या जुळवा!',
      requiredBackdropId: 'bg_village_market',
      requiredCharacterLottie: 'assets/lottie/farmer_waving.json',
      requiredPropLottie: 'assets/lottie/fruit_basket.json',
      storyBridgeIntro: 'शाब्बास! आजचा आठवडी बाजार खूप छान झाला! आता बाजारातील सर्व वस्तू आणि त्यांच्या कामांच्या योग्य जोड्या जुळवूया!',
      ttsMarathiText: 'आठवडी बाजारातील वस्तू आणि त्यांच्या योग्य जोड्या जुळवा फळांची टोपली तराजू आणि पिगी बँक',
      payloadData: {
        'level_id': 3,
        'beat_index': 4,
        'pairs': [
          {'a': 'फळांची टोपली', 'b': 'ताजी फळे'},
          {'a': 'तराजू', 'b': 'वजन मोजणे'},
          {'a': 'पिगी बँक', 'b': 'पैसे वाचवणे'},
        ],
        'correct_answer': 'matched_all',
        'explanation_hint': 'टोपलीत फळे असतात, तराजूने वजन मोजतात, पिगी बँकेत पैसे वाचवतात.',
      },
    ),
    QuestionCandidate(
      questionId: 'Q_MKT_04_T2',
      skillId: 'MATH_MARKET_SUB_01',
      difficultyTier: 2,
      questionType: 'match_following',
      coreLogicText: 'आठवडी बाजारातील वस्तू आणि हिशोबाच्या योग्य जोड्या जुळवा!',
      requiredBackdropId: 'bg_village_market',
      requiredCharacterLottie: 'assets/lottie/farmer_waving.json',
      requiredPropLottie: 'assets/lottie/fruit_basket.json',
      storyBridgeIntro: 'शाब्बास! आजचा आठवडी बाजार खूप छान झाला! आता बाजारातील सर्व वस्तू आणि त्यांच्या कामांच्या योग्य जोड्या जुळवूया!',
      ttsMarathiText: 'आठवडी बाजारातील वस्तू आणि हिशोबाच्या योग्य जोड्या जुळवा शेतकरी दादा फळे आणि सायकल',
      payloadData: {
        'level_id': 3,
        'beat_index': 4,
        'pairs': [
          {'a': 'शेतकरी दादा', 'b': 'खाऊचे दुकान'},
          {'a': '६ - २ फळे', 'b': '४ फळे'},
          {'a': 'सायकलची चाके', 'b': '२ चाके'},
        ],
        'correct_answer': 'matched_all',
        'explanation_hint': 'शेतकरी दादांचे दुकान आहे, ६ वजा २ बरोबर ४ फळे, सायकलला २ चाके असतात.',
      },
    ),
    QuestionCandidate(
      questionId: 'Q_MKT_04_T3',
      skillId: 'MATH_MARKET_SUB_01',
      difficultyTier: 3,
      questionType: 'match_following',
      coreLogicText: 'आठवडी बाजारातील वस्तू आणि हिशोबाच्या योग्य जोड्या जुळवा!',
      requiredBackdropId: 'bg_village_market',
      requiredCharacterLottie: 'assets/lottie/farmer_waving.json',
      requiredPropLottie: 'assets/lottie/fruit_basket.json',
      storyBridgeIntro: 'शाब्बास! आजचा आठवडी बाजार खूप छान झाला! आता बाजारातील सर्व वस्तू आणि त्यांच्या कामांच्या योग्य जोड्या जुळवूया!',
      ttsMarathiText: 'आठवडी बाजारातील वस्तू आणि हिशोबाच्या योग्य जोड्या जुळवा आठ वजा तीन पाच अधिक चार आणि तराजू',
      payloadData: {
        'level_id': 3,
        'beat_index': 4,
        'pairs': [
          {'a': '८ - ३ फळे', 'b': '५ फळे'},
          {'a': '५ + ४ नाणी', 'b': '९ नाणी'},
          {'a': 'तराजूचे पारडे', 'b': '२ पारडी'},
        ],
        'correct_answer': 'matched_all',
        'explanation_hint': '८ वजा ३ बरोबर ५ फळे, ५ अधिक ४ बरोबर ९ नाणी, तराजूला २ पारडी असतात.',
      },
    ),

    // -------------------------------------------------------------------------
    // LEVEL 4: "गावाची शाळा आणि जत्रा" (Village School & Fair) - 12 Candidates (4 Beats x 3 Tiers)
    // -------------------------------------------------------------------------
    // Beat 1: Catching the School Bus & Packing the School Bag (spot_item)
    QuestionCandidate(
      questionId: 'Q_SCH_01_T1',
      skillId: 'MATH_SHAPES_ZERO_01',
      difficultyTier: 1,
      questionType: 'spot_item',
      coreLogicText: 'आपल्याला शाळेत नेणारी पिवळी बस कुठे आहे? चमकणाऱ्या बसवर टॅप कर!',
      requiredBackdropId: 'bg_village_school',
      requiredCharacterLottie: 'assets/lottie/Hand Waving Animation.json',
      requiredPropLottie: 'assets/lottie/bus.json',
      storyBridgeIntro: 'बाजारानंतर आता शाळेची वेळ झाली आहे! चिंटूने दप्तर पाठीवर घेतले आहे आणि पिवळी शाळेची बस आली आहे. चला, आधी शाळेची बस किंवा दप्तर शोधूया!',
      ttsMarathiText: 'आपल्याला शाळेत नेणारी पिवळी बस कुठे आहे चमकणाऱ्या बसवर टॅप कर',
      payloadData: {
        'level_id': 4,
        'beat_index': 1,
        'target_asset': 'prop_bus',
        'correct_answer': 'शाळेची बस',
        'english_text': 'Where is the school bus taking us to school? Tap on the glowing bus!',
        'explanation_hint': 'रस्त्यावर थांबलेली पिवळी शाळेची बस पहा.',
        'wrong_feedback_marathi': 'तिथे नाही! रस्त्यावर उभ्या असलेल्या शाळेच्या बसवर टॅप कर!',
        'wrong_feedback_english': 'Not there! Tap on the school bus waiting on the road!',
      },
    ),
    QuestionCandidate(
      questionId: 'Q_SCH_01_T2',
      skillId: 'MATH_SHAPES_ZERO_01',
      difficultyTier: 2,
      questionType: 'spot_item',
      coreLogicText: 'बसच्या जवळ ठेवलेले चिंटूचे शाळेचे दप्तर किंवा बस शोधा आणि टॅप करा!',
      requiredBackdropId: 'bg_village_school',
      requiredCharacterLottie: 'assets/lottie/Hand Waving Animation.json',
      requiredPropLottie: 'assets/lottie/bus.json',
      storyBridgeIntro: 'बाजारानंतर आता शाळेची वेळ झाली आहे! चिंटूने दप्तर पाठीवर घेतले आहे आणि पिवळी शाळेची बस आली आहे. चला, आधी शाळेची बस किंवा दप्तर शोधूया!',
      ttsMarathiText: 'बसच्या जवळ ठेवलेले चिंटूचे शाळेचे दप्तर किंवा बस शोधा आणि टॅप करा',
      payloadData: {
        'level_id': 4,
        'beat_index': 1,
        'target_asset': 'prop_bus',
        'correct_answer': 'शाळेची बस',
        'english_text': "Spot Chintu's school bus and school bag waiting on the road and tap!",
        'explanation_hint': 'रस्त्यावर शाळेचे दप्तर आणि बस पहा.',
        'wrong_feedback_marathi': 'तिथे नाही! रस्त्यावरील शाळेच्या बसवर टॅप करा!',
        'wrong_feedback_english': 'Not there! Tap on the school bus on the road!',
      },
    ),
    QuestionCandidate(
      questionId: 'Q_SCH_01_T3',
      skillId: 'MATH_SHAPES_ZERO_01',
      difficultyTier: 3,
      questionType: 'spot_item',
      coreLogicText: 'ज्या गाडीची चाके वर्तुळाकार (गोल) आहेत, त्या मोठ्या शाळेच्या बसवर टॅप करा!',
      requiredBackdropId: 'bg_village_school',
      requiredCharacterLottie: 'assets/lottie/Hand Waving Animation.json',
      requiredPropLottie: 'assets/lottie/bus.json',
      storyBridgeIntro: 'बाजारानंतर आता शाळेची वेळ झाली आहे! चिंटूने दप्तर पाठीवर घेतले आहे आणि पिवळी शाळेची बस आली आहे. चला, आधी शाळेची बस किंवा दप्तर शोधूया!',
      ttsMarathiText: 'ज्या गाडीची चाके वर्तुळाकार गोल आहेत त्या मोठ्या शाळेच्या बसवर टॅप करा',
      payloadData: {
        'level_id': 4,
        'beat_index': 1,
        'target_asset': 'prop_bus',
        'correct_answer': 'शाळेची बस',
        'english_text': 'Tap on the large school bus that has round circular wheels!',
        'explanation_hint': 'गोल चाके असलेली पिवळी शाळेची बस पहा.',
        'wrong_feedback_marathi': 'तिथे नाही! गोल चाके असलेल्या शाळेच्या बसवर टॅप करा!',
        'wrong_feedback_english': 'Not there! Tap on the school bus with circular wheels!',
      },
    ),

    // Beat 2: Learning 2D Shapes in Classroom (fill_blanks)
    QuestionCandidate(
      questionId: 'Q_SCH_02_T1',
      skillId: 'MATH_SHAPES_ZERO_01',
      difficultyTier: 1,
      questionType: 'fill_blanks',
      coreLogicText: 'बसच्या चाकासारखा पूर्ण गोल असलेला "वर्तुळ" (Circle) आकार कोणता आहे? योग्य कार्डावर टॅप कर!',
      requiredBackdropId: 'bg_village_school',
      requiredCharacterLottie: 'assets/lottie/Robot says hello.json',
      requiredPropLottie: 'assets/lottie/circle.json',
      storyBridgeIntro: 'चिंटू आणि नोव्हा वर्गात पोहोचले! आज गुरुजी फळ्यावर विविध आकार शिकवत आहेत — वर्तुळ, त्रिकोण, चौकोन आणि आयत! चला योग्य आकार ओळखूया!',
      ttsMarathiText: 'बसच्या चाकासारखा पूर्ण गोल असलेला वर्तुळ आकार कोणता आहे योग्य कार्डावर टॅप कर',
      payloadData: {
        'level_id': 4,
        'beat_index': 2,
        'options': ['वर्तुळ / Circle', 'त्रिकोण / Triangle'],
        'correct_answer': 'वर्तुळ / Circle',
        'option_lotties': ['assets/lottie/circle.json', 'assets/lottie/triangle.json'],
        'english_text': 'Which shape is completely round like a bus wheel — Circle or Triangle? Tap your answer.',
        'explanation_hint': 'वर्तुळ पूर्णपणे गोल असते, त्याला एकही कोपरा नसतो.',
        'correct_feedback_marathi': 'शाब्बास! वर्तुळ बसच्या चाकासारखे गोल असते!',
        'correct_feedback_english': 'Awesome! The circle is round like a wheel!',
        'wrong_feedback_marathi': 'त्रिकोणाला ३ कोपरे असतात! गोल वर्तुळावर टॅप कर!',
        'wrong_feedback_english': 'A triangle has 3 corners! Tap the round circle!',
      },
    ),
    QuestionCandidate(
      questionId: 'Q_SCH_02_T2',
      skillId: 'MATH_SHAPES_ZERO_01',
      difficultyTier: 2,
      questionType: 'fill_blanks',
      coreLogicText: 'ज्या आकाराला फक्त ३ कोपरे आणि ३ बाजू असतात (समोशासारखा), तो "त्रिकोण" कोणता आहे?',
      requiredBackdropId: 'bg_village_school',
      requiredCharacterLottie: 'assets/lottie/Robot says hello.json',
      requiredPropLottie: 'assets/lottie/triangle.json',
      storyBridgeIntro: 'चिंटू आणि नोव्हा वर्गात पोहोचले! आज गुरुजी फळ्यावर विविध आकार शिकवत आहेत — वर्तुळ, त्रिकोण, चौकोन आणि आयत! चला योग्य आकार ओळखूया!',
      ttsMarathiText: 'ज्या आकाराला फक्त तीन कोपरे आणि तीन बाजू असतात तो त्रिकोण कोणता आहे',
      payloadData: {
        'level_id': 4,
        'beat_index': 2,
        'options': ['त्रिकोण (३ कोपरे) / Triangle', 'चौकोन (४ कोपरे) / Square'],
        'correct_answer': 'त्रिकोण (३ कोपरे) / Triangle',
        'option_lotties': ['assets/lottie/triangle.json', 'assets/lottie/square.json'],
        'english_text': 'Which shape has exactly 3 corners and 3 sides — Triangle or Square?',
        'explanation_hint': 'त्रिकोणाला ३ बाजू आणि ३ कोपरे असतात.',
        'correct_feedback_marathi': 'अगदी बरोबर! त्रिकोणाला ३ कोपरे आणि ३ बाजू असतात!',
        'correct_feedback_english': 'Correct! A triangle has 3 corners and 3 sides!',
        'wrong_feedback_marathi': 'चौकोनाला ४ कोपरे असतात! ३ कोपरे असलेल्या त्रिकोणावर टॅप कर!',
        'wrong_feedback_english': 'A square has 4 corners! Tap the triangle with 3 corners!',
      },
    ),
    QuestionCandidate(
      questionId: 'Q_SCH_02_T3',
      skillId: 'MATH_SHAPES_ZERO_01',
      difficultyTier: 3,
      questionType: 'fill_blanks',
      coreLogicText: 'आपल्या दप्तरातील पुस्तकासारखा आणि फळ्यासारखा ४ बाजू असलेला "आयत" (Rectangle) आकार कोणता आहे?',
      requiredBackdropId: 'bg_village_school',
      requiredCharacterLottie: 'assets/lottie/Robot says hello.json',
      requiredPropLottie: 'assets/lottie/rectangle.json',
      storyBridgeIntro: 'चिंटू आणि नोव्हा वर्गात पोहोचले! आज गुरुजी फळ्यावर विविध आकार शिकवत आहेत — वर्तुळ, त्रिकोण, चौकोन आणि आयत! चला योग्य आकार ओळखूया!',
      ttsMarathiText: 'आपल्या दप्तरातील पुस्तकासारखा आणि फळ्यासारखा चार बाजू असलेला आयत आकार कोणता आहे',
      payloadData: {
        'level_id': 4,
        'beat_index': 2,
        'options': ['आयत (४ बाजू) / Rectangle', 'वर्तुळ (० कोपरे) / Circle'],
        'correct_answer': 'आयत (४ बाजू) / Rectangle',
        'option_lotties': ['assets/lottie/rectangle.json', 'assets/lottie/circle.json'],
        'english_text': 'Which shape has 4 sides with opposite sides equal like a school board — Rectangle or Circle?',
        'explanation_hint': 'आयताला ४ बाजू आणि समोरासमोरील समान बाजू असतात.',
        'correct_feedback_marathi': 'खूप छान! फळ्यासारखा आकार आयत असतो!',
        'correct_feedback_english': 'Great job! The school board has a rectangular shape!',
        'wrong_feedback_marathi': 'वर्तुळाला कोपरे नसतात! ४ बाजू असलेल्या आयतावर टॅप करा!',
        'wrong_feedback_english': 'A circle has no corners! Tap the rectangle with 4 sides!',
      },
    ),

    // Beat 3: Evening Village Fair - Balloons, Ferris Wheel & Concept of Zero (voice_input)
    QuestionCandidate(
      questionId: 'Q_SCH_03_T1',
      skillId: 'MATH_SHAPES_ZERO_01',
      difficultyTier: 1,
      questionType: 'voice_input',
      coreLogicText: 'आकाशपाळण्याजवळ १० रंगीबेरंगी फुगे आहेत! माईक दाबून जोरात म्हण: "दहा" किंवा "Ten"!',
      requiredBackdropId: 'bg_village_school',
      requiredCharacterLottie: 'assets/lottie/Hand Waving Animation.json',
      requiredPropLottie: 'assets/lottie/ferris_wheel.json',
      storyBridgeIntro: 'शाळा सुटल्यावर संध्याकाळी गावात जत्रा भरली आहे! तिथे मोठा आकाशपाळणा फिरत आहे आणि रंगीबेरंगी फुगे उडत आहेत! चला माईकमध्ये उत्तर बोलून सांगूया!',
      ttsMarathiText: 'आकाशपाळण्याजवळ दहा रंगीबेरंगी फुगे आहेत माईक दाबून जोरात दहा किंवा टेन म्हणा',
      payloadData: {
        'level_id': 4,
        'beat_index': 3,
        'expected_phrase': 'दहा',
        'alternatives': ['10', '१०', 'daha', 'das', 'ten', 'Ten', 'दहा फुगे'],
        'correct_answer': 'दहा',
        'english_text': 'There are 10 colorful balloons near the Ferris wheel! Tap the mic and say "Daha" or "Ten"!',
        'explanation_hint': 'माईक दाबून स्पष्ट म्हणा: "दहा".',
      },
    ),
    QuestionCandidate(
      questionId: 'Q_SCH_03_T2',
      skillId: 'MATH_SHAPES_ZERO_01',
      difficultyTier: 2,
      questionType: 'voice_input',
      coreLogicText: 'चिंटूकडे ३ फुगे होते आणि तिन्ही फुगे आकाशात उडून गेले (३ - ३ = ०)! आता किती फुगे उरले? माईकमध्ये "शून्य" किंवा "Zero" बोल!',
      requiredBackdropId: 'bg_village_school',
      requiredCharacterLottie: 'assets/lottie/Hand Waving Animation.json',
      requiredPropLottie: 'assets/lottie/balloons.json',
      storyBridgeIntro: 'शाळा सुटल्यावर संध्याकाळी गावात जत्रा भरली आहे! तिथे मोठा आकाशपाळणा फिरत आहे आणि रंगीबेरंगी फुगे उडत आहेत! चला माईकमध्ये उत्तर बोलून सांगूया!',
      ttsMarathiText: 'चिंटूकडे तीन फुगे होते आणि तिन्ही फुगे उडून गेले आता किती फुगे उरले माईकमध्ये शून्य किंवा झिरो बोल',
      payloadData: {
        'level_id': 4,
        'beat_index': 3,
        'expected_phrase': 'शून्य',
        'alternatives': ['0', '०', 'shunya', 'shoonya', 'zero', 'Zero', 'शून्य फुगे'],
        'correct_answer': 'शून्य',
        'english_text': 'Chintu had 3 balloons and all 3 flew away (3 - 3 = 0)! Speak "Shunya" or "Zero" into the mic!',
        'explanation_hint': 'सर्व फुगे उडून गेल्यावर काहीच उरत नाही, म्हणजे "शून्य"!',
      },
    ),
    QuestionCandidate(
      questionId: 'Q_SCH_03_T3',
      skillId: 'MATH_SHAPES_ZERO_01',
      difficultyTier: 3,
      questionType: 'voice_input',
      coreLogicText: 'आकाशपाळण्यात ६ मुले बसली आहेत आणि आणखी ४ मुले आली (६ + ४ = १०). माईकमध्ये "दहा" किंवा "Ten" बोल!',
      requiredBackdropId: 'bg_village_school',
      requiredCharacterLottie: 'assets/lottie/Hand Waving Animation.json',
      requiredPropLottie: 'assets/lottie/ferris_wheel.json',
      storyBridgeIntro: 'शाळा सुटल्यावर संध्याकाळी गावात जत्रा भरली आहे! तिथे मोठा आकाशपाळणा फिरत आहे आणि रंगीबेरंगी फुगे उडत आहेत! चला माईकमध्ये उत्तर बोलून सांगूया!',
      ttsMarathiText: 'आकाशपाळण्यात सहा मुले बसली आहेत आणि आणखी चार मुले आली माईकमध्ये दहा किंवा टेन बोल',
      payloadData: {
        'level_id': 4,
        'beat_index': 3,
        'expected_phrase': 'दहा',
        'alternatives': ['10', '१०', 'daha', 'das', 'ten', 'Ten', 'दहा मुले'],
        'correct_answer': 'दहा',
        'english_text': '6 kids on the Ferris wheel plus 4 more kids equal 10! Tap the mic and say "Daha" or "Ten"!',
        'explanation_hint': '६ अधिक ४ बरोबर १० मुले! माईकमध्ये "दहा" म्हणा.',
      },
    ),

    // Beat 4: Class 1 Grand Finale Matching (match_following)
    QuestionCandidate(
      questionId: 'Q_SCH_04_T1',
      skillId: 'MATH_SHAPES_ZERO_01',
      difficultyTier: 1,
      questionType: 'match_following',
      coreLogicText: 'शाळा, आकार आणि जत्रेतील गोष्टींच्या योग्य जोड्या जुळवा!',
      requiredBackdropId: 'bg_village_school',
      requiredCharacterLottie: 'assets/lottie/Robot says hello.json',
      requiredPropLottie: 'assets/lottie/trophy.json',
      storyBridgeIntro: 'अप्रतिम! तुम्ही इयत्ता पहिलीचा शेवटचा टप्पा पूर्ण करत आहात! आता शाळा, आकार आणि जत्रेतील गोष्टींच्या योग्य जोड्या जुळवा आणि विजेता चषक जिंका!',
      ttsMarathiText: 'शाळा आकार आणि जत्रेतील गोष्टींच्या योग्य जोड्या जुळवा शाळेची बस आकाशपाळणा आणि रंगीबेरंगी फुगे',
      payloadData: {
        'level_id': 4,
        'beat_index': 4,
        'pairs': [
          {'a': 'शाळेची बस', 'b': 'शाळा'},
          {'a': 'आकाशपाळणा', 'b': 'जत्रा'},
          {'a': 'रंगीबेरंगी फुगे', 'b': 'आकाश'},
        ],
        'correct_answer': 'matched_all',
        'explanation_hint': 'बस शाळेत जाते, आकाशपाळणा जत्रेत असतो, फुगे आकाशात उडतात.',
      },
    ),
    QuestionCandidate(
      questionId: 'Q_SCH_04_T2',
      skillId: 'MATH_SHAPES_ZERO_01',
      difficultyTier: 2,
      questionType: 'match_following',
      coreLogicText: 'शाळा, आकार आणि जत्रेतील गोष्टींच्या योग्य जोड्या जुळवा!',
      requiredBackdropId: 'bg_village_school',
      requiredCharacterLottie: 'assets/lottie/Robot says hello.json',
      requiredPropLottie: 'assets/lottie/trophy.json',
      storyBridgeIntro: 'अप्रतिम! तुम्ही इयत्ता पहिलीचा शेवटचा टप्पा पूर्ण करत आहात! आता शाळा, आकार आणि जत्रेतील गोष्टींच्या योग्य जोड्या जुळवा आणि विजेता चषक जिंका!',
      ttsMarathiText: 'शाळा आकार आणि जत्रेतील गोष्टींच्या योग्य जोड्या जुळवा वर्तुळ त्रिकोण आणि चौकोन',
      payloadData: {
        'level_id': 4,
        'beat_index': 4,
        'pairs': [
          {'a': 'वर्तुळ', 'b': 'गोल चाक'},
          {'a': 'त्रिकोण', 'b': '३ कोपरे'},
          {'a': 'चौकोन', 'b': '४ समान बाजू'},
        ],
        'correct_answer': 'matched_all',
        'explanation_hint': 'वर्तुळ चाकासारखे गोल असते, त्रिकोणाला ३ कोपरे असतात, चौकोनाला ४ समान बाजू असतात.',
      },
    ),
    QuestionCandidate(
      questionId: 'Q_SCH_04_T3',
      skillId: 'MATH_SHAPES_ZERO_01',
      difficultyTier: 3,
      questionType: 'match_following',
      coreLogicText: 'शाळा, आकार आणि जत्रेतील गोष्टींच्या योग्य जोड्या जुळवा!',
      requiredBackdropId: 'bg_village_school',
      requiredCharacterLottie: 'assets/lottie/Robot says hello.json',
      requiredPropLottie: 'assets/lottie/trophy.json',
      storyBridgeIntro: 'अप्रतिम! तुम्ही इयत्ता पहिलीचा शेवटचा टप्पा पूर्ण करत आहात! आता शाळा, आकार आणि जत्रेतील गोष्टींच्या योग्य जोड्या जुळवा आणि विजेता चषक जिंका!',
      ttsMarathiText: 'शाळा आकार आणि जत्रेतील गोष्टींच्या योग्य जोड्या जुळवा आयत पाच वजा पाच आणि विजेता बक्षीस',
      payloadData: {
        'level_id': 4,
        'beat_index': 4,
        'pairs': [
          {'a': 'आयत', 'b': 'शाळेचा फळा'},
          {'a': '५ - ५ फुगे', 'b': '० (शून्य)'},
          {'a': 'विजेता बक्षीस', 'b': 'चषक (Trophy)'},
        ],
        'correct_answer': 'matched_all',
        'explanation_hint': 'फळा आयताकार असतो, ५ वजा ५ बरोबर शून्य, अंतिम विजेता चषक जिंकतो.',
      },
    ),
  ];

  // ===========================================================================
  // 4. CATALOG QUERY HELPERS
  // ===========================================================================

  static SkillRecord? getSkillById(String skillId) {
    try {
      return skills.firstWhere((s) => s.skillId == skillId);
    } catch (_) {
      return null;
    }
  }

  static GameAssetRecord? getAssetById(String assetId) {
    try {
      return gameAssets.firstWhere((a) => a.assetId == assetId);
    } catch (_) {
      return null;
    }
  }

  static List<QuestionCandidate> getQuestionsBySkill(String skillId) {
    return questionCandidates.where((q) => q.skillId == skillId).toList();
  }

  static List<QuestionCandidate> getQuestionsByLevel(int levelId) {
    return questionCandidates.where((q) => q.payloadData['level_id'] == levelId).toList();
  }

  static List<QuestionCandidate> getQuestionsByTier(int tier) {
    return questionCandidates.where((q) => q.difficultyTier == tier).toList();
  }

  static QuestionCandidate? getQuestionForBeat({
    required int levelId,
    required int beatIndex,
    required int difficultyTier,
    bool shuffle = true,
  }) {
    final list = questionCandidates.where((q) =>
        (q.payloadData['level_id'] == levelId) &&
        (q.payloadData['beat_index'] == beatIndex) &&
        (q.difficultyTier == difficultyTier)).toList();
    if (list.isNotEmpty) {
      if (shuffle && list.length > 1) {
        list.shuffle(math.Random());
      }
      return list.first;
    }

    final fallbackList = questionCandidates.where((q) =>
        (q.payloadData['level_id'] == levelId) &&
        (q.payloadData['beat_index'] == beatIndex)).toList();
    if (fallbackList.isNotEmpty) {
      if (shuffle && fallbackList.length > 1) {
        fallbackList.shuffle(math.Random());
      }
      return fallbackList.first;
    }
    return null;
  }

  static String buildMarathiFillerBridge({
    required int levelId,
    required int fromBeat,
    required int toBeat,
    required bool gotPreviousCorrect,
  }) {
    if (levelId == 1) {
      if ((fromBeat == 1 && toBeat == 2) || (fromBeat == 2 && toBeat == 1)) {
        return gotPreviousCorrect
            ? 'शाब्बास! चिवताईचे गाणे ऐकून चिंटू जागा झाला. आता शेतात जाण्याची वेळ झाली! शेताबाहेर काय उभे आहे बघा!'
            : 'छान प्रयत्न! आता शेतात जाण्याची वेळ झाली. शेताबाहेर काय उभे आहे बघा!';
      } else if (fromBeat == 2 && toBeat == 3) {
        return gotPreviousCorrect
            ? 'फारच छान! चिंटू आता शाळेच्या वाटेवर निघाला. वाटेत त्याला नोव्हा भेटला! चला, त्यांना प्रेमाने नमस्कार करूया!'
            : 'काही हरकत नाही! आता चिंटू शाळेच्या वाटेवर निघाला. वाटेत त्याला नोव्हा भेटला! चला, त्यांना नमस्कार करूया!';
      } else if (fromBeat == 3 && toBeat == 4) {
        return gotPreviousCorrect
            ? 'शाब्बास! चिंटूने सकाळची सगळी कामे पूर्ण केली. आता आपण सकाळी पाहिलेल्या गोष्टींच्या जोड्या जुळवूया!'
            : 'छान शिकलास! आता आपण सकाळी पाहिलेल्या गोष्टींच्या सोप्या जोड्या जुळवूया!';
      }
    } else if (levelId == 2) {
      // Level 2
      if ((fromBeat == 1 && toBeat == 2) || (fromBeat == 2 && toBeat == 1)) {
        return gotPreviousCorrect
            ? 'खूप छान! वाघोबाला मदत केल्यावर चिंटू गावातील डेअरीमध्ये पोहोचला. तिथे कपिला गाय उभी आहे आणि ताजे दूध तयार आहे!'
            : 'छान प्रयत्न! वाघोबा म्हणाला काळजी करू नको. आता चिंटू डेअरीमध्ये पोहोचला. तिथे कपिला गाय उभी आहे!';
      } else if (fromBeat == 2 && toBeat == 3) {
        return gotPreviousCorrect
            ? 'शाब्बास! डेअरी काकांनी विचारले की आपल्याला किती दुधाचे डबे हवे आहेत! चला, माईकमध्ये आवाज देऊन उत्तर सांगूया!'
            : 'प्रयत्न छान होता! आता डेअरी काका विचारत आहेत आपल्याला किती दुधाचे डबे हवे आहेत! आवाज देऊन सांगूया!';
      } else if (fromBeat == 3 && toBeat == 4) {
        return gotPreviousCorrect
            ? 'खूप गोड आवाज! आता बागेतील आणि डेअरीतील गोष्टींच्या योग्य जोड्या लावूया!'
            : 'छान प्रयत्न! आता बागेतील आणि डेअरीतील सोप्या जोड्या लावूया!';
      }
    } else if (levelId == 3) {
      // Level 3: Village Weekly Market
      if ((fromBeat == 1 && toBeat == 2) || (fromBeat == 2 && toBeat == 1)) {
        return gotPreviousCorrect
            ? 'शाब्बास! शेतकरी दादांचे दुकान शोधले. आता ताज्या फळांचे वजन आणि मोजणी करूया!'
            : 'छान प्रयत्न! आता आपण शेतकरी दादांच्या दुकानातील फळे आणि दूध तराजूवर पाहूया!';
      } else if (fromBeat == 2 && toBeat == 3) {
        return gotPreviousCorrect
            ? 'फारच हुशार! आता विक्रीतून मिळालेली नाणी पिगी बँकेत मोजून ठेवूया. माईकमध्ये आवाज देऊन सांगा!'
            : 'काही हरकत नाही! आता आपण नाणी मोजूया आणि पिगी बँकेत ठेवूया. माईकमध्ये सांगा!';
      } else if (fromBeat == 3 && toBeat == 4) {
        return gotPreviousCorrect
            ? 'शाब्बास! आजचा आठवडी बाजार खूप छान झाला! आता बाजारातील वस्तू आणि हिशोबाच्या जोड्या जुळवूया!'
            : 'छान शिकलास! आता आपण आठवडी बाजारातील गोष्टींच्या सोप्या जोड्या जुळवूया!';
      }
    } else {
      // Level 4: Village School & Evening Fair
      if ((fromBeat == 1 && toBeat == 2) || (fromBeat == 2 && toBeat == 1)) {
        return gotPreviousCorrect
            ? 'शाब्बास! शाळेची बस वेळेवर सापडली. आता वर्गात गुरुजी शिकवत असलेले सुंदर आकार पाहूया!'
            : 'छान प्रयत्न! आता आपण वर्गात जाऊया आणि फळ्यावरील आकार शिकूया!';
      } else if (fromBeat == 2 && toBeat == 3) {
        return gotPreviousCorrect
            ? 'फारच हुशार! शाळा संपल्यावर संध्याकाळी जत्रा भरली आहे! चला, आकाशपाळणा आणि फुगे पाहूया!'
            : 'छान शिकलास! आता शाळा सुटली आहे आणि गावात जत्रा भरली आहे! चला जत्रेत जाऊया!';
      } else if (fromBeat == 3 && toBeat == 4) {
        return gotPreviousCorrect
            ? 'अप्रतिम आवाज! आता इयत्ता पहिलीच्या शेवटच्या अंतिम जोड्या जुळवा आणि विजेता चषक जिंका!'
            : 'छान प्रयत्न! आता आपण इयत्ता पहिलीचा अंतिम टप्पा जिंकूया!';
      }
    }
    return 'शाब्बास! चला पुढील सुंदर टप्पा सुरू करूया!';
  }

  // ===========================================================================
  // 5. SAMPLE GENERATED LEVEL CONTRACTS (Deterministic Seed Levels)
  // ===========================================================================

  /// Seed Level 1 Contract: "माझी सकाळ" (Level 1 Village Morning)
  static GeneratedLevelContract get level1VillageMorningContract {
    return GeneratedLevelContract(
      levelId: 'lvl_01_village_morning',
      levelTitle: 'पातळी १ • माझी सकाळ (My Village Morning)',
      theme: 'village_morning',
      scenes: [
        GeneratedSceneContract(
          sceneId: 6,
          narrativeText: 'सकाळ झाली! सूर्याची सोनेरी किरणे गावावर पडली आहेत. बघा, छतावर चिवताई गाणे गात आहे!',
          environment: SceneEnvironmentContract(
            backdrop: 'bg_village_morning',
            character: 'char_chintu',
            characterExpressionDefault: 'happy',
            prop: 'prop_bird',
          ),
          questionData: SceneQuestionContract(
            questionType: 'spot_item',
            originalQuestionId: 'Q_VILL_01_T1',
            storyQuestionText: 'छतावर कोण बसले आहे? गाणे गाणाऱ्या चिवताईला टॅप करा.',
            correctAnswer: 'चिवताई',
            explanationHint: 'घराच्या कौलारू छतावर बसलेली चिमणी पहा.',
            storyBridgeIntro: 'सकाळ झाली! सूर्याची सोनेरी किरणे गावावर पडली आहेत. बघा, छतावर चिवताई गाणे गात आहे!',
            ttsMarathiText: 'सकाळ झाली छतावर गाणे गाणाऱ्या चिवताईला टॅप करा',
          ),
        ),
        GeneratedSceneContract(
          sceneId: 7,
          narrativeText: 'चिवताईचे गाणे ऐकून चिंटू जागा झाला. आता शेतात जाण्याची वेळ झाली! शेताबाहेर काय उभे आहे बघा!',
          environment: SceneEnvironmentContract(
            backdrop: 'bg_village_morning',
            character: 'char_nova',
            characterExpressionDefault: 'curious',
            prop: 'prop_tractor',
          ),
          questionData: SceneQuestionContract(
            questionType: 'fill_blanks',
            originalQuestionId: 'Q_VILL_02_T1',
            storyQuestionText: 'ट्रॅक्टर आणि सायकलमध्ये मोठे वाहन कोणते? मोठे वाहन ओळखा.',
            options: ['ट्रॅक्टर', 'सायकल'],
            correctAnswer: 'ट्रॅक्टर',
            explanationHint: 'शेतात काम करणारे मोठे वाहन ट्रॅक्टर आहे.',
            storyBridgeIntro: 'चिवताईचे गाणे ऐकून चिंटू जागा झाला. आता शेतात जाण्याची वेळ झाली! शेताबाहेर काय उभे आहे बघा!',
            ttsMarathiText: 'ट्रॅक्टर आणि सायकलमध्ये मोठे वाहन कोणते मोठे वाहन ओळखा',
            payloadData: {
              'display_art': {'big': 'prop_tractor', 'small': 'bicycle'},
            },
          ),
        ),
        GeneratedSceneContract(
          sceneId: 8,
          narrativeText: 'सकाळ झाली! सूर्याची सोनेरी किरणे गावावर पडली आहेत. बघा, छतावर चिवताई गाणे गात आहे!',
          environment: SceneEnvironmentContract(
            backdrop: 'bg_village_morning',
            character: 'char_chintu',
            characterExpressionDefault: 'joyful',
            prop: 'prop_bird',
          ),
          questionData: SceneQuestionContract(
            questionType: 'spot_item',
            originalQuestionId: 'Q_VILL_01_T1',
            storyQuestionText: 'छतावर कोण बसले आहे? गाणे गाणाऱ्या चिवताईला टॅप करा.',
            correctAnswer: 'चिवताई',
            explanationHint: 'घराच्या कौलारू छतावर बसलेली चिमणी पहा.',
            storyBridgeIntro: 'सकाळ झाली! सूर्याची सोनेरी किरणे गावावर पडली आहेत. बघा, छतावर चिवताई गाणे गात आहे!',
            ttsMarathiText: 'सकाळ झाली छतावर गाणे गाणाऱ्या चिवताईला टॅप करा',
          ),
        ),
        GeneratedSceneContract(
          sceneId: 9,
          narrativeText: 'चिंटू आता शाळेच्या वाटेवर निघाला. वाटेत त्याला NOVA भेटला! चला, त्यांना प्रेमाने नमस्कार करूया!',
          environment: SceneEnvironmentContract(
            backdrop: 'bg_village_morning',
            character: 'char_chintu',
            characterExpressionDefault: 'greeting',
            prop: 'char_nova',
          ),
          questionData: SceneQuestionContract(
            questionType: 'voice_input',
            originalQuestionId: 'Q_VILL_03_T1',
            storyQuestionText: 'मित्राला भेटल्यावर काय म्हणायचे? माईकमध्ये "शुभ प्रभात" बोला.',
            correctAnswer: 'शुभ प्रभात',
            explanationHint: 'माईक दाबून स्पष्ट आवाजात "शुभ प्रभात" म्हणा.',
            storyBridgeIntro: 'चिंटू आता शाळेच्या वाटेवर निघाला. वाटेत त्याला NOVA भेटला! चला, त्यांना प्रेमाने नमस्कार करूया!',
            ttsMarathiText: 'मित्राला भेटल्यावर काय म्हणायचे माईकमध्ये शुभ प्रभात बोला',
            payloadData: {
              'expected_phrase': 'शुभ प्रभात',
              'alternatives': ['सुप्रभात', 'Good Morning', 'शुभप्रभात'],
            },
          ),
        ),
        GeneratedSceneContract(
          sceneId: 10,
          narrativeText: 'शाब्बास! चिंटूने सकाळची सगळी कामे पूर्ण केली. आता आपण सकाळी पाहिलेल्या गोष्टींच्या जोड्या जुळवूया!',
          environment: SceneEnvironmentContract(
            backdrop: 'bg_village_morning',
            character: 'char_chintu',
            characterExpressionDefault: 'thinking',
            prop: 'prop_tractor',
          ),
          questionData: SceneQuestionContract(
            questionType: 'match_following',
            originalQuestionId: 'Q_VILL_04_T1',
            storyQuestionText: 'सकाळच्या गोष्टींच्या योग्य जोड्या जुळवा!',
            correctAnswer: 'matched_all',
            explanationHint: 'सूर्य सकाळी उगवतो आणि चिवताई छतावर बसते.',
            storyBridgeIntro: 'शाब्बास! चिंटूने सकाळची सगळी कामे पूर्ण केली. आता आपण सकाळी पाहिलेल्या गोष्टींच्या जोड्या जुळवूया!',
            ttsMarathiText: 'सकाळच्या गोष्टींच्या योग्य जोड्या लावा सूर्य ट्रॅक्टर आणि चिवताई',
            payloadData: {
              'pairs': [
                {'a': 'सूर्य', 'b': 'सकाळ'},
                {'a': 'ट्रॅक्टर', 'b': 'मोठा'},
                {'a': 'चिवताई', 'b': 'छत'},
              ],
            },
          ),
        ),
      ],
    );
  }

  /// Seed Level 2 Contract: "वडाचे झाड आणि डेअरी" (Banyan Grove & Dairy)
  static GeneratedLevelContract get level2BanyanGroveContract {
    return GeneratedLevelContract(
      levelId: 'lvl_02_banyan_grove',
      levelTitle: 'पातळी २ • वडाचे झाड आणि डेअरी (Banyan Grove & Dairy)',
      theme: 'banyan_grove_and_dairy',
      scenes: [
        GeneratedSceneContract(
          sceneId: 1,
          narrativeText: 'चिंटू आणि NOVA गावाजवळच्या मोठ्या आंब्याच्या आणि वडाच्या बागेत पोहोचले! तिथे एक छोटा वाघोबा आंबे मोजत बसला आहे!',
          environment: SceneEnvironmentContract(
            backdrop: 'bg_banyan_grove',
            character: 'char_tiger',
            characterExpressionDefault: 'playful',
            prop: 'prop_mango',
          ),
          questionData: SceneQuestionContract(
            questionType: 'spot_item',
            originalQuestionId: 'Q_GROVE_01_T1',
            storyQuestionText: 'झाडाखाली बसलेल्या गोंडस वाघोबाला शोधा आणि टॅप करा.',
            correctAnswer: 'वाघोबा',
            explanationHint: 'मोठ्या झाडाच्या सावलीत बसलेला पिवळा वाघोबा पहा.',
            storyBridgeIntro: 'चिंटू आणि NOVA गावाजवळच्या मोठ्या आंब्याच्या आणि वडाच्या बागेत पोहोचले! तिथे एक छोटा वाघोबा आंबे मोजत बसला आहे!',
            ttsMarathiText: 'झाडाखाली बसलेल्या गोंडस वाघोबाला शोधा आणि टॅप करा',
          ),
        ),
        GeneratedSceneContract(
          sceneId: 2,
          narrativeText: 'वाघोबाला मदत केल्यावर चिंटू गावातील डेअरीमध्ये पोहोचला. तिथे कपिला गाय उभी आहे आणि ताजे दूध तयार आहे!',
          environment: SceneEnvironmentContract(
            backdrop: 'bg_banyan_grove',
            character: 'char_cow',
            characterExpressionDefault: 'curious',
            prop: 'prop_milk',
          ),
          questionData: SceneQuestionContract(
            questionType: 'fill_blanks',
            originalQuestionId: 'Q_GROVE_02_T1',
            storyQuestionText: 'गोठ्यातील गाय आणि दुधाचा डबा यात मोठे कोण आहे? मोठी वस्तू ओळखा.',
            options: ['गाय', 'दुधाचा डबा'],
            correctAnswer: 'गाय',
            explanationHint: 'गाय आकाराने दुधाच्या डब्यापेक्षा मोठी असते.',
            storyBridgeIntro: 'वाघोबाला मदत केल्यावर चिंटू गावातील डेअरीमध्ये पोहोचला. तिथे कपिला गाय उभी आहे आणि ताजे दूध तयार आहे!',
            ttsMarathiText: 'गोठ्यातील गाय आणि दुधाचा डबा यात मोठे कोण आहे मोठी वस्तू ओळखा',
          ),
        ),
        GeneratedSceneContract(
          sceneId: 3,
          narrativeText: 'चिंटू आणि NOVA गावाजवळच्या मोठ्या आंब्याच्या आणि वडाच्या बागेत पोहोचले! तिथे एक छोटा वाघोबा आंबे मोजत बसला आहे!',
          environment: SceneEnvironmentContract(
            backdrop: 'bg_banyan_grove',
            character: 'char_tiger',
            characterExpressionDefault: 'counting',
            prop: 'prop_mango',
          ),
          questionData: SceneQuestionContract(
            questionType: 'spot_item',
            originalQuestionId: 'Q_GROVE_01_T1',
            storyQuestionText: 'झाडाखाली बसलेल्या गोंडस वाघोबाला शोधा आणि टॅप करा.',
            correctAnswer: 'वाघोबा',
            explanationHint: 'मोठ्या झाडाच्या सावलीत बसलेला पिवळा वाघोबा पहा.',
            storyBridgeIntro: 'चिंटू आणि NOVA गावाजवळच्या मोठ्या आंब्याच्या आणि वडाच्या बागेत पोहोचले! तिथे एक छोटा वाघोबा आंबे मोजत बसला आहे!',
            ttsMarathiText: 'झाडाखाली बसलेल्या गोंडस वाघोबाला शोधा आणि टॅप करा',
          ),
        ),
        GeneratedSceneContract(
          sceneId: 4,
          narrativeText: 'डेअरी काकांनी विचारले की आपल्याला किती दुधाचे डबे हवे आहेत! चला, माईकमध्ये आवाज देऊन उत्तर सांगूया!',
          environment: SceneEnvironmentContract(
            backdrop: 'bg_banyan_grove',
            character: 'char_tiger',
            characterExpressionDefault: 'friendly',
            prop: 'prop_milk',
          ),
          questionData: SceneQuestionContract(
            questionType: 'voice_input',
            originalQuestionId: 'Q_GROVE_03_T1',
            storyQuestionText: 'आपल्याला ३ दुधाचे डबे हवे आहेत. माईकमध्ये संख्या बोला: "तीन".',
            correctAnswer: 'तीन',
            explanationHint: 'माईक दाबून स्पष्ट म्हणा: "तीन".',
            storyBridgeIntro: 'डेअरी काकांनी विचारले की आपल्याला किती दुधाचे डबे हवे आहेत! चला, माईकमध्ये आवाज देऊन उत्तर सांगूया!',
            ttsMarathiText: 'आपल्याला तीन दुधाचे डबे हवे आहेत माईकमध्ये संख्या तीन बोला',
            payloadData: {
              'expected_phrase': 'तीन',
              'alternatives': ['3', 'Three', 'Tin', 'तीन डबे'],
            },
          ),
        ),
        GeneratedSceneContract(
          sceneId: 5,
          narrativeText: 'खूप छान! आता बागेतील आणि डेअरीतील गोष्टींच्या योग्य जोड्या लावूया!',
          environment: SceneEnvironmentContract(
            backdrop: 'bg_banyan_grove',
            character: 'char_tiger',
            characterExpressionDefault: 'happy',
            prop: 'char_cow',
          ),
          questionData: SceneQuestionContract(
            questionType: 'match_following',
            originalQuestionId: 'Q_GROVE_04_T1',
            storyQuestionText: 'बागेतील आणि डेअरीतील योग्य जोड्या जुळवा!',
            correctAnswer: 'matched_all',
            explanationHint: 'वाघ जंगलात राहतो, गाय दूध देते आणि आंबा झाडावर येतो.',
            storyBridgeIntro: 'खूप छान! आता बागेतील आणि डेअरीतील गोष्टींच्या योग्य जोड्या लावूया!',
            ttsMarathiText: 'बाग आणि डेअरीतील साथीदारांच्या जोड्या लावा वाघ गाय आणि आंबा',
            payloadData: {
              'pairs': [
                {'a': 'वाघ', 'b': 'जंगल'},
                {'a': 'गाय', 'b': 'दूध'},
                {'a': 'आंबा', 'b': 'झाड'},
              ],
            },
          ),
        ),
      ],
    );
  }

  /// Seed Level 3 Contract: "गावाचा आठवडी बाजार" (Village Weekly Market)
  static GeneratedLevelContract get level3VillageMarketContract {
    return GeneratedLevelContract(
      levelId: 'lvl_03_village_market',
      levelTitle: 'पातळी ३ • गावाचा आठवडी बाजार (Village Weekly Market)',
      theme: 'village_weekly_market',
      scenes: [
        GeneratedSceneContract(
          sceneId: 1,
          narrativeText: 'आज गावात आठवडी बाजार भरला आहे! शेतकरी दादांनी ताज्या फळांचे आणि खाऊचे दुकान लावले आहे. चला, बाजारातील मुख्य दुकान शोधूया!',
          environment: SceneEnvironmentContract(
            backdrop: 'bg_village_market',
            character: 'char_farmer',
            characterExpressionDefault: 'friendly',
            prop: 'prop_food_stall',
          ),
          questionData: SceneQuestionContract(
            questionType: 'spot_item',
            originalQuestionId: 'Q_MKT_01_T1',
            storyQuestionText: 'बाजारातील खाऊचे आणि फळांचे दुकान कुठे आहे? त्या चमकणाऱ्या दुकानावर टॅप कर!',
            correctAnswer: 'खाऊचे दुकान',
            explanationHint: 'समोर दिसणारे खाऊचे आणि फळांचे चमकणारे दुकान पहा.',
            storyBridgeIntro: 'आज गावात आठवडी बाजार भरला आहे! शेतकरी दादांनी ताज्या फळांचे आणि खाऊचे दुकान लावले आहे. चला, बाजारातील मुख्य दुकान शोधूया!',
            ttsMarathiText: 'बाजारातील खाऊचे आणि फळांचे दुकान कुठे आहे त्या चमकणाऱ्या दुकानावर टॅप कर',
            payloadData: {
              'level_id': 3,
              'beat_index': 1,
              'target_asset': 'prop_food_stall',
              'english_text': 'Where is the village food stall? Tap on the glowing stall!',
              'wrong_feedback_marathi': 'तिथे नाही! समोर दिसणाऱ्या खाऊच्या दुकानावर टॅप कर!',
              'wrong_feedback_english': 'Not there! Tap on the food stall!',
            },
          ),
        ),
        GeneratedSceneContract(
          sceneId: 2,
          narrativeText: 'शेतकरी दादांनी तराजू काढला आहे! आता आपण फळांची टोपली आणि दुधाचे डबे मोजूया आणि कोणती वस्तू जड किंवा जास्त आहे ते पाहूया!',
          environment: SceneEnvironmentContract(
            backdrop: 'bg_village_market',
            character: 'char_farmer',
            characterExpressionDefault: 'counting',
            prop: 'prop_weighing_scale',
          ),
          questionData: SceneQuestionContract(
            questionType: 'fill_blanks',
            originalQuestionId: 'Q_MKT_02_T1',
            storyQuestionText: 'तराजूवर ठेवल्यास कोणती गोष्ट जास्त जड आणि मोठी भरेल — पूर्ण भरलेली फळांची टोपली की एक छोटा दुधाचा डबा?',
            options: ['फळांची टोपली', 'दुधाचा डबा'],
            correctAnswer: 'फळांची टोपली',
            explanationHint: 'पूर्ण भरलेल्या फळांच्या टोपलीचे वजन एका दुधाच्या डब्यापेक्षा जास्त असते!',
            storyBridgeIntro: 'शेतकरी दादांनी तराजू काढला आहे! आता आपण फळांची टोपली आणि दुधाचे डबे मोजूया आणि कोणती वस्तू जड किंवा जास्त आहे ते पाहूया!',
            ttsMarathiText: 'तराजूवर ठेवल्यास कोणती गोष्ट जास्त जड भरेल पूर्ण भरलेली फळांची टोपली की छोटा दुधाचा डबा',
            payloadData: {
              'level_id': 3,
              'beat_index': 2,
              'options': ['फळांची टोपली', 'दुधाचा डबा'],
              'english_text': 'On the weighing scale, which is heavier — the full Fruit Basket or a single Milk Carton? Tap your answer.',
              'correct_feedback_marathi': 'फळांची टोपली जड आहे!',
              'correct_feedback_english': 'Yes! The fruit basket is heavier.',
              'wrong_feedback_marathi': 'दुधाचा डबा हलका आहे! जड वस्तू कोणती ते पुन्हा निवड!',
              'wrong_feedback_english': 'The milk can is lighter. Tap the fruit basket!',
            },
          ),
        ),
        GeneratedSceneContract(
          sceneId: 3,
          narrativeText: 'आज गावात आठवडी बाजार भरला आहे! शेतकरी दादांनी ताज्या फळांचे आणि खाऊचे दुकान लावले आहे. चला, बाजारातील मुख्य दुकान शोधूया!',
          environment: SceneEnvironmentContract(
            backdrop: 'bg_village_market',
            character: 'char_farmer',
            characterExpressionDefault: 'welcoming',
            prop: 'prop_food_stall',
          ),
          questionData: SceneQuestionContract(
            questionType: 'spot_item',
            originalQuestionId: 'Q_MKT_01_T1',
            storyQuestionText: 'बाजारातील खाऊचे आणि फळांचे दुकान कुठे आहे? त्या चमकणाऱ्या दुकानावर टॅप कर!',
            correctAnswer: 'खाऊचे दुकान',
            explanationHint: 'समोर दिसणारे खाऊचे आणि फळांचे चमकणारे दुकान पहा.',
            storyBridgeIntro: 'आज गावात आठवडी बाजार भरला आहे! शेतकरी दादांनी ताज्या फळांचे आणि खाऊचे दुकान लावले आहे. चला, बाजारातील मुख्य दुकान शोधूया!',
            ttsMarathiText: 'बाजारातील खाऊचे आणि फळांचे दुकान कुठे आहे त्या चमकणाऱ्या दुकानावर टॅप कर',
            payloadData: {
              'level_id': 3,
              'beat_index': 1,
              'target_asset': 'prop_food_stall',
              'english_text': 'Where is the village food stall? Tap on the glowing stall!',
              'wrong_feedback_marathi': 'तिथे नाही! समोर दिसणाऱ्या खाऊच्या दुकानावर टॅप कर!',
              'wrong_feedback_english': 'Not there! Tap on the food stall!',
            },
          ),
        ),
        GeneratedSceneContract(
          sceneId: 4,
          narrativeText: 'विक्रीतून मिळालेले नाणे आता आपण पिगी बँकेत टाकणार आहोत! शेतकरी दादा विचारत आहेत की किती नाणी झाली? चला माईकमध्ये उत्तर बोलून सांगूया!',
          environment: SceneEnvironmentContract(
            backdrop: 'bg_village_market',
            character: 'char_farmer',
            characterExpressionDefault: 'joyful',
            prop: 'prop_piggy_bank',
          ),
          questionData: SceneQuestionContract(
            questionType: 'voice_input',
            originalQuestionId: 'Q_MKT_03_T1',
            storyQuestionText: 'पिगी बँकेत ४ नाणी आहेत. माईक दाबून स्पष्ट आवाजात म्हण: "चार" किंवा "Four"!',
            correctAnswer: 'चार',
            explanationHint: 'माईक दाबून स्पष्ट म्हणा: "चार".',
            storyBridgeIntro: 'विक्रीतून मिळालेले नाणे आता आपण पिगी बँकेत टाकणार आहोत! शेतकरी दादा विचारत आहेत की किती नाणी झाली? चला माईकमध्ये उत्तर बोलून सांगूया!',
            ttsMarathiText: 'पिगी बँकेत चार नाणी आहेत माईक दाबून स्पष्ट आवाजात चार किंवा फोर म्हणा',
            payloadData: {
              'expected_phrase': 'चार',
              'alternatives': ['4', '४', 'char', 'chaar', 'four', 'Four', 'चार नाणी'],
            },
          ),
        ),
        GeneratedSceneContract(
          sceneId: 5,
          narrativeText: 'शाब्बास! आजचा आठवडी बाजार खूप छान झाला! आता बाजारातील सर्व वस्तू आणि त्यांच्या कामांच्या योग्य जोड्या जुळवूया!',
          environment: SceneEnvironmentContract(
            backdrop: 'bg_village_market',
            character: 'char_farmer',
            characterExpressionDefault: 'proud',
            prop: 'prop_fruit_basket',
          ),
          questionData: SceneQuestionContract(
            questionType: 'match_following',
            originalQuestionId: 'Q_MKT_04_T1',
            storyQuestionText: 'आठवडी बाजारातील वस्तू आणि त्यांच्या योग्य जोड्या जुळवा!',
            correctAnswer: 'matched_all',
            explanationHint: 'टोपलीत फळे असतात, तराजूने वजन मोजतात, पिगी बँकेत पैसे वाचवतात.',
            storyBridgeIntro: 'शाब्बास! आजचा आठवडी बाजार खूप छान झाला! आता बाजारातील सर्व वस्तू आणि त्यांच्या कामांच्या योग्य जोड्या जुळवूया!',
            ttsMarathiText: 'आठवडी बाजारातील वस्तू आणि त्यांच्या योग्य जोड्या जुळवा फळांची टोपली तराजू आणि पिगी बँक',
            payloadData: {
              'pairs': [
                {'a': 'फळांची टोपली', 'b': 'ताजी फळे'},
                {'a': 'तराजू', 'b': 'वजन मोजणे'},
                {'a': 'पिगी बँक', 'b': 'पैसे वाचवणे'},
              ],
            },
          ),
        ),
      ],
    );
  }

  /// Seed Level 4 Contract: "गावाची शाळा आणि जत्रा" (Village School & Evening Fair Finale)
  static GeneratedLevelContract get level4SchoolFairContract {
    return GeneratedLevelContract(
      levelId: 'lvl_04_school_fair',
      levelTitle: 'पातळी ४ • गावाची शाळा आणि जत्रा (School & Evening Fair 🏆)',
      theme: 'village_school_and_fair',
      scenes: [
        GeneratedSceneContract(
          sceneId: 1,
          narrativeText: 'बाजारानंतर आता शाळेची वेळ झाली आहे! चिंटूने दप्तर पाठीवर घेतले आहे आणि पिवळी शाळेची बस आली आहे. चला, आधी शाळेची बस शोधूया!',
          environment: SceneEnvironmentContract(
            backdrop: 'bg_village_school',
            character: 'char_chintu',
            characterExpressionDefault: 'ready',
            prop: 'prop_bus',
          ),
          questionData: SceneQuestionContract(
            questionType: 'spot_item',
            originalQuestionId: 'Q_SCH_01_T1',
            storyQuestionText: 'आपल्याला शाळेत नेणारी पिवळी बस कुठे आहे? चमकणाऱ्या बसवर टॅप कर!',
            correctAnswer: 'शाळेची बस',
            explanationHint: 'रस्त्यावर थांबलेली पिवळी शाळेची बस पहा.',
            storyBridgeIntro: 'बाजारानंतर आता शाळेची वेळ झाली आहे! चिंटूने दप्तर पाठीवर घेतले आहे आणि पिवळी शाळेची बस आली आहे. चला, आधी शाळेची बस शोधूया!',
            ttsMarathiText: 'आपल्याला शाळेत नेणारी पिवळी बस कुठे आहे चमकणाऱ्या बसवर टॅप कर',
            payloadData: {
              'level_id': 4,
              'beat_index': 1,
              'target_asset': 'prop_bus',
              'english_text': 'Where is the school bus taking us to school? Tap on the glowing bus!',
              'wrong_feedback_marathi': 'तिथे नाही! रस्त्यावर उभ्या असलेल्या शाळेच्या बसवर टॅप कर!',
              'wrong_feedback_english': 'Not there! Tap on the school bus waiting on the road!',
            },
          ),
        ),
        GeneratedSceneContract(
          sceneId: 2,
          narrativeText: 'चिंटू आणि नोव्हा वर्गात पोहोचले! आज गुरुजी फळ्यावर विविध आकार शिकवत आहेत — वर्तुळ, त्रिकोण, चौकोन आणि आयत! चला योग्य आकार ओळखूया!',
          environment: SceneEnvironmentContract(
            backdrop: 'bg_village_school',
            character: 'char_nova',
            characterExpressionDefault: 'learning',
            prop: 'shape_circle',
          ),
          questionData: SceneQuestionContract(
            questionType: 'fill_blanks',
            originalQuestionId: 'Q_SCH_02_T1',
            storyQuestionText: 'बसच्या चाकासारखा पूर्ण गोल असलेला "वर्तुळ" (Circle) आकार कोणता आहे? योग्य कार्डावर टॅप कर!',
            options: ['वर्तुळ / Circle', 'त्रिकोण / Triangle'],
            correctAnswer: 'वर्तुळ / Circle',
            explanationHint: 'वर्तुळ पूर्णपणे गोल असते, त्याला एकही कोपरा नसतो.',
            storyBridgeIntro: 'चिंटू आणि नोव्हा वर्गात पोहोचले! आज गुरुजी फळ्यावर विविध आकार शिकवत आहेत — वर्तुळ, त्रिकोण, चौकोन आणि आयत! चला योग्य आकार ओळखूया!',
            ttsMarathiText: 'बसच्या चाकासारखा पूर्ण गोल असलेला वर्तुळ आकार कोणता आहे योग्य कार्डावर टॅप कर',
            payloadData: {
              'level_id': 4,
              'beat_index': 2,
              'options': ['वर्तुळ / Circle', 'त्रिकोण / Triangle'],
              'option_lotties': ['assets/lottie/circle.json', 'assets/lottie/triangle.json'],
              'english_text': 'Which shape is completely round like a bus wheel — Circle or Triangle? Tap your answer.',
              'correct_feedback_marathi': 'शाब्बास! वर्तुळ बसच्या चाकासारखे गोल असते!',
              'correct_feedback_english': 'Awesome! The circle is round like a wheel!',
              'wrong_feedback_marathi': 'त्रिकोणाला ३ कोपरे असतात! गोल वर्तुळावर टॅप कर!',
              'wrong_feedback_english': 'A triangle has 3 corners! Tap the round circle!',
            },
          ),
        ),
        GeneratedSceneContract(
          sceneId: 3,
          narrativeText: 'शाळेची बस वेळेवर आली आहे! चला बसवर टॅप करून शाळेत जाऊया!',
          environment: SceneEnvironmentContract(
            backdrop: 'bg_village_school',
            character: 'char_chintu',
            characterExpressionDefault: 'cheerful',
            prop: 'prop_bus',
          ),
          questionData: SceneQuestionContract(
            questionType: 'spot_item',
            originalQuestionId: 'Q_SCH_01_T1',
            storyQuestionText: 'आपल्याला शाळेत नेणारी पिवळी बस कुठे आहे? चमकणाऱ्या बसवर टॅप कर!',
            correctAnswer: 'शाळेची बस',
            explanationHint: 'रस्त्यावर थांबलेली पिवळी शाळेची बस पहा.',
            storyBridgeIntro: 'शाळेची बस वेळेवर आली आहे! चला बसवर टॅप करून शाळेत जाऊया!',
            ttsMarathiText: 'आपल्याला शाळेत नेणारी पिवळी बस कुठे आहे चमकणाऱ्या बसवर टॅप कर',
            payloadData: {
              'level_id': 4,
              'beat_index': 1,
              'target_asset': 'prop_bus',
              'english_text': 'Where is the school bus taking us to school? Tap on the glowing bus!',
              'wrong_feedback_marathi': 'तिथे नाही! रस्त्यावर उभ्या असलेल्या शाळेच्या बसवर टॅप कर!',
              'wrong_feedback_english': 'Not there! Tap on the school bus waiting on the road!',
            },
          ),
        ),
        GeneratedSceneContract(
          sceneId: 4,
          narrativeText: 'शाळा सुटल्यावर संध्याकाळी गावात जत्रा भरली आहे! तिथे मोठा आकाशपाळणा फिरत आहे आणि रंगीबेरंगी फुगे उडत आहेत! चला माईकमध्ये उत्तर बोलून सांगूया!',
          environment: SceneEnvironmentContract(
            backdrop: 'bg_village_school',
            character: 'char_chintu',
            characterExpressionDefault: 'excited',
            prop: 'prop_balloons',
          ),
          questionData: SceneQuestionContract(
            questionType: 'voice_input',
            originalQuestionId: 'Q_SCH_03_T1',
            storyQuestionText: 'आकाशपाळण्याजवळ १० रंगीबेरंगी फुगे आहेत! माईक दाबून जोरात म्हण: "दहा" किंवा "Ten"!',
            correctAnswer: 'दहा',
            explanationHint: 'माईक दाबून स्पष्ट म्हणा: "दहा".',
            storyBridgeIntro: 'शाळा सुटल्यावर संध्याकाळी गावात जत्रा भरली आहे! तिथे मोठा आकाशपाळणा फिरत आहे आणि रंगीबेरंगी फुगे उडत आहेत! चला माईकमध्ये उत्तर बोलून सांगूया!',
            ttsMarathiText: 'आकाशपाळण्याजवळ दहा रंगीबेरंगी फुगे आहेत माईक दाबून जोरात दहा किंवा टेन म्हणा',
            payloadData: {
              'expected_phrase': 'दहा',
              'alternatives': ['10', '१०', 'daha', 'das', 'ten', 'Ten', 'दहा फुगे'],
              'english_text': 'There are 10 colorful balloons near the Ferris wheel! Tap the mic and say "Daha" or "Ten"!',
            },
          ),
        ),
        GeneratedSceneContract(
          sceneId: 5,
          narrativeText: 'अप्रतिम! तुम्ही इयत्ता पहिलीचा शेवटचा टप्पा पूर्ण करत आहात! आता शाळा, आकार आणि जत्रेतील गोष्टींच्या योग्य जोड्या जुळवा आणि विजेता चषक जिंका!',
          environment: SceneEnvironmentContract(
            backdrop: 'bg_village_school',
            character: 'char_nova',
            characterExpressionDefault: 'triumphant',
            prop: 'prop_trophy',
          ),
          questionData: SceneQuestionContract(
            questionType: 'match_following',
            originalQuestionId: 'Q_SCH_04_T1',
            storyQuestionText: 'शाळा, आकार आणि जत्रेतील गोष्टींच्या योग्य जोड्या जुळवा!',
            correctAnswer: 'matched_all',
            explanationHint: 'बस शाळेत जाते, आकाशपाळणा जत्रेत असतो, फुगे आकाशात उडतात.',
            storyBridgeIntro: 'अप्रतिम! तुम्ही इयत्ता पहिलीचा शेवटचा टप्पा पूर्ण करत आहात! आता शाळा, आकार आणि जत्रेतील गोष्टींच्या योग्य जोड्या जुळवा आणि विजेता चषक जिंका!',
            ttsMarathiText: 'शाळा आकार आणि जत्रेतील गोष्टींच्या योग्य जोड्या जुळवा शाळेची बस आकाशपाळणा आणि रंगीबेरंगी फुगे',
            payloadData: {
              'pairs': [
                {'a': 'शाळेची बस', 'b': 'शाळा'},
                {'a': 'आकाशपाळणा', 'b': 'जत्रा'},
                {'a': 'रंगीबेरंगी फुगे', 'b': 'आकाश'},
              ],
            },
          ),
        ),
      ],
    );
  }
}
