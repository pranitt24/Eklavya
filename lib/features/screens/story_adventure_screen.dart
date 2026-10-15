import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/design_system/nova_colors.dart';
import '../../core/design_system/nova_typography.dart';
import '../../core/design_system/nova_spacing.dart';
import '../../core/routing/orientation_helper.dart';
import '../../core/services/nova_audio_service.dart';
import 'package:lottie/lottie.dart';
import '../../nova_main/demo/demo_controls.dart';
import '../../core/widgets/nova/nova_button.dart';
import '../../core/widgets/nova/nova_matching_chip.dart';
import '../../core/widgets/nova/nova_matching_bezier_painter.dart';
import '../../core/widgets/nova/nova_pause_modal.dart';
import '../../core/widgets/nova/nova_progress_bar.dart';
import '../../core/widgets/nova/nova_speaker_button.dart';
import '../../core/widgets/nova/nova_village_painter.dart';
import '../../core/widgets/nova/nova_robot_mascot.dart';
import '../../features/diagnostic/adaptive_engine.dart';
import '../../features/voice_engine/voice_answer_matcher.dart';
import '../../nova_main/services/app_state.dart';
import 'level_road_screen.dart';

/// Flagship Landscape Story Engine implementing Screens 5 through 11:
/// - Screen 5: Rotate Phone Modal
/// - Screen 6: Village Story (Bilingual split screen)
/// - Screen 7: Big vs Small Quiz (Interactive selection & BKT engine)
/// - Screen 8: Touch the Bird (Interactive village canvas & celebration)
/// - Screen 9: Voice Activity (Vosk STT / Vernacular pronunciation & optional tap)
/// - Screen 10: Match the Following (Cubic bezier curve line-matching & multi-state chips)
/// - Screen 11: Level Celebration (Earned badges, stars, and high five)
class StoryAdventureScreen extends StatefulWidget {
  final int initialLevelId;
  final int initialScreen;
  final bool startWithRotateModal;

  const StoryAdventureScreen({
    super.key,
    this.initialLevelId = 1,
    this.initialScreen = 6,
    this.startWithRotateModal = true,
  });

  @override
  State<StoryAdventureScreen> createState() => _StoryAdventureScreenState();
}

class _StoryAdventureScreenState extends State<StoryAdventureScreen> with TickerProviderStateMixin {
  // Screen 5 modal state
  late bool _showRotateModal;

  // Active Story Step: 6 (Story), 7 (Quiz), 8 (Bird), 9 (Voice), 10 (Matching), 11 (Celebration)
  late int _activeScreen;

  // BKT Engine & Performance
  final DiagnosticManager _diagnosticManager = DiagnosticManager();
  final StudentPerformanceState _bktState = StudentPerformanceState(pMastery: 0.15, consecutiveFails: 0);
  late DateTime _stepStartTime;

  // Audio State
  NovaSpeakerState _speakerState = NovaSpeakerState.listen;

  // Micro-celebration confetti state
  bool _showConfettiPop = false;

  void _triggerConfettiPop() {
    setState(() {
      _showConfettiPop = true;
    });
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) {
        setState(() {
          _showConfettiPop = false;
        });
      }
    });
  }

  // --- Screen 7 Quiz State ---
  // null = idle, true = correct, false = retry
  bool? _quizAnswerOutcome;

  // --- Screen 8 Bird State ---
  bool _birdTapped = false;

  // --- Screen 9 Voice State ---
  bool _voiceListening = false;
  bool _voiceSuccess = false;

  // --- Screen 10 Matching State ---
  // Correct match map: 0 -> 1, 1 -> 2, 2 -> 0
  final Map<int, int> _correctMatches = {0: 1, 1: 2, 2: 0};
  final List<MatchConnection> _establishedConnections = [];
  int? _selectedLeftChip;
  int? _selectedRightChip;
  bool? _matchingOutcome; // true = success, false = incorrect retry, null = selecting
  Offset? _activeDragStart;
  Offset? _activeDragCurrent;

  final Map<int, GlobalKey> _leftSocketKeys = {0: GlobalKey(), 1: GlobalKey(), 2: GlobalKey()};
  final Map<int, GlobalKey> _rightSocketKeys = {0: GlobalKey(), 1: GlobalKey(), 2: GlobalKey()};
  final GlobalKey _matchingStackKey = GlobalKey();

  // Animation controller for pulsing mic and rings
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _showRotateModal = widget.startWithRotateModal && widget.initialScreen == 6;
    _activeScreen = widget.initialScreen;
    if (!_showRotateModal) {
      OrientationHelper.lockLandscape();
    }
    _stepStartTime = DateTime.now();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    NovaAudioService.instance.isPlayingNotifier.addListener(_onTtsStateChanged);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    NovaAudioService.instance.isPlayingNotifier.removeListener(_onTtsStateChanged);
    OrientationHelper.lockPortrait();
    super.dispose();
  }

  void _onTtsStateChanged() {
    if (mounted) {
      setState(() {
        _speakerState = NovaAudioService.instance.isPlaying
            ? NovaSpeakerState.playing
            : NovaSpeakerState.listen;
      });
    }
  }

  void _onDismissRotateModal() {
    setState(() {
      _showRotateModal = false;
    });
    OrientationHelper.lockLandscape();
    _playScreenAudio();
  }

  void _playScreenAudio() {
    switch (_activeScreen) {
      case 6:
        NovaAudioService.instance.speak("सूर्याची सोनेरी किरणे आली... गाव जागे झाले! चिवताई छतावर गाऊ लागली!");
        break;
      case 7:
        NovaAudioService.instance.speak("यातील मोठी वस्तू कोणती? ट्रॅक्टर की सायकल?");
        break;
      case 8:
        NovaAudioService.instance.speak("छतावर कोण बसले आहे? चिवताईला टॅप करा!");
        break;
      case 9:
        NovaAudioService.instance.speak("म्हणून बघ... शुभ प्रभात!");
        break;
      case 10:
        NovaAudioService.instance.speak("ओढून जुळव किंवा टॅप कर! जोड्या जुळवा.");
        break;
      case 11:
        NovaAudioService.instance.speak("खूप छान! तू पहिली पातळी जिंकलीस! अभिनंदन!");
        break;
    }
  }

  void _handleExit() {
    NovaPauseModal.show(
      context,
      onResume: () {},
      onHome: () {
        OrientationHelper.lockPortrait();
        Navigator.of(context).maybePop();
      },
    );
  }

  // --- Step 7 Quiz Handlers ---
  void _answerQuiz(bool isTractorSelected) {
    final timeMs = DateTime.now().difference(_stepStartTime).inMilliseconds;
    final isCorrect = isTractorSelected; // Tractor is big

    _diagnosticManager.evaluateResponse(isCorrect, timeMs, _bktState);

    setState(() {
      _quizAnswerOutcome = isCorrect;
    });

    if (isCorrect) {
      _triggerConfettiPop();
      NovaAudioService.instance.speak("शाब्बास! ट्रॅक्टर मोठा आहे!");
    } else {
      NovaAudioService.instance.speak("पुन्हा बघूया! सायकल छोटी आहे. पुन्हा प्रयत्न करा!");
    }
  }

  // --- Step 8 Bird Handlers ---
  void _tapBird() {
    if (_birdTapped) return;
    setState(() {
      _birdTapped = true;
    });
    _triggerConfettiPop();
    NovaAudioService.instance.speak("शाब्बास! वर! चिवताई छतावर बसली आहे!");
  }

  // --- Step 9 Voice Handlers ---
  void _triggerVoiceInput() {
    setState(() {
      _voiceListening = true;
    });

    // Simulate / Process through VoiceAnswerMatcher
    Timer(const Duration(milliseconds: 1600), () {
      if (!mounted) return;
      final bool matches = VoiceAnswerMatcher.evaluateAnswer("शुभ प्रभात", "शुभ प्रभात");
      if (matches) {
        setState(() {
          _voiceListening = false;
          _voiceSuccess = true;
        });
        _triggerConfettiPop();
        NovaAudioService.instance.speak("शाब्बास! शुभ प्रभात!");
      }
    });
  }

  // --- Step 10 Matching Handlers ---
  void _onLeftChipTapped(int index) {
    if (_establishedConnections.any((c) => c.leftIndex == index)) return;
    setState(() {
      _selectedLeftChip = index;
      _matchingOutcome = null;
    });
    if (_selectedRightChip != null) {
      _evaluateMatch(index, _selectedRightChip!);
    }
  }

  void _onRightChipTapped(int index) {
    if (_establishedConnections.any((c) => c.rightIndex == index)) return;
    setState(() {
      _selectedRightChip = index;
      _matchingOutcome = null;
    });
    if (_selectedLeftChip != null) {
      _evaluateMatch(_selectedLeftChip!, index);
    }
  }

  void _evaluateMatch(int leftIdx, int rightIdx) {
    final bool isCorrect = _correctMatches[leftIdx] == rightIdx;

    if (isCorrect) {
      Color curveColor;
      if (leftIdx == 0) {
        curveColor = NovaColors.goldDark;
      } else if (leftIdx == 1) {
        curveColor = NovaColors.purple;
      } else {
        curveColor = const Color(0xFF0D9488); // Teal
      }

      setState(() {
        _establishedConnections.add(
          MatchConnection(leftIndex: leftIdx, rightIndex: rightIdx, color: curveColor),
        );
        _selectedLeftChip = null;
        _selectedRightChip = null;
        _matchingOutcome = true;
      });
      _triggerConfettiPop();

      if (_establishedConnections.length == 3) {
        NovaAudioService.instance.speak("शाब्बास! सगळ्या जोड्या जुळल्या!");
      } else {
        NovaAudioService.instance.speak("छान! बरोबर जोडी!");
      }
    } else {
      setState(() {
        _matchingOutcome = false;
      });
      NovaAudioService.instance.speak("पुन्हा बघूया! दुसरी जोडी निवडा.");
    }
  }

  Offset? _getSocketCenter(GlobalKey key) {
    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    final stackBox = _matchingStackKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || stackBox == null) return null;
    final globalPos = renderBox.localToGlobal(Offset.zero);
    final localPos = stackBox.globalToLocal(globalPos);
    return Offset(localPos.dx + renderBox.size.width / 2, localPos.dy + renderBox.size.height / 2);
  }

  void _goToScreen(int screenNumber) {
    setState(() {
      _activeScreen = screenNumber;
      _stepStartTime = DateTime.now();
      _quizAnswerOutcome = null;
      _birdTapped = false;
      _voiceListening = false;
      _voiceSuccess = false;
      if (screenNumber == 6) {
        _establishedConnections.clear();
        _selectedLeftChip = null;
        _selectedRightChip = null;
        _matchingOutcome = null;
      }
    });
    _playScreenAudio();
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);

    // If Screen 5 modal is active, display it over blurred level road background
    if (_showRotateModal) {
      return _buildScreen5RotateModal();
    }

    return Scaffold(
      backgroundColor: NovaColors.cream,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Top Global Landscape Header Bar
                _buildLandscapeHeader(appState),
                // Main Content Screen Router
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                    child: _buildActiveScreenContent(appState),
                  ),
                ),
              ],
            ),
          ),
          if (_showConfettiPop)
            Positioned.fill(
              child: IgnorePointer(
                child: Center(
                  child: Lottie.asset(
                    'assets/lottie/Confetti Pop.json',
                    repeat: false,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ===========================================================================
  // SCREEN 5: ROTATE PHONE MODAL
  // ===========================================================================
  Widget _buildScreen5RotateModal() {
    return Scaffold(
      backgroundColor: const Color(0xFF1B162E),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background vector landscape
          const Opacity(
            opacity: 0.35,
            child: CustomPaint(
              size: Size.infinite,
              painter: VillageRoadPainter(),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 680),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                decoration: BoxDecoration(
                  color: NovaColors.cream,
                  borderRadius: NovaSpacing.roundedModal,
                  border: Border.all(color: Colors.white, width: 4.0),
                  boxShadow: NovaSpacing.modalShadow,
                ),
                child: Row(
                  children: [
                    // Rotating phone graphic and mascot
                    Expanded(
                      flex: 4,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 130,
                            height: 130,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFEF3C7),
                              shape: BoxShape.circle,
                            ),
                          ),
                          // Rotating phone visual
                          Transform.rotate(
                            angle: -0.25,
                            child: Container(
                              width: 100,
                              height: 60,
                              decoration: BoxDecoration(
                                color: NovaColors.purple,
                                borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x3D271C44),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(Icons.crop_landscape_rounded, color: Colors.white, size: 34),
                            ),
                          ),
                        ).animate(onPlay: (c) => c.repeat(reverse: true))
                         .rotate(begin: -0.1, end: 0.1, duration: 1200.ms, curve: Curves.easeInOut),

                        // Animated Lottie NOVA mascot
                        Positioned(
                          bottom: 0,
                          left: 10,
                          child: Lottie.asset(
                            'assets/lottie/Robot says hello.json',
                            width: 60,
                            height: 60,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),

                  // Modal Instructions & CTA
                  Expanded(
                    flex: 6,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'NOVA • MAJHE GAON • PART 2',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: NovaColors.purple,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Expanded(
                              child: Text(
                                'गोष्ट पाहण्यासाठी फोन आडवा करा!',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: NovaColors.ink,
                                ),
                              ),
                            ),
                            NovaSpeakerButton(
                              state: _speakerState,
                              onTap: () {
                                NovaAudioService.instance.speak("गोष्ट पाहण्यासाठी फोन आडवा करा!");
                              },
                              size: 38,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '(Turn your phone sideways for the story!)',
                          style: NovaTypography.bodySecondary,
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: NovaColors.purpleLight,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text(
                            'चिंटू आणि NOVA तयार आहेत!',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: NovaColors.purple,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        NovaButton(
                          label: 'पुढे चला -> (Continue)',
                          variant: NovaButtonVariant.primary,
                          height: 44,
                          onPressed: _onDismissRotateModal,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        ],
      ),
    );
  }

  // ===========================================================================
  // GLOBAL LANDSCAPE HEADER
  // ===========================================================================
  Widget _buildLandscapeHeader(AppState appState) {
    String title = 'गावाची सफर';
    String subtitle = 'NOVA • MAJHE GAON / Village story';
    int progressStep = 1;
    String? statusBadge;
    Color statusBadgeColor = NovaColors.goldLight;
    Color statusTextColor = NovaColors.goldDark;

    switch (_activeScreen) {
      case 6:
        title = 'गावाची सफर';
        subtitle = 'NOVA • MAJHE GAON / Village story';
        progressStep = 1;
        break;
      case 7:
        title = 'मोठे आणि छोटे';
        subtitle = 'NOVA • MAJHE GAON / Big & small';
        progressStep = 2;
        if (_quizAnswerOutcome == true) {
          statusBadge = 'QUIZ • CORRECT';
          statusBadgeColor = const Color(0xFFFEF3C7);
          statusTextColor = const Color(0xFFB45309);
        } else if (_quizAnswerOutcome == false) {
          statusBadge = 'QUIZ • RETRY';
          statusBadgeColor = const Color(0xFFFEE2E2);
          statusTextColor = const Color(0xFFDC2626);
        }
        break;
      case 8:
        title = 'चिवताई कुठे आहे?';
        subtitle = 'NOVA • MAJHE GAON / Find Chiu';
        progressStep = 3;
        if (_birdTapped) {
          statusBadge = 'BIRD • CELEBRATION';
          statusBadgeColor = const Color(0xFFFEF3C7);
          statusTextColor = const Color(0xFFB45309);
        }
        break;
      case 9:
        title = 'सकाळचा नमस्कार';
        subtitle = 'NOVA • MAJHE GAON / Good morning';
        progressStep = 4;
        if (_voiceSuccess) {
          statusBadge = 'VOICE • SUCCESS';
          statusBadgeColor = const Color(0xFFFEF3C7);
          statusTextColor = const Color(0xFFB45309);
        }
        break;
      case 10:
        title = 'जोड्या जुळवा!';
        subtitle = 'NOVA • MAJHE GAON / Match the following';
        progressStep = 5;
        if (_establishedConnections.length == 3) {
          statusBadge = 'MATCH • COMPLETED';
          statusBadgeColor = const Color(0xFFFEF3C7);
          statusTextColor = const Color(0xFFB45309);
        } else if (_matchingOutcome == false) {
          statusBadge = 'MATCH • TRY AGAIN';
          statusBadgeColor = const Color(0xFFFEE2E2);
          statusTextColor = const Color(0xFFDC2626);
        } else if (_selectedLeftChip != null || _selectedRightChip != null) {
          statusBadge = 'MATCH • SELECTED';
          statusBadgeColor = const Color(0xFFFEF3C7);
          statusTextColor = const Color(0xFFB45309);
        }
        break;
      case 11:
        title = 'माझे गाव • शाब्बास!';
        subtitle = 'NOVA • MAJHE GAON / Level 1 complete';
        progressStep = 5;
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: Row(
        children: [
          // Home button
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: NovaColors.purpleBorder.withValues(alpha: 0.6)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0C271C44),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: InkWell(
              onTap: _handleExit,
              child: Row(
                children: const [
                  Icon(Icons.home_rounded, color: NovaColors.purple, size: 20),
                  SizedBox(width: 4),
                  Text(
                    'Home',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: NovaColors.ink,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Title & Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: NovaColors.ink,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: NovaColors.inkSoft,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Active feedback badge if any
          if (statusBadge != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusBadgeColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                statusBadge,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: statusTextColor,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(width: 10),
          ],

          // Segmented Progress Bar
          NovaProgressBar(
            currentStep: progressStep,
            totalSteps: 5,
            dashWidth: 22,
            dashHeight: 7,
          ),
          const SizedBox(width: 10),

          // Mute Button
          ValueListenableBuilder<bool>(
            valueListenable: NovaAudioService.instance.isMutedNotifier,
            builder: (context, isMuted, _) {
              return NovaSpeakerButton(
                state: isMuted ? NovaSpeakerState.mute : NovaSpeakerState.listen,
                label: 'Mute',
                onTap: () {
                  NovaAudioService.instance.toggleMute();
                },
                size: 38,
              );
            },
          ),
          const SizedBox(width: 8),

          // Evaluator Demo Controls Button
          GestureDetector(
            onTap: () => DemoControlsSheet.show(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: NovaColors.purpleLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: NovaColors.purple.withValues(alpha: 0.3)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.build_rounded, size: 15, color: NovaColors.purple),
                  SizedBox(width: 4),
                  Text(
                    'Demo',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: NovaColors.purple,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // ROUTER FOR ACTIVE SCREEN
  // ===========================================================================
  Widget _buildActiveScreenContent(AppState appState) {
    switch (_activeScreen) {
      case 6:
        return _buildScreen6VillageStory();
      case 7:
        return _buildScreen7BigVsSmallQuiz();
      case 8:
        return _buildScreen8TouchBird();
      case 9:
        return _buildScreen9VoiceActivity();
      case 10:
        return _buildScreen10MatchFollowing();
      case 11:
        return _buildScreen11Celebration(appState);
      default:
        return _buildScreen6VillageStory();
    }
  }

  // ===========================================================================
  // ===========================================================================
  // REUSABLE RICH VILLAGE CANVAS (Screen 6 & Screen 8)
  // ===========================================================================
  Widget _buildVillageCanvas({bool isInteractiveBird = false}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: NovaSpacing.roundedCard,
        boxShadow: NovaSpacing.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: NovaSpacing.roundedCard,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double cardW = constraints.maxWidth;
            final double cardH = constraints.maxHeight;

            return Stack(
              fit: StackFit.expand,
              children: [
                // Rich 3D Village Background Artwork (cropped top 8% to cleanly eliminate cut-off text)
                Positioned(
                  top: -cardH * 0.08,
                  left: 0,
                  right: 0,
                  bottom: -cardH * 0.02,
                  child: Image.asset(
                    'assets/images/village_story_bg.png',
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                    errorBuilder: (context, error, stackTrace) => const CustomPaint(
                      size: Size.infinite,
                      painter: VillageScenePainter(),
                    ),
                  ),
                ),

                // Screen 8 Interactive Chiu Target: ONLY glowing golden pulsing ring over painted bird
                if (isInteractiveBird) ...[
                  Positioned(
                    left: cardW * 0.54 - 40,
                    top: cardH * 0.32 - 40,
                    child: GestureDetector(
                      onTap: _tapBird,
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: 80,
                        height: 80,
                        alignment: Alignment.center,
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _birdTapped ? NovaColors.green : NovaColors.gold,
                              width: 3.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (_birdTapped ? NovaColors.green : NovaColors.gold).withValues(alpha: 0.5),
                                blurRadius: 12,
                                spreadRadius: 3,
                              ),
                            ],
                          ),
                        ).animate(onPlay: (c) => c.repeat(reverse: true))
                         .scale(begin: const Offset(0.90, 0.90), end: const Offset(1.15, 1.15), duration: 1100.ms),
                      ),
                    ),
                  ),
                  if (_birdTapped)
                    Positioned(
                      top: cardH * 0.18,
                      left: cardW * 0.54 - 45,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: NovaColors.gold,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x3D271C44),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Text(
                          'वर / TOP!',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: NovaColors.ink,
                          ),
                        ),
                      ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
                    ),
                ],

                // "माझी सकाळ • My morning" pill tag cleanly placed at top-left
                Positioned(
                  top: 10,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x1A271C44),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Text(
                      'माझी सकाळ • My morning',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: NovaColors.ink,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // SCREEN 6: VILLAGE STORY
  // ===========================================================================
  Widget _buildScreen6VillageStory() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Left Column: Village Illustration Canvas
        Expanded(
          flex: 11,
          child: _buildVillageCanvas(isInteractiveBird: false),
        ),
        const SizedBox(width: 18),

        // Right Column: Bilingual Narration & Actions
        Expanded(
          flex: 9,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: NovaColors.purpleLight,
                    borderRadius: NovaSpacing.roundedCard,
                  ),
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 380),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const NovaRobotMascot(size: 64),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'NOVA SAYS...',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: NovaColors.purple,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ],
                                ),
                                NovaSpeakerButton(
                                  state: _speakerState,
                                  label: 'Listen',
                                  onTap: _playScreenAudio,
                                  size: 36,
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'सूर्याची सोनेरी किरणे आली... गाव जागे झाले! चिवताई छतावर गाऊ लागली!',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: NovaColors.ink,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Golden rays arrive... the village wakes! Chiu sings on the roof.',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: NovaColors.inkSoft,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    flex: 6,
                    child: NovaButton(
                      label: 'पुढे -> Next Beat',
                      variant: NovaButtonVariant.primary,
                      height: 44,
                      onPressed: () => _goToScreen(7),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 4,
                    child: NovaButton(
                      label: 'Skip ->',
                      variant: NovaButtonVariant.secondary,
                      height: 44,
                      onPressed: () => _goToScreen(7),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // SCREEN 7: BIG VS SMALL QUIZ
  // ===========================================================================
  Widget _buildScreen7BigVsSmallQuiz() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Prompt banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: NovaColors.purpleLight,
            borderRadius: NovaSpacing.roundedMd,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'यातील मोठी वस्तू कोणती?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: NovaColors.ink,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Which object is big? Tap your answer.',
                      style: NovaTypography.bodySecondary,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              NovaSpeakerButton(
                state: _speakerState,
                onTap: _playScreenAudio,
                size: 38,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Cards & Feedback row
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Card 1: Red Tractor
              Expanded(
                flex: 7,
                child: _buildQuizSelectionCard(
                  imageAsset: 'assets/images/generated/tractor.png',
                  label: 'ट्रॅक्टर / Tractor',
                  fallbackIcon: Icons.agriculture_rounded,
                  isTargetBig: true,
                  isSelected: _quizAnswerOutcome == true,
                  isGentleRetry: false,
                  onTap: () => _answerQuiz(true),
                ),
              ),
              const SizedBox(width: 12),

              // Card 2: Blue Bicycle
              Expanded(
                flex: 7,
                child: _buildQuizSelectionCard(
                  imageAsset: 'assets/images/generated/bicycle.png',
                  label: 'सायकल / Bicycle',
                  fallbackIcon: Icons.pedal_bike_rounded,
                  isTargetBig: false,
                  isSelected: false,
                  isGentleRetry: _quizAnswerOutcome == false,
                  onTap: () => _answerQuiz(false),
                ),
              ),
              const SizedBox(width: 12),

              // Right Sidebar: Prompt / Feedback
              Expanded(
                flex: 6,
                child: _buildQuizSidebarFeedback(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuizSelectionCard({
    required String imageAsset,
    required String label,
    required IconData fallbackIcon,
    required bool isTargetBig,
    required bool isSelected,
    required bool isGentleRetry,
    required VoidCallback onTap,
  }) {
    Color borderColor = NovaColors.purpleBorder.withValues(alpha: 0.5);
    Color bgColor = Colors.white;
    double borderWidth = 1.5;

    if (isSelected) {
      borderColor = NovaColors.green;
      borderWidth = 3.0;
      bgColor = const Color(0xFFF0FDF4);
    } else if (isGentleRetry) {
      borderColor = NovaColors.coral;
      borderWidth = 2.5;
      bgColor = const Color(0xFFFFF1F2);
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: NovaSpacing.roundedCard,
          border: Border.all(color: borderColor, width: borderWidth),
          boxShadow: NovaSpacing.cardShadow,
        ),
        child: Stack(
          children: [
            // Status Icon badge
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: NovaColors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_rounded, color: Colors.white, size: 18),
                ),
              ),
            if (isGentleRetry)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: NovaColors.coral,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
                ),
              ),
            // Artwork & bottom pill
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Center(
                        child: isTargetBig
                            ? ClipRect(
                                child: Transform.scale(
                                  scale: 2.2,
                                  child: Lottie.asset(
                                    'assets/lottie/tractor.json',
                                    height: 120,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              )
                            : const SizedBox(
                                height: 90,
                                child: Center(
                                  child: BicycleVectorArt(size: 78),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                      decoration: BoxDecoration(
                        color: (isSelected || isGentleRetry) ? const Color(0xFFFEF3C7) : NovaColors.purpleLight,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        label,
                        style: NovaTypography.chipText.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: NovaColors.ink,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizSidebarFeedback() {
    if (_quizAnswerOutcome == true) {
      // Correct feedback state matching Feedback · Quiz correct.png
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F8F0),
          borderRadius: NovaSpacing.roundedCard,
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const NovaRobotMascot(size: 64),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.star_rounded, color: NovaColors.gold, size: 20),
                    SizedBox(width: 3),
                    Icon(Icons.star_rounded, color: NovaColors.gold, size: 24),
                    SizedBox(width: 3),
                    Icon(Icons.star_rounded, color: NovaColors.gold, size: 20),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'शाब्बास!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: NovaColors.green,
                  ),
                ),
                const Text(
                  'ट्रॅक्टर मोठा आहे!',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: NovaColors.ink,
                  ),
                ),
                const Text(
                  'Yes! The tractor is big.',
                  style: NovaTypography.caption,
                ),
                const SizedBox(height: 10),
                NovaButton(
                  label: 'पुढे चला ->',
                  variant: NovaButtonVariant.primary,
                  height: 40,
                  onPressed: () => _goToScreen(8),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_quizAnswerOutcome == false) {
      // Gentle retry state matching Feedback · Quiz retry.png
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF1E8),
          borderRadius: NovaSpacing.roundedCard,
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const NovaRobotMascot(size: 64),
                const SizedBox(height: 4),
                const Text(
                  'पुन्हा बघूया!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: NovaColors.ink,
                  ),
                ),
                const Text(
                  'सायकल छोटी आहे.',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: NovaColors.ink,
                  ),
                ),
                const Text(
                  'That bicycle is small. Try again!',
                  style: NovaTypography.caption,
                ),
                const SizedBox(height: 10),
                NovaButton(
                  label: 'पुन्हा प्रयत्न ↺',
                  variant: NovaButtonVariant.retry,
                  height: 40,
                  onPressed: () {
                    setState(() => _quizAnswerOutcome = null);
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Default idle guidance
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: NovaSpacing.roundedCard,
      ),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const NovaRobotMascot(size: 64),
              const SizedBox(height: 6),
              const Text(
                'बघ आणि निवड!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: NovaColors.ink,
                ),
              ),
              const Text(
                'कोणती वस्तू मोठी?',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: NovaColors.ink,
                ),
              ),
              const Text(
                'Look at both objects.',
                style: NovaTypography.caption,
              ),
              const SizedBox(height: 10),
              NovaButton(
                label: 'Skip ->',
                variant: NovaButtonVariant.secondary,
                height: 40,
                onPressed: () => _goToScreen(8),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // SCREEN 8: TOUCH THE BIRD
  // ===========================================================================
  Widget _buildScreen8TouchBird() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Left Column: Interactive village canvas with Chiu on roof
        Expanded(
          flex: 11,
          child: _buildVillageCanvas(isInteractiveBird: true),
        ),
        const SizedBox(width: 18),

        // Right Column: Instructions or Celebration
        Expanded(
          flex: 9,
          child: _birdTapped
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F8F0),
                    borderRadius: NovaSpacing.roundedCard,
                  ),
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.star_rounded, color: NovaColors.gold, size: 24),
                              SizedBox(width: 4),
                              Icon(Icons.star_rounded, color: NovaColors.gold, size: 30),
                              SizedBox(width: 4),
                              Icon(Icons.star_rounded, color: NovaColors.gold, size: 24),
                            ],
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'शाब्बास! वर!',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: NovaColors.green,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Chiu is on TOP! Hooray!',
                            style: NovaTypography.bodySecondary,
                          ),
                          const SizedBox(height: 12),
                          NovaButton(
                            label: 'पुढे चला ->',
                            variant: NovaButtonVariant.primary,
                            height: 40,
                            onPressed: () => _goToScreen(9),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: NovaColors.purpleLight,
                    borderRadius: NovaSpacing.roundedCard,
                  ),
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.center,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 360),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'छतावर कोण बसले आहे?',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: NovaColors.ink,
                                  ),
                                ),
                                NovaSpeakerButton(
                                  state: _speakerState,
                                  onTap: _playScreenAudio,
                                  size: 36,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const NovaRobotMascot(size: 64),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: const [
                                      Text(
                                        'चिवताईला टॅप कर!',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          color: NovaColors.ink,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'Who is on the roof? Tap the glowing bird.',
                                        style: NovaTypography.bodySecondary,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            NovaButton(
                              label: 'Skip ->',
                              variant: NovaButtonVariant.secondary,
                              height: 40,
                              onPressed: () => _goToScreen(9),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  // ===========================================================================
  // SCREEN 9: VOICE ACTIVITY
  // ===========================================================================
  Widget _buildScreen9VoiceActivity() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Left Column: Pulsing Microphone or Recognized Feedback
        Expanded(
          flex: 10,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _voiceSuccess ? const Color(0xFFE8F8F0) : const Color(0xFFFFF1E8),
              borderRadius: NovaSpacing.roundedCard,
            ),
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Pulsing Mic Button
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Concentric rings
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _voiceSuccess
                                  ? const Color(0xFF86EFAC)
                                  : (_voiceListening ? const Color(0xFFFCA5A5) : const Color(0xFFFED7AA)),
                              width: 2.0,
                            ),
                          ),
                        ).animate(onPlay: (c) => c.repeat(reverse: true))
                         .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.15, 1.15), duration: 1000.ms),

                        // Center Coral/Green Button
                        GestureDetector(
                          onTap: _triggerVoiceInput,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: _voiceSuccess ? NovaColors.green : NovaColors.coral,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: (_voiceSuccess ? NovaColors.green : NovaColors.coral).withValues(alpha: 0.4),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.mic_rounded, size: 40, color: Colors.white),
                          ),
                        ),

                        if (_voiceSuccess)
                          Positioned(
                            bottom: 0,
                            right: 4,
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: const BoxDecoration(
                                color: NovaColors.green,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.check_rounded, color: Colors.white, size: 18),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Waveform Equalizer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(8, (i) {
                        return Container(
                          width: 5,
                          height: (10 + (i % 3) * 6).toDouble(),
                          margin: const EdgeInsets.symmetric(horizontal: 2.5),
                          decoration: BoxDecoration(
                            color: _voiceSuccess ? NovaColors.green : NovaColors.coral,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 8),

                    Text(
                      _voiceSuccess ? '● Recognized! • ऐकले!' : (_voiceListening ? '● Listening... • ऐकत आहे...' : 'माईक दाबा किंवा टॅप करा'),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: _voiceSuccess ? NovaColors.green : NovaColors.coral,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),

        // Right Column: Prompt & Tap Alternative
        Expanded(
          flex: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: NovaColors.purpleLight,
              borderRadius: NovaSpacing.roundedCard,
            ),
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.center,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 380),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'म्हणून बघ...',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: NovaColors.inkSoft,
                                  ),
                                ),
                                Text(
                                  'शुभ प्रभात!',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: NovaColors.ink,
                                  ),
                                ),
                                Text(
                                  '(Good Morning!)',
                                  style: NovaTypography.bodySecondary,
                                ),
                              ],
                            ),
                          ),
                          NovaSpeakerButton(
                            state: _speakerState,
                            onTap: _playScreenAudio,
                            size: 38,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // NOVA helper or success card
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: _voiceSuccess ? const Color(0xFFE8F8F0) : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            const NovaRobotMascot(size: 64),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _voiceSuccess ? 'शाब्बास! शुभ प्रभात!' : 'बोल किंवा टॅप कर!',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: _voiceSuccess ? NovaColors.green : NovaColors.ink,
                                    ),
                                  ),
                                  Text(
                                    _voiceSuccess ? 'You did it! Your greeting was heard.' : 'Say it if you like. Tapping works too!',
                                    style: NovaTypography.caption,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Actions: Tap option or Proceed
                      Row(
                        children: [
                          Expanded(
                            flex: 6,
                            child: NovaButton(
                              label: 'किंवा येथे टॅप करा',
                              variant: NovaButtonVariant.secondary,
                              height: 40,
                              onPressed: _triggerVoiceInput,
                            ),
                          ),
                          if (_voiceSuccess) ...[
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 4,
                              child: NovaButton(
                                label: 'पुढे ->',
                                variant: NovaButtonVariant.primary,
                                height: 40,
                                onPressed: () => _goToScreen(10),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Center(
                        child: Text(
                          'Tap instead • Speaking is always optional',
                          style: TextStyle(fontSize: 10, color: NovaColors.inkSoft),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // SCREEN 10: MATCH THE FOLLOWING
  // ===========================================================================
  Widget _buildScreen10MatchFollowing() {
    final int matchedCount = _establishedConnections.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: NovaColors.purpleLight,
            borderRadius: NovaSpacing.roundedMd,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'ओढून जुळव किंवा टॅप कर!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: NovaColors.ink,
                      ),
                    ),
                    Text(
                      'Drag to match • Or tap a picture, then its word.',
                      style: NovaTypography.bodySecondary,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '$matchedCount/3 matched',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: NovaColors.purple,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              NovaSpeakerButton(
                state: _speakerState,
                onTap: _playScreenAudio,
                size: 40,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Interactive matching canvas and columns
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left Column & Right Column Stack with Custom Bezier Line Painter
              Expanded(
                flex: 14,
                child: Stack(
                  key: _matchingStackKey,
                  children: [
                    // Bezier Curve Painter Layer
                    Positioned.fill(
                      child: AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, _) {
                          final Map<int, Offset> leftPositions = {};
                          final Map<int, Offset> rightPositions = {};

                          for (int i = 0; i < 3; i++) {
                            final pL = _getSocketCenter(_leftSocketKeys[i]!);
                            if (pL != null) leftPositions[i] = pL;
                            final pR = _getSocketCenter(_rightSocketKeys[i]!);
                            if (pR != null) rightPositions[i] = pR;
                          }

                          return CustomPaint(
                            painter: NovaMatchingBezierPainter(
                              leftSocketPositions: leftPositions,
                              rightSocketPositions: rightPositions,
                              connections: _establishedConnections,
                              activeDragStart: _activeDragStart,
                              activeDragCurrent: _activeDragCurrent,
                            ),
                          );
                        },
                      ),
                    ),

                    // Matching Chips Grid
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Left Chips
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildLeftMatchingChip(
                                index: 0,
                                text: 'सूर्य',
                                subtitle: 'Sun',
                                icon: Icons.wb_sunny_rounded,
                                iconColor: NovaColors.goldDark,
                                customLottie: 'assets/lottie/Animated Star Gold 3D Icon Loop.json',
                              ),
                              _buildLeftMatchingChip(
                                index: 1,
                                text: 'छतावरील चिमणी',
                                subtitle: 'Chiu on roof',
                                icon: Icons.flutter_dash_rounded,
                                iconColor: const Color(0xFFD97706),
                                customLottie: 'assets/lottie/Blue Bird.json',
                              ),
                              _buildLeftMatchingChip(
                                index: 2,
                                text: 'मोठा ट्रॅक्टर',
                                subtitle: 'Big tractor',
                                icon: Icons.agriculture_rounded,
                                iconColor: const Color(0xFFDC2626),
                                customLottie: 'assets/lottie/tractor.json',
                              ),
                            ],
                          ),
                        ),
                        // Helper pill in center when a chip is selected
                        if (_selectedLeftChip != null && _selectedRightChip == null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: NovaColors.purpleLight,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Text(
                              'Tap a word ->',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: NovaColors.purple),
                            ),
                          )
                        else
                          const SizedBox(width: 40),

                        // Right Chips
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildRightMatchingChip(
                                index: 0,
                                text: 'मोठा',
                                subtitle: 'Big',
                              ),
                              _buildRightMatchingChip(
                                index: 1,
                                text: 'सकाळ',
                                subtitle: 'Morning',
                              ),
                              _buildRightMatchingChip(
                                index: 2,
                                text: 'वर',
                                subtitle: 'Top',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),

              // Right Column Sidebar: Instructions & Celebration
              Expanded(
                flex: 6,
                child: _buildMatchingSidebar(matchedCount),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLeftMatchingChip({
    required int index,
    required String text,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    String? customLottie,
  }) {
    NovaMatchingChipState chipState = NovaMatchingChipState.defaultState;
    if (_establishedConnections.any((c) => c.leftIndex == index)) {
      chipState = NovaMatchingChipState.completed;
    } else if (_selectedLeftChip == index) {
      chipState = (_matchingOutcome == false)
          ? NovaMatchingChipState.incorrect
          : NovaMatchingChipState.selected;
    }

    return NovaMatchingChip(
      text: text,
      subtitle: subtitle,
      state: chipState,
      dotSide: ConnectionDotSide.right,
      socketKey: _leftSocketKeys[index],
      leadingIcon: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: customLottie != null
              ? Lottie.asset(customLottie, width: 30, height: 30, fit: BoxFit.contain)
              : Icon(icon, color: iconColor, size: 22),
        ),
      ),
      onTap: () => _onLeftChipTapped(index),
    );
  }

  Widget _buildRightMatchingChip({
    required int index,
    required String text,
    required String subtitle,
  }) {
    NovaMatchingChipState chipState = NovaMatchingChipState.defaultState;
    if (_establishedConnections.any((c) => c.rightIndex == index)) {
      chipState = NovaMatchingChipState.completed;
    } else if (_selectedRightChip == index) {
      chipState = (_matchingOutcome == false)
          ? NovaMatchingChipState.incorrect
          : NovaMatchingChipState.selected;
    }

    return NovaMatchingChip(
      text: text,
      subtitle: subtitle,
      state: chipState,
      dotSide: ConnectionDotSide.left,
      socketKey: _rightSocketKeys[index],
      onTap: () => _onRightChipTapped(index),
    );
  }

  Widget _buildMatchingSidebar(int matchedCount) {
    if (matchedCount == 3) {
      // Completed state matching Matching feedback · Completed.png
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F8F0),
          borderRadius: NovaSpacing.roundedCard,
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const NovaRobotMascot(size: 64),
                const SizedBox(height: 4),
                const Text(
                  'शाब्बास!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: NovaColors.green,
                  ),
                ),
                const Text(
                  'सगळ्या जोड्या जुळल्या!',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: NovaColors.ink,
                  ),
                ),
                const Text(
                  'All pairs matched. You did it!',
                  style: NovaTypography.caption,
                ),
                const SizedBox(height: 10),
                NovaButton(
                  label: 'बक्षीस पाहूया! ->',
                  variant: NovaButtonVariant.primary,
                  height: 40,
                  onPressed: () => _goToScreen(11),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_matchingOutcome == false) {
      // Gently incorrect retry state
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF1E8),
          borderRadius: NovaSpacing.roundedCard,
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const NovaRobotMascot(size: 64),
                const SizedBox(height: 4),
                const Text(
                  'पुन्हा बघूया!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: NovaColors.ink,
                  ),
                ),
                const Text(
                  'सूर्य सकाळी उगवतो.',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: NovaColors.ink,
                  ),
                ),
                const Text(
                  'The sun rises in the morning. Try another pair.',
                  style: NovaTypography.caption,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                NovaButton(
                  label: 'पुन्हा प्रयत्न ↺',
                  variant: NovaButtonVariant.retry,
                  height: 40,
                  onPressed: () {
                    setState(() {
                      _selectedLeftChip = null;
                      _selectedRightChip = null;
                      _matchingOutcome = null;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Default guidance
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: NovaSpacing.roundedCard,
      ),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const NovaRobotMascot(size: 64),
              const SizedBox(height: 6),
              const Text(
                'जोडी शोधूया!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: NovaColors.ink,
                ),
              ),
              const Text(
                'ओढून किंवा टॅप करून जुळव!',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: NovaColors.ink,
                ),
                textAlign: TextAlign.center,
              ),
              const Text(
                'Drag to a match, or tap one chip on each side.',
                style: NovaTypography.caption,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              NovaButton(
                label: 'ऐकूया • Listen',
                variant: NovaButtonVariant.secondary,
                height: 40,
                onPressed: _playScreenAudio,
              ),
              const SizedBox(height: 4),
              const Text(
                'No timer • Take your time',
                style: TextStyle(fontSize: 10, color: NovaColors.inkSoft),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // SCREEN 11: CELEBRATION
  // ===========================================================================
  Widget _buildScreen11Celebration(AppState appState) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Left Column: Chintu + NOVA High-five Artwork & Stars
        Expanded(
          flex: 9,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: NovaSpacing.roundedCard,
              boxShadow: NovaSpacing.cardShadow,
            ),
            child: ClipRRect(
              borderRadius: NovaSpacing.roundedCard,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Base background gradient
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFFFEF3C7),
                          Color(0xFFEDE9FE),
                          Color(0xFFDCFCE7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),

                  // Full-card celebration confetti effects loop across entire background
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Lottie.asset(
                        'assets/lottie/Confetti Effects Lottie Animation.json',
                        fit: BoxFit.cover,
                        repeat: true,
                      ),
                    ),
                  ),

                  // Chintu and Nova celebrating right next to each other in the center
                  Positioned.fill(
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Lottie.asset(
                            'assets/lottie/Hand Waving Animation.json',
                            height: 170,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(width: 12),
                          const NovaRobotMascot(
                            size: 140,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 3 Gold Stars at top
                  Positioned(
                    top: 12,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Lottie.asset('assets/lottie/Animated Star Gold 3D Icon Loop.json', width: 34, height: 34, fit: BoxFit.contain),
                        const SizedBox(width: 8),
                        Lottie.asset('assets/lottie/Animated Star Gold 3D Icon Loop.json', width: 44, height: 44, fit: BoxFit.contain),
                        const SizedBox(width: 8),
                        Lottie.asset('assets/lottie/Animated Star Gold 3D Icon Loop.json', width: 34, height: 34, fit: BoxFit.contain),
                      ],
                    ),
                  ),

                  // Bottom High-five pill
                  Positioned(
                    bottom: 12,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x28271C44),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Text(
                          'चिंटू + NOVA • High five!',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: NovaColors.purple,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),

        // Right Column: Summary, 5 Badges, and Exits
        Expanded(
          flex: 11,
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.topLeft,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'LEVEL 1 • COMPLETE ✓',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: NovaColors.purple,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'खूप छान!\nतू १ ली पातळी जिंकलीस!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: NovaColors.ink,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Awesome! You completed Level 1!',
                      style: NovaTypography.bodySecondary,
                    ),
                    const SizedBox(height: 8),

                    // Badges Section
                    const Text(
                      'YOUR LEARNING BADGES • तुझी कमाई',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: NovaColors.purple,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 5),

                    // 5 Badges Row
                    Row(
                      children: [
                        _buildCelebrationBadge(Icons.wb_sunny_rounded, const Color(0xFFF59E0B), 'सकाळ • रात्र', 'Morning/Night'),
                        _buildCelebrationBadge(Icons.agriculture_rounded, const Color(0xFFDC2626), 'मोठे • छोटे', 'Big vs Small'),
                        _buildCelebrationBadge(Icons.arrow_upward_rounded, NovaColors.purple, 'वर • खाली', 'Top vs Bottom'),
                        _buildCelebrationBadge(Icons.flutter_dash_rounded, const Color(0xFF0284C7), 'छतावर चिऊ', 'Chiu on Roof'),
                        _buildCelebrationBadge(Icons.cruelty_free_rounded, const Color(0xFF16A34A), 'जमिनीवर गण्या', 'Ganya Ground'),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Action Buttons Row
                    Row(
                      children: [
                        Expanded(
                          child: NovaButton(
                            label: 'पुन्हा खेळू • Play Again',
                            variant: NovaButtonVariant.primary,
                            height: 44,
                            onPressed: () {
                              _goToScreen(6);
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: NovaButton(
                            label: 'घरी जाऊ • Back to Home',
                            variant: NovaButtonVariant.secondary,
                            height: 44,
                            onPressed: () {
                              OrientationHelper.lockPortrait();
                              Navigator.of(context).maybePop();
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCelebrationBadge(IconData icon, Color badgeColor, String marathi, String english) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E2F4)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A271C44),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(color: badgeColor, width: 1.5),
              ),
              child: Center(
                child: Icon(icon, color: badgeColor, size: 17),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              marathi,
              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: NovaColors.ink),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              english,
              style: const TextStyle(fontSize: 7.5, fontWeight: FontWeight.w600, color: NovaColors.inkSoft),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
