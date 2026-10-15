import 'package:flutter/material.dart';
import '../models/story_beat.dart';
import '../services/haptics_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'mascot_widget.dart';

/// Themed interactive scene container supporting tap-to-count and drag-to-share activities.
class StoryCard extends StatefulWidget {
  final SceneType sceneType;
  final NovaMood novaMood;
  final InteractionType interactionType;
  final int itemsToCount;
  final int itemsToShare;
  final int basketCount;
  final VoidCallback? onActivityCompleted;

  const StoryCard({
    super.key,
    required this.sceneType,
    this.novaMood = NovaMood.happy,
    this.interactionType = InteractionType.none,
    this.itemsToCount = 8,
    this.itemsToShare = 8,
    this.basketCount = 2,
    this.onActivityCompleted,
  });

  @override
  State<StoryCard> createState() => _StoryCardState();
}

class _StoryCardState extends State<StoryCard> {
  // Tap-to-count state
  int _countedItems = 0;
  final Set<int> _tappedIndices = {};

  // Drag-to-share state
  late List<int> _basketCounts;
  int _unassignedItems = 8;

  @override
  void initState() {
    super.initState();
    _resetActivities();
  }

  @override
  void didUpdateWidget(covariant StoryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.sceneType != oldWidget.sceneType ||
        widget.interactionType != oldWidget.interactionType) {
      _resetActivities();
    }
  }

  void _resetActivities() {
    _countedItems = 0;
    _tappedIndices.clear();
    _unassignedItems = widget.itemsToShare;
    _basketCounts = List.filled(widget.basketCount, 0);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 240,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        gradient: _getSceneGradient(widget.sceneType),
        borderRadius: AppSpacing.roundedCard,
        border: Border.all(color: AppColors.borderLight, width: 2.0),
        boxShadow: AppSpacing.softShadow,
      ),
      child: ClipRRect(
        borderRadius: AppSpacing.roundedCard,
        child: Stack(
          children: [
            // Background scenery elements
            _buildSceneryElements(widget.sceneType),

            // Active Interactive activity if enabled
            if (widget.interactionType == InteractionType.tapToCount)
              _buildTapToCountLayer()
            else if (widget.interactionType == InteractionType.dragToShare)
              _buildDragToShareLayer(),

            // NOVA mascot positioned on the left or bottom-left
            Positioned(
              left: 16,
              bottom: 12,
              child: MascotWidget(
                size: 88,
                mood: widget.novaMood,
                showGlow: widget.novaMood == NovaMood.celebrating,
              ),
            ),
          ],
        ),
      ),
    );
  }

  LinearGradient _getSceneGradient(SceneType type) {
    switch (type) {
      case SceneType.observatory:
        return const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      case SceneType.garden:
        return const LinearGradient(
          colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      case SceneType.market:
        return const LinearGradient(
          colors: [Color(0xFFFFF7ED), Color(0xFFFFEDD5)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      case SceneType.factory:
        return const LinearGradient(
          colors: [Color(0xFFF1F5F9), Color(0xFFE2E8F0)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      case SceneType.cave:
        return const LinearGradient(
          colors: [Color(0xFF1E1B4B), Color(0xFF312E81)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      case SceneType.treasure:
        return const LinearGradient(
          colors: [Color(0xFFFEF3C7), Color(0xFFFDE68A)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      case SceneType.general:
        return const LinearGradient(
          colors: [Color(0xFFF3F8FF), Color(0xFFE0EDFD)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
    }
  }

  Widget _buildSceneryElements(SceneType type) {
    switch (type) {
      case SceneType.observatory:
        return const Positioned(
          top: 15,
          right: 20,
          child: Text('🔭 🌙 ⭐ 🪐', style: TextStyle(fontSize: 26)),
        );
      case SceneType.garden:
        return const Positioned(
          top: 10,
          right: 20,
          child: Text('🌳 🌸 🦋 ☀️', style: TextStyle(fontSize: 26)),
        );
      case SceneType.market:
        return const Positioned(
          top: 10,
          right: 20,
          child: Text('🥭 🍊 🍉 🛒', style: TextStyle(fontSize: 26)),
        );
      case SceneType.factory:
        return const Positioned(
          top: 10,
          right: 20,
          child: Text('⚙️ 🤖 ⚡ 📦', style: TextStyle(fontSize: 26)),
        );
      case SceneType.cave:
        return const Positioned(
          top: 10,
          right: 20,
          child: Text('💎 🔮 ✨ 🦇', style: TextStyle(fontSize: 26)),
        );
      case SceneType.treasure:
        return const Positioned(
          top: 10,
          right: 20,
          child: Text('🏴‍☠️ 🗺️ 🪙 💎', style: TextStyle(fontSize: 26)),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildTapToCountLayer() {
    return Positioned(
      top: 45,
      right: 15,
      left: 110,
      bottom: 15,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: AppSpacing.softShadow,
            ),
            child: Text(
              'Counted: $_countedItems / ${widget.itemsToCount} ⭐',
              style: AppTextStyles.label.copyWith(
                color: AppColors.indigo,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.end,
              children: List.generate(widget.itemsToCount, (i) {
                final bool tapped = _tappedIndices.contains(i);
                return GestureDetector(
                  onTap: () {
                    if (!tapped) {
                      HapticsService.lightImpact();
                      setState(() {
                        _tappedIndices.add(i);
                        _countedItems++;
                      });
                      if (_countedItems >= widget.itemsToCount) {
                        widget.onActivityCompleted?.call();
                      }
                    }
                  },
                  child: AnimatedScale(
                    scale: tapped ? 1.3 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.elasticOut,
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: tapped ? AppColors.mint.withValues(alpha: 0.3) : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: tapped ? AppColors.mint : AppColors.borderLight,
                          width: 2,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        widget.sceneType == SceneType.garden ? '🍎' : '⭐',
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDragToShareLayer() {
    return Positioned(
      top: 40,
      right: 15,
      left: 110,
      bottom: 10,
      child: Column(
        children: [
          // Remaining unassigned items source
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Remaining: $_unassignedItems 🍎',
                style: AppTextStyles.label.copyWith(fontWeight: FontWeight.bold, color: AppColors.navy),
              ),
              const SizedBox(width: 8),
              if (_unassignedItems > 0)
                Draggable<int>(
                  data: 1,
                  feedback: Material(
                    color: Colors.transparent,
                    child: const Text('🍎', style: TextStyle(fontSize: 36)),
                  ),
                  childWhenDragging: Opacity(
                    opacity: 0.3,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: const Text('🍎', style: TextStyle(fontSize: 26)),
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: const Text('🍎', style: TextStyle(fontSize: 26)),
                  ),
                ),
            ],
          ),
          const Spacer(),
          // Baskets (DragTargets)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(widget.basketCount, (basketIdx) {
              return DragTarget<int>(
                onAcceptWithDetails: (details) {
                  if (_unassignedItems > 0) {
                    HapticsService.lightImpact();
                    setState(() {
                      _unassignedItems--;
                      _basketCounts[basketIdx]++;
                    });
                    if (_unassignedItems == 0) {
                      widget.onActivityCompleted?.call();
                    }
                  }
                },
                builder: (context, candidateData, rejectedData) {
                  final bool isHovered = candidateData.isNotEmpty;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(8),
                    width: 72,
                    height: 80,
                    decoration: BoxDecoration(
                      color: isHovered ? const Color(0xFFFEF08A) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isHovered ? AppColors.sunYellow : AppColors.borderLight,
                        width: 2.2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('🧺', style: TextStyle(fontSize: 26)),
                        Text(
                          '${_basketCounts[basketIdx]}',
                          style: AppTextStyles.label.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AppColors.navy,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
