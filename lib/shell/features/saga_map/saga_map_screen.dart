import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/level_api.dart';
import '../../core/audio/sound_service.dart';
import '../../core/models/level_progress.dart';
import '../../core/models/user_profile.dart';
import '../../core/widgets/squishy_button.dart';
import '../../theme.dart';

/// SagaMapScreen: Continuous vertically scrollable Candy Crush-style Saga Map
/// with winding S-curve road, glossy 3D level nodes, roadside guiding mascots,
/// and floating bottom level detail drawer.
class SagaMapScreen extends StatefulWidget {
  const SagaMapScreen({super.key});

  @override
  State<SagaMapScreen> createState() => _SagaMapScreenState();
}

class _SagaMapScreenState extends State<SagaMapScreen>
    with SingleTickerProviderStateMixin {
  late final ScrollController _scrollController;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;
  final GameState _gameState = GameState.instance;

  static const double _mapHeight = 1800.0;
  final LevelApi _levelApi = LevelApi();
  List<Map<String, dynamic>> _studentLevels = [];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _gameState.addListener(_onGameStateChanged);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.98, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _loadStudentLevelsAndProgress();

    // Initial scroll position: center on active Level (Y ≈ 900)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          550.0,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  Future<void> _loadStudentLevelsAndProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final studentId = prefs.getInt('current_student_id') ?? UserProfile.instance.studentId;
      if (studentId != null) {
        final levels = await _levelApi.getStudentLevels(studentId, timeout: const Duration(seconds: 4));
        if (levels.isNotEmpty && mounted) {
          setState(() {
            _studentLevels = levels;
            _gameState.setStudentLevels(levels);
          });
        }

        // Fetch student level progress and update unlocked levels
        final progress = await _levelApi.getStudentProgress(studentId, timeout: const Duration(seconds: 4));
        for (final p in progress) {
          final levelId = p['level_id'] as String?;
          final stars = (p['stars'] as int?) ?? 1;
          if (levels.isNotEmpty && levelId != null) {
            final idx = levels.indexWhere((l) => l['level_id'] == levelId);
            if (idx != -1) {
              _gameState.completeLevel(idx + 1, stars, 0);
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Saga map levels load note: $e');
    }

    // Fallback: If backend is offline or student levels empty, load all bundled 5-scene 3-question demo levels
    if (_studentLevels.isEmpty) {
      try {
        final idxString = await rootBundle.loadString('assets/nova/demo/index.json');
        final List<dynamic> demoFiles = jsonDecode(idxString) as List<dynamic>;
        final demoLevels = <Map<String, dynamic>>[];
        for (final f in demoFiles) {
          final s = await rootBundle.loadString('assets/nova/demo/$f');
          demoLevels.add(Map<String, dynamic>.from(jsonDecode(s) as Map));
        }
        if (demoLevels.isNotEmpty && mounted) {
          setState(() {
            _studentLevels = demoLevels;
            _gameState.setStudentLevels(demoLevels);
            final lvlIdx = (_gameState.currentLevelIndex - 1).clamp(0, demoLevels.length - 1);
            _gameState.setSelectedLevelData(demoLevels[lvlIdx]);
          });
          debugPrint('Loaded ${_studentLevels.length} bundled multi-task story demo levels into SagaMap');
        }
      } catch (fallbackErr) {
        debugPrint('Fallback demo levels load note: $fallbackErr');
      }
    }
  }

  void _onGameStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _gameState.removeListener(_onGameStateChanged);
    _scrollController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _onLevelTapped(int levelNumber) {
    final availableCount = _studentLevels.isNotEmpty ? _studentLevels.length : 7;
    if (levelNumber > availableCount) {
      SoundService.instance.playBoingBloop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'टप्पा $levelNumber अजून उपलब्ध नाही! 🔒',
            style: GameTypography.buttonLabel(color: Colors.white).copyWith(fontSize: 16),
          ),
          backgroundColor: GameColors.inkGrape,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    if (_gameState.isLevelUnlocked(levelNumber)) {
      SoundService.instance.playPopClick();
      setState(() {
        _gameState.setCurrentLevel(levelNumber);
        if (_studentLevels.isNotEmpty && levelNumber - 1 < _studentLevels.length) {
          _gameState.setSelectedLevelData(_studentLevels[levelNumber - 1]);
        }
      });
    } else {
      SoundService.instance.playBoingBloop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'टप्पा $levelNumber अजून कुलूपबंद आहे! आधीचे टप्पे पूर्ण करा. 🔒',
            style: GameTypography.buttonLabel(color: Colors.white).copyWith(fontSize: 16),
          ),
          backgroundColor: GameColors.inkGrape,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _playSelectedLevel() {
    SoundService.instance.playPopClick();
    final lvlIdx = _gameState.currentLevelIndex - 1;
    final lvlData = (_studentLevels.isNotEmpty && lvlIdx >= 0 && lvlIdx < _studentLevels.length)
        ? _studentLevels[lvlIdx]
        : _gameState.selectedLevelData;
    _gameState.setSelectedLevelData(lvlData);

    context.go('/rotate-phone', extra: {
      'selectedLevel': lvlData,
      'levelNumber': _gameState.currentLevelIndex,
    });
  }

  @override
  Widget build(BuildContext context) {
    final devanagariNums = {
      1: '१',
      2: '२',
      3: '३',
      4: '४',
      5: '५',
      6: '६',
      7: '७',
    };

    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;

    return Scaffold(
      backgroundColor: const Color(0xFF1E1435),
      body: SizedBox(
        width: double.infinity,
        height: screenHeight,
        child: Stack(
          children: [
            // -------------------------------------------------------------------
            // LAYER 1: Full-Bleed 100% Screen Height Background (Zero White Space)
            // -------------------------------------------------------------------
            Positioned.fill(
              child: SizedBox(
                width: double.infinity,
                height: screenHeight,
                child: Image.asset(
                  'assets/images/components/village_saga_background.png',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: screenHeight,
                  errorBuilder: (c, e, s) => Image.asset(
                    'assets/full_bleed_vertical_9_16_mobile_game_background_illustration_for_a_kids_game/screen.png',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: screenHeight,
                    errorBuilder: (c1, e1, s1) => Container(
                      width: double.infinity,
                      height: screenHeight,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFFBAE6FD), // Blue sky hilltop
                            Color(0xFFFEF3C7), // Sunny orchard
                            Color(0xFFBBF7D0), // Rolling meadow
                            Color(0xFFFDE68A), // Morning courtyard
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // -------------------------------------------------------------------
            // LAYER 2: Scrollable Map (Winding Path & Interactive Level Nodes)
            // -------------------------------------------------------------------
            Positioned.fill(
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(top: 80, bottom: 220),
                child: SizedBox(
                  height: _mapHeight,
                  width: screenWidth,
                child: Stack(
                  children: [
                    // Custom Painter: Winding Cobblestone S-Curve Road
                    Positioned.fill(
                      child: CustomPaint(
                        painter: WindingRoadPainter(),
                      ),
                    ),

                    // Roadside Guiding Mascot: NOVA near Level 2 (Cheering)
                    Positioned(
                      left: 16,
                      top: 1330,
                      child: _buildRoadsideNova(),
                    ),

                    // Roadside Guiding Mascot: NOVA welcoming with Namaste near Level 1
                    Positioned(
                      right: 18,
                      top: 1540,
                      child: _buildRoadsideNovaGuide(
                        pose: 'assets/nova/characters/char_nova_namaste.webp',
                        title: 'सुरू करा! 🌟',
                        subtitle: "Let's start!",
                      ),
                    ),

                    // Roadside Mango Tree near Level 5
                    Positioned(
                      right: 18,
                      top: 620,
                      child: _buildRoadsideAnimal(
                        emoji: '🥭',
                        label: 'आंब्याची बाग',
                      ),
                    ),

                    // Interactive 3D Circular Level Nodes along the Trail
                    ..._buildLevelNodes(devanagariNums),
                  ],
                ),
              ),
            ),
          ),

          // -------------------------------------------------------------------
          // LAYER 3: Top HUD (Coin / Title / Streak Counters)
          // -------------------------------------------------------------------
          Align(
            alignment: Alignment.topCenter,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Left: Coin HUD Capsule
                    HudPillChip(
                      icon: const Text('🪙', style: TextStyle(fontSize: 16)),
                      label: '${_gameState.coins}',
                    ),

                    // Center: Map Title Banner Ribbon
                    Flexible(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFFDE047),
                              Color(0xFFF59E0B),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: GameColors.activeGoldDark.withValues(alpha: 0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Text(
                          'माझे गाव सफर 🚜',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GameTypography.buttonLabel(
                            color: GameColors.inkGrape,
                          ).copyWith(fontSize: 14.5),
                        ),
                      ),
                    ),

                    // Right: Streak Badge (Toggles Active Fire vs Frozen Snowflake)
                    GestureDetector(
                      onTap: () {
                        SoundService.instance.playPopClick();
                        _gameState.toggleStreakFreeze();
                      },
                      child: HudPillChip(
                        icon: Text(
                          _gameState.isStreakFrozen ? '❄️' : '🔥',
                          style: const TextStyle(fontSize: 16),
                        ),
                        label: _gameState.isStreakFrozen
                            ? 'गोठवले!'
                            : '${_gameState.streakDays} दिवस',
                        backgroundColor: _gameState.isStreakFrozen
                            ? const Color(0xFFE0F2FE)
                            : const Color(0xFFFFEDD5),
                        borderColor: _gameState.isStreakFrozen
                            ? const Color(0xFF38BDF8)
                            : GameColors.vibrantOrangeDark,
                        textColor: _gameState.isStreakFrozen
                            ? const Color(0xFF0284C7)
                            : GameColors.vibrantOrangeDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // -------------------------------------------------------------------
          // LAYER 4: Anchored Bottom Drawer ("Start Level" Button firmly pinned)
          // -------------------------------------------------------------------
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: SafeArea(
              top: false,
              child: _buildBottomLevelDetailDrawer(),
            ),
          ),
        ],
      ),
      ),
    );
  }

  /// Builds all 7 level nodes with their exact positioning
  List<Widget> _buildLevelNodes(Map<int, String> devanagariNums) {
    // Relative coordinates across the 1800px tall winding trail
    final nodePositions = [
      {'level': 1, 'xRatio': 0.35, 'y': 1610.0},
      {'level': 2, 'xRatio': 0.68, 'y': 1370.0},
      {'level': 3, 'xRatio': 0.32, 'y': 1130.0},
      {'level': 4, 'xRatio': 0.68, 'y': 890.0}, // Hero Active Level
      {'level': 5, 'xRatio': 0.36, 'y': 650.0},
      {'level': 6, 'xRatio': 0.65, 'y': 430.0},
      {'level': 7, 'xRatio': 0.50, 'y': 210.0}, // Hilltop Fair
    ];

    final screenWidth = MediaQuery.of(context).size.width;

    return nodePositions.map((pos) {
      final level = pos['level'] as int;
      final xRatio = pos['xRatio'] as double;
      final y = pos['y'] as double;
      final x = screenWidth * xRatio;

      final isOutOfRange = _studentLevels.isNotEmpty && (level - 1 >= _studentLevels.length);
      final isCompleted = !isOutOfRange && _gameState.isLevelCompleted(level);
      final isActiveHero = !isOutOfRange && level == _gameState.currentLevelIndex;
      final isLocked = isOutOfRange || !_gameState.isLevelUnlocked(level);
      final stars = isOutOfRange ? 0 : _gameState.getStarsForLevel(level);

      return Positioned(
        left: x - (isActiveHero ? 44.0 : 34.0),
        top: y - (isActiveHero ? 44.0 : 34.0),
        child: GestureDetector(
          onTap: () => _onLevelTapped(level),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Hero Indicator with Chintu Waving
              if (isActiveHero) ...[
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: child,
                    );
                  },
                  child: Column(
                    children: [
                      // Speech Bubble
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: GameColors.activeGoldDark,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Text(
                          'येथे आहात! 👇',
                          style: GameTypography.buttonSublabel(
                            color: GameColors.electricPurple,
                          ).copyWith(fontWeight: FontWeight.w900),
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Nova Guide Head Pin
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFE0F2FE),
                          border: Border.all(color: GameColors.robotBlue, width: 3),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Padding(
                            padding: const EdgeInsets.all(3),
                            child: Image.asset(
                              'assets/nova/characters/char_nova_waving.webp',
                              fit: BoxFit.contain,
                              errorBuilder: (c, e, s) => const Center(
                                child: Text('🤖', style: TextStyle(fontSize: 26)),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                    ],
                  ),
                ),
              ],

              // Level Crown on Level 3
              if (level == 3 && isCompleted)
                const Padding(
                  padding: EdgeInsets.only(bottom: 2),
                  child: Text('👑', style: TextStyle(fontSize: 20)),
                ),

              // 3D Circular Node Body
              Container(
                width: isActiveHero ? 88.0 : 68.0,
                height: isActiveHero ? 88.0 : 68.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isActiveHero
                      ? const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFFFDE047),
                            Color(0xFFFBBF24),
                            Color(0xFFD97706),
                          ],
                        )
                      : isCompleted
                          ? const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0xFF34D399),
                                Color(0xFF10B981),
                                Color(0xFF047857),
                              ],
                            )
                          : const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0xFFF3E8FF),
                                Color(0xFFE9D5FF),
                                Color(0xFFC4B5FD),
                              ],
                            ),
                  border: Border.all(
                    color: Colors.white,
                    width: isActiveHero ? 4.5 : 3.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isActiveHero
                          ? GameColors.activeGoldDark.withValues(alpha: 0.45)
                          : isCompleted
                              ? GameColors.emeraldGrassDark.withValues(alpha: 0.35)
                              : Colors.black12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(
                  child: isLocked
                      ? const Text('🔒', style: TextStyle(fontSize: 26))
                      : Text(
                          devanagariNums[level] ?? '$level',
                          style: GameTypography.displayHero(
                            color: Colors.white,
                          ).copyWith(
                            fontSize: isActiveHero ? 36 : 28,
                            height: 1.0,
                            shadows: const [
                              Shadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                ),
              ),

              // 3 Stars Underneath for Completed Levels
              if (isCompleted) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (starIdx) {
                    final isEarnedStar = starIdx < stars;
                    return Text(
                      isEarnedStar ? '⭐' : '☆',
                      style: TextStyle(
                        fontSize: 14,
                        color: isEarnedStar ? GameColors.activeGoldDark : Colors.grey,
                      ),
                    );
                  }),
                ),
              ],
            ],
          ),
        ),
      );
    }).toList();
  }

  /// Roadside Nova Mascot guide element with customizable pose & speech
  Widget _buildRoadsideNovaGuide({
    required String pose,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: GameColors.robotBlue, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFFE0F2FE),
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: Image.asset(
                pose,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => const Center(
                  child: Text('🤖', style: TextStyle(fontSize: 22)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: GameTypography.headline(color: GameColors.electricPurple)
                    .copyWith(fontSize: 13),
              ),
              Text(
                subtitle,
                style: GameTypography.buttonSublabel(color: GameColors.inkMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// NOVA mascot roadside element
  Widget _buildRoadsideNova() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: GameColors.robotBlue, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFFE0F2FE),
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: Padding(
                padding: const EdgeInsets.all(3),
                child: Image.asset(
                  'assets/nova/characters/char_nova_pointing.webp',
                  fit: BoxFit.contain,
                  errorBuilder: (c, e, s) => const Center(
                    child: Text('🤖', style: TextStyle(fontSize: 24)),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'छान प्रगती! 🚀',
                style: GameTypography.headline(color: GameColors.electricPurple)
                    .copyWith(fontSize: 14),
              ),
              Text(
                'Keep climbing!',
                style: GameTypography.buttonSublabel(color: GameColors.inkMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Small roadside landmark sticker
  Widget _buildRoadsideAnimal({required String emoji, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GameColors.cardBorderAmber, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 6),
          Text(
            label,
            style: GameTypography.buttonSublabel(color: GameColors.inkGrape)
                .copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  /// Floating Bottom Level Detail Drawer Card
  Widget _buildBottomLevelDetailDrawer() {
    final currentInfo = _gameState.currentLevelInfo;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: GameColors.cardBorderLavender, width: 3),
        boxShadow: [
          BoxShadow(
            color: GameColors.inkGrape.withValues(alpha: 0.16),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Row
          Row(
            children: [
              // Level Emoji Badge
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: GameColors.canvasCream,
                  shape: BoxShape.circle,
                  border: Border.all(color: GameColors.cardBorderAmber, width: 2),
                ),
                child: Center(
                  child: Text(
                    currentInfo.iconEmoji,
                    style: const TextStyle(fontSize: 26),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Titles
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      () {
                        final idx = _gameState.currentLevelIndex - 1;
                        if (_studentLevels.isNotEmpty && idx >= 0 && idx < _studentLevels.length) {
                          final lvl = _studentLevels[idx];
                          if (lvl['title'] is Map && lvl['title']['mr'] != null) {
                            return 'टप्पा ${_gameState.currentLevelIndex}: ${lvl['title']['mr']}';
                          }
                        }
                        return 'टप्पा ${currentInfo.levelNumber}: ${currentInfo.titleMarathi}';
                      }(),
                      style: GameTypography.headline(
                        color: GameColors.inkGrape,
                      ).copyWith(fontSize: 17),
                    ),
                    Text(
                      () {
                        final idx = _gameState.currentLevelIndex - 1;
                        if (_studentLevels.isNotEmpty && idx >= 0 && idx < _studentLevels.length) {
                          final lvl = _studentLevels[idx];
                          if (lvl['title'] is Map && lvl['title']['en'] != null) {
                            return 'Level ${_gameState.currentLevelIndex}: ${lvl['title']['en']}';
                          }
                        }
                        return 'Level ${currentInfo.levelNumber}: ${currentInfo.titleEnglish}';
                      }(),
                      style: GameTypography.buttonSublabel(
                        color: GameColors.inkMuted,
                      ),
                    ),
                  ],
                ),
              ),

              // Speaker Audio Cue
              SpeakerButton(
                size: 42,
                color: GameColors.activeGold,
                onPlay: () {
                  SoundService.instance.playDingChime();
                },
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Primary Squishy 3D Play Button
          Squishy3DButton(
            height: 64,
            backgroundColor: GameColors.emeraldGrass,
            bevelColor: GameColors.emeraldGrassDark,
            icon: const Icon(
              Icons.play_arrow_rounded,
              color: Colors.white,
              size: 28,
            ),
            label: 'खेळा! (PLAY) ▶',
            sublabel: 'START LEVEL ${currentInfo.levelNumber}',
            onPressed: _playSelectedLevel,
          ),
        ],
      ),
    );
  }
}

/// CustomPainter rendering the Golden Cobblestone Winding Road
class WindingRoadPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    final w = size.width;

    // S-curve points connecting bottom (Level 1) to top (Level 7)
    final p1 = Offset(w * 0.35, 1610.0);
    final p2 = Offset(w * 0.68, 1370.0);
    final p3 = Offset(w * 0.32, 1130.0);
    final p4 = Offset(w * 0.68, 890.0);
    final p5 = Offset(w * 0.36, 650.0);
    final p6 = Offset(w * 0.65, 430.0);
    final p7 = Offset(w * 0.50, 210.0);

    path.moveTo(p1.dx, p1.dy);
    path.cubicTo(w * 0.15, 1500, w * 0.85, 1480, p2.dx, p2.dy);
    path.cubicTo(w * 0.85, 1260, w * 0.15, 1240, p3.dx, p3.dy);
    path.cubicTo(w * 0.15, 1020, w * 0.85, 1000, p4.dx, p4.dy);
    path.cubicTo(w * 0.85, 780, w * 0.15, 760, p5.dx, p5.dy);
    path.cubicTo(w * 0.15, 550, w * 0.85, 530, p6.dx, p6.dy);
    path.cubicTo(w * 0.85, 330, w * 0.35, 310, p7.dx, p7.dy);

    // Layer 1: Road Drop Shadow Rim
    final shadowPaint = Paint()
      ..color = const Color(0xFFC99300).withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 52.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, shadowPaint);

    // Layer 2: Golden Cobblestone Road Core
    final roadPaint = Paint()
      ..color = const Color(0xFFFFC329)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 42.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, roadPaint);

    // Layer 3: Inner Golden Highlight
    final highlightPaint = Paint()
      ..color = const Color(0xFFFFE071)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 28.0
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, highlightPaint);

    // Layer 4: Stepping White Dashes
    final dashPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    // Draw dashed path points
    final pathMetrics = path.computeMetrics();
    for (final metric in pathMetrics) {
      double distance = 0.0;
      const dashLength = 14.0;
      const dashSpace = 16.0;
      while (distance < metric.length) {
        final extracted = metric.extractPath(distance, distance + dashLength);
        canvas.drawPath(extracted, dashPaint);
        distance += dashLength + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
