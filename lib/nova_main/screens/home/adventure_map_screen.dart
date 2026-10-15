import 'dart:math';
import 'package:flutter/material.dart';
import '../../constants/app_strings.dart';
import '../../models/level_model.dart';
import '../../services/app_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/level_node.dart';
import '../../widgets/offline_badge.dart';
import '../levels/level_detail_screen.dart';

/// Adventure Map hero screen with winding cubic S-curve path and 15 interactive level nodes.
class AdventureMapScreen extends StatefulWidget {
  final int? classId;
  const AdventureMapScreen({super.key, this.classId});

  @override
  State<AdventureMapScreen> createState() => _AdventureMapScreenState();
}

class _AdventureMapScreenState extends State<AdventureMapScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentLevel();
    });
  }

  void _scrollToCurrentLevel() {
    if (!_scrollController.hasClients) return;
    // Map is rendered bottom-to-top (Level 1 at bottom, Level 15 at top)
    final appState = AppStateScope.of(context);
    final currentLvl = appState.student.currentLevel;
    // Each level node row takes ~130dp
    final maxScroll = _scrollController.position.maxScrollExtent;
    final targetScroll = max(0.0, maxScroll - (currentLvl - 1) * 115);

    _scrollController.animateTo(
      targetScroll,
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
    );
  }

  void _openLevelDetail(AppState appState, LevelModel level) {
    appState.startLevel(level.number);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LevelDetailScreen()),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final student = appState.student;
    final levels = appState.currentLevels; // 1 to 15
    final currentLevel = student.currentLevel;

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                // Top Header Bar
                _buildTopBar(appState),
                const Divider(height: 1),

                // Winding Path Scrollable Area
                Expanded(
                  child: Stack(
                    children: [
                      SingleChildScrollView(
                        controller: _scrollController,
                        padding: const EdgeInsets.only(top: 30, bottom: 120),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
                            child: SizedBox(
                              height: 15 * 130.0 + 80,
                              child: Stack(
                                children: [
                                  // CustomPainter S-Curve connector path
                                  Positioned.fill(
                                    child: CustomPaint(
                                      painter: _WindingPathPainter(
                                        totalLevels: 15,
                                        completedLevelMax: student.completedLevels.isEmpty
                                            ? 0
                                            : student.completedLevels.reduce(max),
                                      ),
                                    ),
                                  ),

                                  // Level nodes positioned along the S-curve
                                  // Rendered Level 15 at top down to Level 1 at bottom
                                  for (int i = 0; i < 15; i++) ...[
                                    _buildPositionedNode(
                                      levelIndex: i, // 0 = Lvl 15, 14 = Lvl 1
                                      level: levels[14 - i],
                                      appState: appState,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Persistent floating bottom pill: [ Continue Level {n} ]
            Positioned(
              left: 20,
              right: 20,
              bottom: 24,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.navy,
                      foregroundColor: Colors.white,
                      elevation: 6,
                      shadowColor: AppColors.shadowNavy,
                      minimumSize: const Size(double.infinity, 58),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(29)),
                    ),
                    onPressed: () {
                      final currentLvlModel = appState.currentCourse.getLevel(currentLevel);
                      _openLevelDetail(appState, currentLvlModel);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.play_circle_fill_rounded, color: AppColors.sunYellow, size: 28),
                        const SizedBox(width: 8),
                        Text(
                          AppStrings.continueLevelPill.replaceAll('{n}', '$currentLevel'),
                          style: AppTextStyles.button,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(AppState appState) {
    final student = appState.student;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          // Class chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.indigo.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Text('🎒', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 4),
                Text(
                  'Class ${student.classNumber}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.navy, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Stars chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.sunYellow),
            ),
            child: Row(
              children: [
                const Icon(Icons.star_rounded, color: AppColors.sunYellow, size: 18),
                const SizedBox(width: 4),
                Text(
                  '${student.stars}',
                  style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFFB45309), fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Streak chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1F0),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.coral),
            ),
            child: Row(
              children: [
                const Text('🔥', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Text(
                  '${student.streak}',
                  style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF991B1B), fontSize: 13),
                ),
              ],
            ),
          ),
          const Spacer(),

          // Offline Chip
          const OfflineBadge(compact: true),
        ],
      ),
    );
  }

  Widget _buildPositionedNode({
    required int levelIndex,
    required LevelModel level,
    required AppState appState,
  }) {
    // S-curve positioning: Left / Center / Right alternating
    // Top = level 15 (levelIndex 0), Bottom = level 1 (levelIndex 14)
    final double y = levelIndex * 130.0 + 30;
    double alignmentFactor; // -0.6 (left), 0.0 (center), 0.6 (right)

    final cycle = levelIndex % 4;
    if (cycle == 0) {
      alignmentFactor = 0.0;
    } else if (cycle == 1) {
      alignmentFactor = -0.55;
    } else if (cycle == 2) {
      alignmentFactor = 0.0;
    } else {
      alignmentFactor = 0.55;
    }

    return Positioned(
      top: y,
      left: 0,
      right: 0,
      child: Center(
        child: Transform.translate(
          offset: Offset(alignmentFactor * 140, 0),
          child: LevelNode(
            level: level,
            state: level.state,
            isRecommended: level.number == appState.student.recommendedLevel,
            onTap: () => _openLevelDetail(appState, level),
          ),
        ),
      ),
    );
  }
}

class _WindingPathPainter extends CustomPainter {
  final int totalLevels;
  final int completedLevelMax;

  _WindingPathPainter({required this.totalLevels, required this.completedLevelMax});

  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = size.width / 2;
    const double rowHeight = 130.0;
    const double startY = 30.0 + 40.0; // center of node

    final solidPaint = Paint()
      ..color = AppColors.mint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    final lockedPaint = Paint()
      ..color = AppColors.borderLight
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round;

    // Draw connecting curve between consecutive levels (from level 1 bottom up to level 15 top)
    for (int i = 14; i > 0; i--) {
      final double y1 = i * rowHeight + startY;
      final double y2 = (i - 1) * rowHeight + startY;

      final double x1 = centerX + _getXOffset(i);
      final double x2 = centerX + _getXOffset(i - 1);

      final path = Path();
      path.moveTo(x1, y1);
      path.cubicTo(
        x1, y1 - rowHeight * 0.5,
        x2, y2 + rowHeight * 0.5,
        x2, y2,
      );

      final int levelNum = 15 - i;
      final bool isSegmentCompleted = levelNum <= completedLevelMax;

      canvas.drawPath(path, isSegmentCompleted ? solidPaint : lockedPaint);
    }
  }

  double _getXOffset(int index) {
    final cycle = index % 4;
    if (cycle == 0) return 0.0;
    if (cycle == 1) return -0.55 * 140;
    if (cycle == 2) return 0.0;
    return 0.55 * 140;
  }

  @override
  bool shouldRepaint(covariant _WindingPathPainter oldDelegate) {
    return oldDelegate.completedLevelMax != completedLevelMax;
  }
}
