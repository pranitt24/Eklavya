import 'package:flutter/material.dart';
import '../services/app_state.dart';
import '../services/haptics_service.dart';
import '../theme/app_colors.dart';
import 'demo_controls.dart';

/// Draggable floating "🛠 Demo" button overlay available on all screens for evaluators.
class DemoFab extends StatefulWidget {
  const DemoFab({super.key});

  @override
  State<DemoFab> createState() => _DemoFabState();
}

class _DemoFabState extends State<DemoFab> {
  Offset? _position;

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    if (!appState.showDemoFab) return const SizedBox.shrink();

    final screenSize = MediaQuery.of(context).size;
    final bool isLandscape = screenSize.width > screenSize.height;

    // Default to an unobtrusive corner: top-right in landscape, bottom-right in portrait
    final Offset currentPos = _position ??
        (isLandscape
            ? Offset(screenSize.width - 94.0, 10.0)
            : Offset(screenSize.width - 94.0, screenSize.height - 100.0));

    final double clampedX = currentPos.dx.clamp(8.0, (screenSize.width - 94.0).clamp(8.0, 9999.0));
    final double clampedY = currentPos.dy.clamp(
      isLandscape ? 8.0 : 48.0,
      (screenSize.height - 48.0).clamp(8.0, 9999.0),
    );

    return Positioned(
      left: clampedX,
      top: clampedY,
      child: SafeArea(
        child: GestureDetector(
          onPanUpdate: (details) {
            setState(() {
              _position = Offset(clampedX, clampedY) + details.delta;
            });
          },
          child: Material(
            elevation: 4,
            shape: const StadiumBorder(),
            color: AppColors.navy.withValues(alpha: 0.92),
            child: InkWell(
              customBorder: const StadiumBorder(),
              onTap: () {
                HapticsService.lightImpact();
                DemoControlsSheet.show(context);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.build_circle_rounded, color: AppColors.sunYellow, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Demo',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
