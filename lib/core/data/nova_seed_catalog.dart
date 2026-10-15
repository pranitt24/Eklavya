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
    } else {
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
}
