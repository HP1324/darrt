import 'dart:math' as math;

import 'package:confetti/confetti.dart';
import 'package:darrt/task/statistics/achievements.dart';
import 'package:flutter/material.dart';

class AchievementDialog extends StatefulWidget {
  final Achievement achievement;
  final int currentStreak;

  const AchievementDialog({
    super.key,
    required this.achievement,
    required this.currentStreak,
  });

  @override
  State<AchievementDialog> createState() => _AchievementDialogState();
}

class _AchievementDialogState extends State<AchievementDialog> with TickerProviderStateMixin {
  late ConfettiController _confettiControllerLeft;
  late ConfettiController _confettiControllerRight;
  late ConfettiController _confettiControllerTop;
  late ConfettiController _confettiControllerBottom;
  late AnimationController _scaleController;
  late AnimationController _rotationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize multiple confetti controllers for different directions
    _confettiControllerLeft = ConfettiController(duration: const Duration(seconds: 3));
    _confettiControllerRight = ConfettiController(duration: const Duration(seconds: 3));
    _confettiControllerTop = ConfettiController(duration: const Duration(seconds: 3));
    _confettiControllerBottom = ConfettiController(duration: const Duration(seconds: 3));

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation =
        Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: _scaleController,
            curve: Curves.elasticOut,
          ),
        );

    _rotationAnimation =
        Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: _rotationController,
            curve: Curves.easeInOut,
          ),
        );

    _startAnimations();
  }

  void _startAnimations() {
    // Start all confetti controllers
    _confettiControllerLeft.play();
    _confettiControllerRight.play();
    _confettiControllerTop.play();
    _confettiControllerBottom.play();

    _scaleController.forward();
    _rotationController.forward();
  }

  @override
  void dispose() {
    _confettiControllerLeft.dispose();
    _confettiControllerRight.dispose();
    _confettiControllerTop.dispose();
    _confettiControllerBottom.dispose();
    _scaleController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    final textTheme = TextTheme.of(context);

    return Stack(
      children: [
        Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  widget.achievement.color.withValues(alpha: 0.1),
                  colorScheme.surface,
                  widget.achievement.color.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: widget.achievement.color.withValues(alpha: 0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _scaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: child,
                    );
                  },
                  child: AnimatedBuilder(
                    animation: _rotationAnimation,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _rotationAnimation.value * 2 * math.pi,
                        child: child,
                      );
                    },
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: widget.achievement.color,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: widget.achievement.color.withValues(alpha: 0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        widget.achievement.icon,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Achievement Unlocked!',
                  style: textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: widget.achievement.color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: widget.achievement.color.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Text(
                    widget.achievement.rank,
                    style: textTheme.bodyMedium?.copyWith(
                      color: widget.achievement.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.achievement.title,
                  style: textTheme.titleLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  widget.achievement.description,
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(widget.achievement.color)),
                      child: Text('Continue',style: TextStyle(color: colorScheme.onPrimaryContainer)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Confetti from left side
        Positioned(
          top: MediaQuery.of(context).size.height * 0.3,
          left: 0,
          child: ConfettiWidget(
            confettiController: _confettiControllerLeft,
            blastDirection: 0, // Blast to the right
            emissionFrequency: 0.05,
            numberOfParticles: 50,
            maxBlastForce: 80,
            minBlastForce: 60,
            gravity: 0.1,
            colors: [
              widget.achievement.color,
              colorScheme.primary,
              colorScheme.secondary,
              colorScheme.tertiary,
              Colors.yellow,
              Colors.orange,
              Colors.pink,
            ],
          ),
        ),

        // Confetti from right side
        Positioned(
          top: MediaQuery.of(context).size.height * 0.3,
          right: 0,
          child: ConfettiWidget(
            confettiController: _confettiControllerRight,
            blastDirection: math.pi, // Blast to the left
            emissionFrequency: 0.05,
            numberOfParticles: 50,
            maxBlastForce: 80,
            minBlastForce: 60,
            gravity: 0.1,
            colors: [
              widget.achievement.color,
              colorScheme.primary,
              colorScheme.secondary,
              colorScheme.tertiary,
              Colors.yellow,
              Colors.orange,
              Colors.pink,
            ],
          ),
        ),

        // Confetti from top center
        Positioned(
          top: 0,
          left: MediaQuery.of(context).size.width * 0.5,
          child: ConfettiWidget(
            confettiController: _confettiControllerTop,
            blastDirection: math.pi / 2, // Blast downward
            blastDirectionality: BlastDirectionality.explosive, // Spread in multiple directions
            emissionFrequency: 0.03,
            numberOfParticles: 80,
            maxBlastForce: 120,
            minBlastForce: 100,
            gravity: 0.08,
            colors: [
              widget.achievement.color,
              colorScheme.primary,
              colorScheme.secondary,
              colorScheme.tertiary,
              Colors.yellow,
              Colors.orange,
              Colors.pink,
            ],
          ),
        ),

        // Confetti from bottom center (for extra effect)
        Positioned(
          bottom: 0,
          left: MediaQuery.of(context).size.width * 0.5,
          child: ConfettiWidget(
            confettiController: _confettiControllerBottom,
            blastDirection: -math.pi / 2, // Blast upward
            blastDirectionality: BlastDirectionality.explosive, // Spread in multiple directions
            emissionFrequency: 0.02,
            numberOfParticles: 30,
            maxBlastForce: 60,
            minBlastForce: 40,
            gravity: 0.5, // Negative gravity to make it fall back down
            colors: [
              widget.achievement.color,
              colorScheme.primary,
              colorScheme.secondary,
              colorScheme.tertiary,
              Colors.yellow,
              Colors.orange,
              Colors.pink,
            ],
          ),
        ),
      ],
    );
  }
}

// Helper function to show achievement dialog
Future<void> showAchievementDialog(
  BuildContext context,
  Achievement achievement,
  int currentStreak,
) async {
  return await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AchievementDialog(
      achievement: achievement,
      currentStreak: currentStreak,
    ),
  );
}
