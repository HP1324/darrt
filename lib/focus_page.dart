import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;

enum TimerMode { focus, shortBreak, longBreak }

class FocusTimerPage extends StatefulWidget {
  const FocusTimerPage({Key? key}) : super(key: key);

  @override
  State<FocusTimerPage> createState() => _FocusTimerPageState();
}

class _FocusTimerPageState extends State<FocusTimerPage>
    with TickerProviderStateMixin {
  Timer? _timer;
  TimerMode _currentMode = TimerMode.focus;
  int _completedPomodoros = 0;

  // Timer durations (in seconds)
  int _focusTime = 25 * 60;
  int _shortBreakTime = 5 * 60;
  int _longBreakTime = 15 * 60;

  int _remainingSeconds = 25 * 60;
  bool _isRunning = false;
  bool _isPaused = false;

  late AnimationController _pulseController;
  late AnimationController _glowController;
  late AnimationController _modeTransitionController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _modeTransition;

  final List<int> _focusPresets = [15, 25, 45, 60]; // minutes
  final List<int> _shortBreakPresets = [5, 10, 15]; // minutes
  final List<int> _longBreakPresets = [15, 20, 30]; // minutes

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _resetTimer();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _glowController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _modeTransitionController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    _modeTransition = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _modeTransitionController,
      curve: Curves.elasticOut,
    ));

    _pulseController.repeat(reverse: true);
    _glowController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _glowController.dispose();
    _modeTransitionController.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (_remainingSeconds <= 0) return;

    setState(() {
      _isRunning = true;
      _isPaused = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _onTimerComplete();
        }
      });
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isPaused = true;
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isPaused = false;
    });
    _resetTimer();
  }

  void _resetTimer() {
    setState(() {
      _remainingSeconds = _getCurrentDuration();
    });
  }

  void _onTimerComplete() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isPaused = false;
    });

    if (_currentMode == TimerMode.focus) {
      _completedPomodoros++;
      // After 4 focus sessions, suggest long break
      TimerMode nextMode = (_completedPomodoros % 4 == 0)
          ? TimerMode.longBreak
          : TimerMode.shortBreak;

      _showCompletionDialog(nextMode);
    } else {
      // Break completed, suggest focus
      _showCompletionDialog(TimerMode.focus);
    }
  }

  void _switchMode(TimerMode newMode) {
    if (_isRunning || _isPaused) {
      _stopTimer();
    }

    setState(() {
      _currentMode = newMode;
    });

    _modeTransitionController.forward().then((_) {
      _modeTransitionController.reverse();
    });

    _resetTimer();
  }

  int _getCurrentDuration() {
    switch (_currentMode) {
      case TimerMode.focus:
        return _focusTime;
      case TimerMode.shortBreak:
        return _shortBreakTime;
      case TimerMode.longBreak:
        return _longBreakTime;
    }
  }

  void _setDuration(int seconds) {
    _stopTimer();
    setState(() {
      switch (_currentMode) {
        case TimerMode.focus:
          _focusTime = seconds;
          break;
        case TimerMode.shortBreak:
          _shortBreakTime = seconds;
          break;
        case TimerMode.longBreak:
          _longBreakTime = seconds;
          break;
      }
    });
    _resetTimer();
  }

  List<int> _getCurrentPresets() {
    switch (_currentMode) {
      case TimerMode.focus:
        return _focusPresets;
      case TimerMode.shortBreak:
        return _shortBreakPresets;
      case TimerMode.longBreak:
        return _longBreakPresets;
    }
  }

  void _showCompletionDialog(TimerMode suggestedNext) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final colorScheme = Theme.of(context).colorScheme;
        final textTheme = Theme.of(context).textTheme;

        String title, message, actionText;
        IconData icon;

        if (_currentMode == TimerMode.focus) {
          title = '🎉 Focus Session Complete!';
          message = _completedPomodoros % 4 == 0
              ? 'Great work! You\'ve completed ${_completedPomodoros} sessions. Time for a longer break!'
              : 'Excellent focus! You\'ve completed ${_completedPomodoros} sessions. Ready for a short break?';
          actionText = suggestedNext == TimerMode.longBreak ? 'Take Long Break' : 'Take Short Break';
          icon = Icons.coffee;
        } else {
          title = '✨ Break Complete!';
          message = 'Hope you feel refreshed! Ready to get back to focused work?';
          actionText = 'Start Focus Session';
          icon = Icons.psychology;
        }

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            title,
            style: textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 48,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              if (_completedPomodoros > 0) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Total Sessions: $_completedPomodoros',
                    style: textTheme.labelLarge?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetTimer();
              },
              child: Text(
                'Not Now',
                style: textTheme.labelLarge?.copyWith(
                  color: colorScheme.outline,
                ),
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                _switchMode(suggestedNext);
              },
              child: Text(actionText),
            ),
          ],
        );
      },
    );
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  double get _progress => 1.0 - (_remainingSeconds / _getCurrentDuration());

  Color _getModeColor(ColorScheme colorScheme) {
    switch (_currentMode) {
      case TimerMode.focus:
        return colorScheme.primary;
      case TimerMode.shortBreak:
        return colorScheme.secondary;
      case TimerMode.longBreak:
        return colorScheme.tertiary;
    }
  }

  String _getModeTitle() {
    switch (_currentMode) {
      case TimerMode.focus:
        return 'Focus Time';
      case TimerMode.shortBreak:
        return 'Short Break';
      case TimerMode.longBreak:
        return 'Long Break';
    }
  }

  String _getModeSubtitle() {
    switch (_currentMode) {
      case TimerMode.focus:
        return _isRunning
            ? 'Stay focused and productive!'
            : _isPaused
            ? 'Paused - Ready to continue?'
            : 'Ready to focus?';
      case TimerMode.shortBreak:
        return _isRunning
            ? 'Relax and recharge!'
            : _isPaused
            ? 'Paused - Take your time'
            : 'Time for a quick break';
      case TimerMode.longBreak:
        return _isRunning
            ? 'Enjoy your well-deserved break!'
            : _isPaused
            ? 'Paused - Rest when ready'
            : 'You\'ve earned a longer break';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;
    final modeColor = _getModeColor(colorScheme);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 16.0 : 32.0),
            child: Column(
              children: [
                // Header with mode tabs
                Container(
                  margin: const EdgeInsets.only(bottom: 32),
                  child: Column(
                    children: [
                      Text(
                        _getModeTitle(),
                        style: textTheme.headlineLarge?.copyWith(
                          color: modeColor,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getModeSubtitle(),
                        style: textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (_completedPomodoros > 0) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '🍅 $_completedPomodoros sessions completed',
                            style: textTheme.labelMedium?.copyWith(
                              color: colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Mode Selection Tabs
                Container(
                  margin: const EdgeInsets.only(bottom: 32),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: TimerMode.values.map((mode) {
                      final isSelected = _currentMode == mode;
                      String label;
                      IconData icon;

                      switch (mode) {
                        case TimerMode.focus:
                          label = 'Focus';
                          icon = Icons.psychology;
                          break;
                        case TimerMode.shortBreak:
                          label = 'Short Break';
                          icon = Icons.coffee;
                          break;
                        case TimerMode.longBreak:
                          label = 'Long Break';
                          icon = Icons.self_improvement;
                          break;
                      }

                      return Expanded(
                        child: InkWell(
                          onTap: () => _switchMode(mode),
                          borderRadius: BorderRadius.circular(12),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.all(4),
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? _getModeColor(colorScheme)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  icon,
                                  size: 20,
                                  color: isSelected
                                      ? colorScheme.onPrimary
                                      : colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  label,
                                  style: textTheme.labelSmall?.copyWith(
                                    color: isSelected
                                        ? colorScheme.onPrimary
                                        : colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // Timer Circle
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 40),
                  child: AnimatedBuilder(
                    animation: Listenable.merge([
                      _pulseAnimation,
                      _glowAnimation,
                      _modeTransition,
                    ]),
                    builder: (context, child) {
                      return Transform.scale(
                        scale: (_isRunning ? _pulseAnimation.value : 1.0) *
                            (1.0 + _modeTransition.value * 0.1),
                        child: Container(
                          width: math.min(size.width * 0.8, 320),
                          height: math.min(size.width * 0.8, 320),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              if (_isRunning)
                                BoxShadow(
                                  color: modeColor.withValues(
                                    alpha: 0.3 * _glowAnimation.value,
                                  ),
                                  blurRadius: 40,
                                  spreadRadius: 10,
                                ),
                            ],
                          ),
                          child: CustomPaint(
                            painter: TimerPainter(
                              progress: _progress,
                              backgroundColor: colorScheme.outline.withValues(alpha: 0.2),
                              progressColor: modeColor,
                              strokeWidth: 12,
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _formatTime(_remainingSeconds),
                                    style: textTheme.displayLarge?.copyWith(
                                      color: colorScheme.onSurface,
                                      fontWeight: FontWeight.w200,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${(_getCurrentDuration() / 60).round()} min ${_currentMode.name}',
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Control Buttons
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Stop Button
                      if (_isRunning || _isPaused)
                        Flexible(
                          child: Container(
                            margin: const EdgeInsets.only(right: 16),
                            child: FloatingActionButton(
                              onPressed: _stopTimer,
                              backgroundColor: colorScheme.errorContainer,
                              foregroundColor: colorScheme.onErrorContainer,
                              heroTag: "stop",
                              child: const Icon(Icons.stop),
                            ),
                          ),
                        ),

                      // Play/Pause Button
                      Flexible(
                        child: FloatingActionButton.extended(
                          onPressed: _isRunning ? _pauseTimer : _startTimer,
                          backgroundColor: modeColor.withValues(alpha: 0.9),
                          foregroundColor: colorScheme.onPrimary,
                          heroTag: "playPause",
                          icon: Icon(
                            _isRunning ? Icons.pause : Icons.play_arrow,
                            size: 28,
                          ),
                          label: Text(
                            _isRunning ? 'Pause' : _isPaused ? 'Resume' : 'Start',
                            style: textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Preset Time Buttons
                if (!_isRunning && !_isPaused) ...[
                  const SizedBox(height: 48), // Added more space here
                  Text(
                    'Quick Setup',
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: _getCurrentPresets().map((minutes) {
                      final isSelected = _getCurrentDuration() == minutes * 60;
                      return InkWell(
                        onTap: () => _setDuration(minutes * 60),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: isSelected
                                ? modeColor
                                : colorScheme.surfaceVariant,
                            border: Border.all(
                              color: isSelected
                                  ? modeColor
                                  : colorScheme.outline.withValues(alpha: 0.2),
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            '${minutes}m',
                            style: textTheme.labelLarge?.copyWith(
                              color: isSelected
                                  ? colorScheme.onPrimary
                                  : colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 64), // Added bottom spacing
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TimerPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;
  final double strokeWidth;

  TimerPainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = progressColor
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      const startAngle = -math.pi / 2; // Start from top
      final sweepAngle = 2 * math.pi * progress;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(TimerPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}