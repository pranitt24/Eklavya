import 'package:flutter/material.dart';
import '../../constants/app_strings.dart';
import '../../demo/demo_fab.dart';
import '../../services/app_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/primary_button.dart';
import '../../../features/curriculum/presentation/std1_level1_story_screen.dart';
import '../story/story_screen.dart';

/// Level detail preview modal presenting challenge topic, estimated time, and reward stars.
class LevelDetailScreen extends StatelessWidget {
  const LevelDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final level = appState.activeLevel ?? appState.currentCourse.getLevel(appState.student.currentLevel);

    String difficultyLabel = 'Easy';
    if (level.difficulty == 2) difficultyLabel = 'Medium';
    if (level.difficulty == 3) difficultyLabel = 'Tricky';

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.navy, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Big Topic Emoji in glowing circle
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.sunYellow, width: 3.5),
                          boxShadow: AppSpacing.glowShadow,
                        ),
                        alignment: Alignment.center,
                        child: Text(level.emoji, style: const TextStyle(fontSize: 54)),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Level Tag
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.navy,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          '${AppStrings.levelPrefix} ${level.number}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      // Topic Title
                      Text(
                        level.topic,
                        style: AppTextStyles.headingLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),

                      // Description
                      Text(
                        level.description,
                        style: AppTextStyles.bodySoft,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Info Badges Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildInfoCard(
                            'Difficulty',
                            difficultyLabel,
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(3, (i) {
                                return Icon(
                                  i < level.difficulty ? Icons.star_rounded : Icons.star_border_rounded,
                                  color: AppColors.sunYellow,
                                  size: 18,
                                );
                              }),
                            ),
                          ),
                          _buildInfoCard(
                            'Time',
                            '${level.estMinutes} min',
                            const Icon(Icons.timer_outlined, color: AppColors.indigo, size: 20),
                          ),
                          _buildInfoCard(
                            'Reward',
                            '${level.rewardStars} Stars',
                            const Icon(Icons.stars_rounded, color: Color(0xFFD97706), size: 20),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Voice or tap hint
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FF),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          AppStrings.voiceOrTap,
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.indigo,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),

                      // ▶ Primary Action: [ Start Adventure ]
                      PrimaryButton(
                        label: AppStrings.startAdventure,
                        icon: Icons.play_arrow_rounded,
                        onPressed: () {
                          appState.startLevel(level.number);
                          if (appState.student.classNumber == 1 && level.number == 1) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const Std1Level1StoryScreen()),
                            );
                          } else {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const StoryScreen()),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const DemoFab(),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String val, Widget visual) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppSpacing.roundedCard,
        border: Border.all(color: AppColors.borderLight, width: 1.5),
        boxShadow: AppSpacing.softShadow,
      ),
      child: Column(
        children: [
          visual,
          const SizedBox(height: 4),
          Text(
            val,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.navy),
            textAlign: TextAlign.center,
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 11, color: AppColors.inkSoft),
          ),
        ],
      ),
    );
  }
}
