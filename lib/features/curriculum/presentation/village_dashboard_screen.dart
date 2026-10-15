import 'package:rive/rive.dart' hide LinearGradient;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'level_play_screen.dart';
import '../../duel/duel_lobby_screen.dart';
import '../../../core/routing/boot_logic.dart';

class VillageDashboardScreen extends ConsumerWidget {
  const VillageDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentAsync = ref.watch(activeStudentProvider);

    return Scaffold(
      body: studentAsync.when(
        data: (student) {
          final screenSize = MediaQuery.of(context).size;
          
          return Stack(
            children: [
              // IgnorePointer wraps the non-interactive background elements
              IgnorePointer(
                child: Stack(
                  children: [
                    // Animated Gradient Background
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.lightBlue.shade300,
                            Colors.orange.shade300,
                          ],
                        ),
                      ),
                    ).animate(onPlay: (controller) => controller.repeat())
                     .fadeIn(duration: 2.seconds),

                    // SVG Clouds (Using Icons as vectors)
                    Positioned.fill(
                      child: Stack(
                        children: [
                          Positioned(
                            top: 80,
                            child: const Icon(Icons.cloud, color: Colors.white70, size: 100)
                                .animate(onPlay: (c) => c.repeat())
                                .moveX(begin: -100, end: screenSize.width + 100, duration: 20.seconds, curve: Curves.linear),
                          ),
                          Positioned(
                            top: 140,
                            child: const Icon(Icons.cloud, color: Colors.white54, size: 160)
                                .animate(onPlay: (c) => c.repeat())
                                .moveX(begin: -200, end: screenSize.width + 200, duration: 35.seconds, curve: Curves.linear),
                          ),
                          Positioned(
                            top: 40,
                            child: const Icon(Icons.cloud, color: Colors.white60, size: 80)
                                .animate(onPlay: (c) => c.repeat())
                                .moveX(begin: -100, end: screenSize.width + 100, duration: 15.seconds, curve: Curves.linear, delay: 5.seconds),
                          ),
                        ],
                      ),
                    ),

                    // Rive Character Placeholder
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 100),
                          SizedBox(
                            width: 300,
                            height: 300,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                // Fallback placeholder if Rive fails to load
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.purple.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: Icon(Icons.animation, size: 64, color: Colors.white54),
                                  ),
                                ),
                                RiveAnimation.asset(
                                  'assets/riv-assets/27684-52283-cute-purple-mascot-splash-screen-animation.riv',
                                  fit: BoxFit.cover,
                                ),
                              ],
                            ),
                          ).animate(onPlay: (c) => c.repeat(reverse: true))
                           .scaleXY(begin: 1.0, end: 1.02, duration: 2.seconds, curve: Curves.easeInOut)
                           .moveY(begin: 0, end: -15, duration: 2.seconds, curve: Curves.easeInOut),
                          
                          const SizedBox(height: 140), // Spacer to maintain previous layout structure
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Interactive Foreground Elements

              // App Bar / Greeting
              Positioned(
                top: 60,
                left: 24,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'नमस्कार, ${student.name}!',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(color: Colors.black45, blurRadius: 4, offset: Offset(2, 2)),
                        ],
                      ),
                    ).animate().fadeIn(duration: 800.ms).slideY(begin: -0.5, end: 0),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Chip(
                          label: Text('🌱 ${student.seedsBalance}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          backgroundColor: Colors.white.withValues(alpha: 0.9),
                        ),
                        const SizedBox(width: 8),
                        Chip(
                          label: Text('🔥 ${student.streakCount}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          backgroundColor: Colors.white.withValues(alpha: 0.9),
                        ),
                      ],
                    ).animate().fadeIn(delay: 400.ms),
                  ],
                ),
              ),

              // Start Journey Button
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 100 + 300 + 60), // Perfectly aligned below Rive
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(60), // Pill-shaped
                        ),
                        elevation: 12,
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const LevelPlayScreen(levelId: 301),
                          ),
                        );
                      },
                      child: const Text(
                        'प्रवास सुरू करा\n(Start Journey)',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ).animate(onPlay: (c) => c.repeat(reverse: true))
                     .scaleXY(begin: 1.0, end: 1.06, duration: 1500.ms, curve: Curves.easeInOut),
                  ],
                ),
              ),

              // Ganit Dangal Floating Button
              Positioned(
                bottom: 32,
                right: 32,
                child: FloatingActionButton.large(
                  heroTag: 'ganit_dangal',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const DuelLobbyScreen(),
                      ),
                    );
                  },
                  backgroundColor: Colors.orange.shade600,
                  foregroundColor: Colors.white,
                  elevation: 8,
                  child: const Icon(Icons.emoji_events, size: 48), // Trophy icon
                ).animate(onPlay: (c) => c.repeat())
                 .shake(delay: 3.seconds, duration: 600.ms, hz: 4),
              ),
            ],
          );
        },
        loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
      ),
    );
  }
}
