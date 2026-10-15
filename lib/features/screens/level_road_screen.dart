import 'package:flutter/material.dart';
import '../../core/design_system/nova_colors.dart';
import '../../core/design_system/nova_typography.dart';
import '../../core/design_system/nova_spacing.dart';
import '../../core/routing/orientation_helper.dart';
import '../../core/services/nova_audio_service.dart';
import 'package:lottie/lottie.dart';
import '../../core/widgets/nova/nova_button.dart';
import '../../core/widgets/nova/nova_speaker_button.dart';
import '../../nova_main/demo/demo_controls.dart';
import '../../nova_main/services/app_state.dart';
import 'story_adventure_screen.dart';

/// Screen 4: Level road (`assets/Potrait screens/Level road.png`).
/// Displays vertical winding village road ('गावाची सफर') with interactive level nodes,
/// locked/unlocked states, and bottom 'माझी सकाळ' start adventure card.
class LevelRoadScreen extends StatefulWidget {
  const LevelRoadScreen({super.key});

  @override
  State<LevelRoadScreen> createState() => _LevelRoadScreenState();
}

class _LevelRoadScreenState extends State<LevelRoadScreen> {
  int _selectedLevel = 1;
  NovaSpeakerState _speakerState = NovaSpeakerState.listen;

  @override
  void initState() {
    super.initState();
    OrientationHelper.lockPortrait();
    NovaAudioService.instance.isPlayingNotifier.addListener(_onTtsStateChanged);
  }

  @override
  void dispose() {
    NovaAudioService.instance.isPlayingNotifier.removeListener(_onTtsStateChanged);
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

  void _playPromptAudio() {
    NovaAudioService.instance.speak("चिंटूसोबत साहसाला तयार? Start at the sunshine stop!");
  }

  void _startStoryAdventure() {
    // Show Screen 5 Rotate Phone Modal and launch story adventure
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StoryAdventureScreen(initialLevelId: _selectedLevel),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final int studentClass = appState.student.classNumber;

    return Scaffold(
      backgroundColor: NovaColors.cream,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Bar
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x10271C44),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_rounded, color: NovaColors.ink),
                          onPressed: () => Navigator.of(context).maybePop(),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'गावाची सफर',
                              style: NovaTypography.headingLarge,
                            ),
                            Text(
                              'Story Adventure • Standard $studentClass',
                              style: NovaTypography.bodySecondary,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x10271C44),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.build_rounded, color: NovaColors.purple, size: 20),
                          tooltip: 'Demo Controls',
                          onPressed: () => DemoControlsSheet.show(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Prompt Banner
                  Container(
                    padding: const EdgeInsets.all(16.0),
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
                                'चिंटूसोबत साहसाला तयार?',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: NovaColors.ink,
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                'Start at the sunshine stop!',
                                style: NovaTypography.bodySecondary,
                              ),
                            ],
                          ),
                        ),
                        NovaSpeakerButton(
                          state: _speakerState,
                          onTap: _playPromptAudio,
                          size: 44,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Level Road Canvas Container
                  Container(
                    height: 400,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFBF6E9),
                      borderRadius: NovaSpacing.roundedCard,
                      border: Border.all(color: NovaColors.purpleBorder.withValues(alpha: 0.5), width: 1.5),
                      boxShadow: NovaSpacing.cardShadow,
                    ),
                    child: ClipRRect(
                      borderRadius: NovaSpacing.roundedCard,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Vibrant Village Road Canvas (100% Vector)
                          const CustomPaint(
                            size: Size.infinite,
                            painter: VillageRoadPainter(),
                          ),

                          // Interactive Level Nodes
                          // Node 1: Sunshine Node (Active/Selected)
                          Positioned(
                            left: 36,
                            bottom: 60,
                            child: _buildSunshineNode(1),
                          ),

                          // Node 2: Locked
                          Positioned(
                            right: 70,
                            bottom: 120,
                            child: _buildLockedNode(2, 'Level 2'),
                          ),

                          // Node 3: Locked
                          Positioned(
                            left: 100,
                            top: 175,
                            child: _buildLockedNode(3, 'Level 3'),
                          ),

                          // Node 4: Locked
                          Positioned(
                            right: 60,
                            top: 110,
                            child: _buildLockedNode(4, 'Level 4'),
                          ),

                          // Node 5: Locked
                          Positioned(
                            left: 120,
                            top: 40,
                            child: _buildLockedNode(5, 'Level 5'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Floating Bottom Start Card
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: NovaSpacing.roundedCard,
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x10271C44),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'माझी सकाळ',
                                style: NovaTypography.headingMedium,
                              ),
                              SizedBox(height: 2),
                              Text(
                                'My morning • Level 1',
                                style: NovaTypography.bodySecondary,
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Lottie.asset('assets/lottie/Animated Star Gold 3D Icon Loop.json', width: 28, height: 28, fit: BoxFit.contain),
                            const SizedBox(width: 4),
                            Lottie.asset('assets/lottie/Animated Star Gold 3D Icon Loop.json', width: 28, height: 28, fit: BoxFit.contain),
                            const SizedBox(width: 4),
                            Lottie.asset('assets/lottie/Animated Star Gold 3D Icon Loop.json', width: 28, height: 28, fit: BoxFit.contain),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Bottom CTA
                  NovaButton(
                    label: 'साहस सुरू करा! 🚀',
                    variant: NovaButtonVariant.primary,
                    height: 56,
                    onPressed: _startStoryAdventure,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSunshineNode(int levelNum) {
    return GestureDetector(
      onTap: () {
        setState(() => _selectedLevel = levelNum);
        NovaAudioService.instance.speak("पातळी एक. माझी सकाळ.");
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: NovaColors.gold,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4.0),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x3DFBBF24),
                  blurRadius: 16,
                  spreadRadius: 4,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.wb_sunny_rounded,
                size: 34,
                color: NovaColors.ink,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14271C44),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: const Text(
              'Level 1',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: NovaColors.purple,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLockedNode(int levelNum, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFDDD6FE), width: 1.5),
            boxShadow: const [
              BoxShadow(
                color: Color(0x10271C44),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.lock_rounded,
              size: 24,
              color: Color(0xFF8B7FA8),
            ),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: Color(0xFF6B5E87),
          ),
        ),
      ],
    );
  }
}

/// Vector Painter for Level Road: Draws lush rural Maharashtra landscape
/// with a winding earthen path connecting the learning nodes.
class VillageRoadPainter extends CustomPainter {
  const VillageRoadPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // 1. Pastoral Background Gradient (Sky to Meadow)
    final Rect fullRect = Offset.zero & size;
    final Paint bgPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFFE0F2FE), // Light sky blue
          Color(0xFFFEF3C7), // Sunny warmth
          Color(0xFFDCFCE7), // Soft grass
          Color(0xFFBBF7D0), // Lush field
        ],
        stops: [0.0, 0.28, 0.65, 1.0],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(fullRect);
    canvas.drawRect(fullRect, bgPaint);

    // 2. Rolling Sahyadri Hills in distance
    final Paint hillPaintFar = Paint()..color = const Color(0xFFC7D2FE).withValues(alpha: 0.6);
    final Path farHills = Path()
      ..moveTo(0, h * 0.28)
      ..quadraticBezierTo(w * 0.25, h * 0.18, w * 0.55, h * 0.25)
      ..quadraticBezierTo(w * 0.8, h * 0.16, w, h * 0.24)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(farHills, hillPaintFar);

    final Paint hillPaintNear = Paint()..color = const Color(0xFF86EFAC).withValues(alpha: 0.7);
    final Path nearHills = Path()
      ..moveTo(0, h * 0.35)
      ..quadraticBezierTo(w * 0.35, h * 0.26, w * 0.70, h * 0.36)
      ..quadraticBezierTo(w * 0.9, h * 0.30, w, h * 0.38)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(nearHills, hillPaintNear);

    // 3. Winding Clay Road (Connecting level milestones)
    final Path roadPath = Path()
      ..moveTo(w * 0.16, h * 0.90) // Level 1 start
      ..cubicTo(w * 0.35, h * 0.88, w * 0.82, h * 0.80, w * 0.76, h * 0.68) // to Level 2
      ..cubicTo(w * 0.70, h * 0.56, w * 0.22, h * 0.60, w * 0.34, h * 0.48) // to Level 3
      ..cubicTo(w * 0.44, h * 0.38, w * 0.82, h * 0.38, w * 0.72, h * 0.28) // to Level 4
      ..cubicTo(w * 0.64, h * 0.20, w * 0.30, h * 0.22, w * 0.38, h * 0.12); // to Level 5

    // Road Shadow / Depth
    final Paint roadBorder = Paint()
      ..color = const Color(0xFFD97706)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 36
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(roadPath, roadBorder);

    // Main Earthen Road Surface
    final Paint roadFill = Paint()
      ..color = const Color(0xFFFDE68A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 30
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(roadPath, roadFill);

    // Road Center Dotted Guide Line
    final Paint roadDashes = Paint()
      ..color = const Color(0xFFF59E0B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(roadPath, roadDashes);

    // 4. Little decorative village elements along the path
    final Paint treeTrunk = Paint()..color = const Color(0xFF78350F);
    final Paint treeLeaves = Paint()..color = const Color(0xFF16A34A);

    // Distant tree 1
    canvas.drawRect(Rect.fromLTWH(w * 0.08, h * 0.32, 6, 16), treeTrunk);
    canvas.drawCircle(Offset(w * 0.08 + 3, h * 0.30), 16, treeLeaves);

    // Distant tree 2
    canvas.drawRect(Rect.fromLTWH(w * 0.86, h * 0.22, 6, 18), treeTrunk);
    canvas.drawCircle(Offset(w * 0.86 + 3, h * 0.20), 18, treeLeaves);

    // Cute Grass Clumps & Flowers
    final Paint flowerYellow = Paint()..color = const Color(0xFFF59E0B);
    final Paint flowerRed = Paint()..color = const Color(0xFFEF4444);

    canvas.drawCircle(Offset(w * 0.12, h * 0.82), 4, flowerYellow);
    canvas.drawCircle(Offset(w * 0.88, h * 0.74), 4, flowerRed);
    canvas.drawCircle(Offset(w * 0.18, h * 0.58), 4, flowerYellow);
    canvas.drawCircle(Offset(w * 0.85, h * 0.44), 4, flowerRed);
    canvas.drawCircle(Offset(w * 0.22, h * 0.22), 4, flowerYellow);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
