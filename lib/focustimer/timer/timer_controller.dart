// timer_controller.dart
import 'dart:async';
import 'dart:convert';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:darrt/helpers/consts.dart';
import 'package:flutter/foundation.dart';
import 'package:darrt/app/services/mini_box.dart';
import 'package:darrt/helpers/mini_logger.dart';

import '../../helpers/globals.dart' as g;
import '../../task/models/task.dart' show Task;

enum TimerType { focus, timerBreak }

enum TimerState { idle, running, paused, completed }

class TimerController extends ChangeNotifier {
  static const String _timerStateKey = 'timer_state';
  static const String _timerTypeKey = 'timer_type';
  static const String _startTimeKey = 'start_time';
  static const String _durationKey = 'duration';
  static const String _pausedTimeKey = 'paused_time';
  static const String _focusDurationKey = 'focus_duration';
  static const String _breakDurationKey = 'break_duration';

  // Default durations in seconds
  static const int defaultFocusDuration = 25 * 60; // 25 minutes
  static const int defaultBreakDuration = 5 * 60; // 5 minutes

  Timer? _ticker;
  TimerState _state = TimerState.idle;
  TimerType _currentType = TimerType.focus;
  int _focusDuration = defaultFocusDuration;
  int _breakDuration = defaultBreakDuration;
  int _remainingSeconds = defaultFocusDuration;
  DateTime? _startTime;
  int _pausedSeconds = 0;

  // Getters
  TimerState get state => _state;
  TimerType get currentType => _currentType;
  int get focusDuration => _focusDuration;
  int get breakDuration => _breakDuration;
  int get remainingSeconds => _remainingSeconds;
  int get currentDuration => _currentType == TimerType.focus ? _focusDuration : _breakDuration;
  double get progress => 1.0 - (_remainingSeconds / currentDuration);
  bool get isRunning => _state == TimerState.running;
  bool get isPaused => _state == TimerState.paused;
  bool get isCompleted => _state == TimerState.completed;
  bool get isIdle => _state == TimerState.idle;


  String get timerTypeLabel => _currentType == TimerType.focus ? 'Focus Mode' : 'Break';

  TimerController() {
    _initializeFromStorage();
  }

  void _initializeFromStorage() {
    try {
      final stateStr = MiniBox().read(_timerStateKey);
      final typeStr = MiniBox().read(_timerTypeKey);
      final startTimeStr = MiniBox().read(_startTimeKey);
      final durationStr = MiniBox().read(_durationKey);
      final pausedTimeStr = MiniBox().read(_pausedTimeKey);
      final focusDurStr = MiniBox().read(_focusDurationKey);
      final breakDurStr = MiniBox().read(_breakDurationKey);

      if (focusDurStr != null) {
        _focusDuration = int.parse(focusDurStr);
      }
      if (breakDurStr != null) {
        _breakDuration = int.parse(breakDurStr);
      }
      if (stateStr != null && typeStr != null) {
        _state = TimerState.values.firstWhere(
          (e) => e.toString() == stateStr,
          orElse: () => TimerState.idle,
        );
        _currentType = TimerType.values.firstWhere(
          (e) => e.toString() == typeStr,
          orElse: () => TimerType.focus,
        );

        if (_state == TimerState.running && startTimeStr != null && durationStr != null) {
          _startTime = DateTime.parse(startTimeStr);
          final totalDuration = int.parse(durationStr);
          final elapsed = DateTime.now().difference(_startTime!).inSeconds;
          _remainingSeconds = totalDuration - elapsed;

          if (_remainingSeconds <= 0) {
            stopTimer();
            if (MiniBox().read(mPauseResumeSoundWithTimer)) {
              g.audioController.pauseAudio();
            }
          } else {
            _startTicker();
          }
        } else if (_state == TimerState.paused && pausedTimeStr != null) {
          _remainingSeconds = int.parse(pausedTimeStr);
          _pausedSeconds = _remainingSeconds;
        } else if (_state == TimerState.completed) {
          _remainingSeconds = 0;
        } else {
          _remainingSeconds = currentDuration;
        }
      } else {
        _remainingSeconds = currentDuration;
      }
      _loadSelectedTasksFromStorage();
    } catch (e) {
      MiniLogger.dp('Error initializing timer from storage: $e');
      _resetToDefaults();
    }
    notifyListeners();
  }

  // Modify your existing _resetToDefaults method:
  void _resetToDefaults() {
    _state = TimerState.idle;
    _currentType = TimerType.focus;
    _remainingSeconds = currentDuration;
    _startTime = null;
    _pausedSeconds = 0;
    _selectedTasks.clear(); // Clear selected tasks too
    _clearStorage();
  }

  // Modify your existing _clearStorage method:
  void _clearStorage() {
    try {
      MiniBox().remove(_timerStateKey);
      MiniBox().remove(_timerTypeKey);
      MiniBox().remove(_startTimeKey);
      MiniBox().remove(_durationKey);
      MiniBox().remove(_pausedTimeKey);
      MiniBox().remove(_selectedTasksKey); // Add this line
    } catch (e) {
      MiniLogger.dp('Error clearing timer storage: $e');
    }
  }

  void _saveToStorage() {
    try {
      MiniBox().write(_timerStateKey, _state.toString());
      MiniBox().write(_timerTypeKey, _currentType.toString());
      MiniBox().write(_focusDurationKey, _focusDuration.toString());
      MiniBox().write(_breakDurationKey, _breakDuration.toString());

      if (_state == TimerState.running && _startTime != null) {
        MiniBox().write(_startTimeKey, _startTime!.toIso8601String());
        MiniBox().write(_durationKey, currentDuration.toString());
      } else if (_state == TimerState.paused) {
        MiniBox().write(_pausedTimeKey, _remainingSeconds.toString());
      }
    } catch (e) {
      MiniLogger.dp('Error saving timer to storage: $e');
    }
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_startTime != null) {
        final elapsed = DateTime.now().difference(_startTime!).inSeconds;
        _remainingSeconds = currentDuration - elapsed;

        if (_remainingSeconds <= 0) {
          _handleTimerCompletion();
        } else {
          _updatePersistentNotification();
          notifyListeners();
        }
      }
    });
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  void _completeTimer() {
    _stopTicker();
    _state = TimerState.completed;
    _remainingSeconds = 0;
    _startTime = null;
    _saveToStorage();
    notifyListeners();
  }

  void pauseTimer() {
    if (_state == TimerState.running) {
      _stopTicker();
      _state = TimerState.paused;
      _pausedSeconds = _remainingSeconds;
      _startTime = null;
      _saveToStorage();
      _updatePersistentNotification();
      notifyListeners();
    }
  }

  void startTimer() {
    if (_state == TimerState.idle) {
      _remainingSeconds = currentDuration;
      _startTime = DateTime.now();
    } else if (_state == TimerState.paused) {
      _startTime = DateTime.now().subtract(Duration(seconds: currentDuration - _pausedSeconds));
    }

    _state = TimerState.running;
    _startTicker();
    _saveToStorage();
    _updatePersistentNotification();
    notifyListeners();
  }

  void stopTimer() {
    _stopTicker();
    _state = TimerState.idle;
    _remainingSeconds = currentDuration;
    _startTime = null;
    _pausedSeconds = 0;
    _saveToStorage();
    _updatePersistentNotification();
    notifyListeners();
  }

  void resetTimer() {
    _stopTicker();
    _state = TimerState.idle;
    _remainingSeconds = currentDuration;
    _startTime = null;
    _pausedSeconds = 0;
    _saveToStorage();
    _updatePersistentNotification();
    notifyListeners();
  }

  void switchToFocus() {
    if (_currentType != TimerType.focus) {
      _stopTicker();
      _currentType = TimerType.focus;
      _state = TimerState.idle;
      _remainingSeconds = _focusDuration;
      _startTime = null;
      _pausedSeconds = 0;
      _saveToStorage();
      _updatePersistentNotification();
      notifyListeners();
    }
  }

  void switchToBreak() {
    if (_currentType != TimerType.timerBreak) {
      _stopTicker();
      _currentType = TimerType.timerBreak;
      _state = TimerState.idle;
      _remainingSeconds = _breakDuration;
      _startTime = null;
      _pausedSeconds = 0;
      _saveToStorage();
      _updatePersistentNotification();
      notifyListeners();
    }
  }

  void setFocusDuration(int seconds) {
    _focusDuration = seconds;
    if (_currentType == TimerType.focus && _state == TimerState.idle) {
      _remainingSeconds = _focusDuration;
    }
    _saveToStorage();
    notifyListeners();
  }

  void setBreakDuration(int seconds) {
    _breakDuration = seconds;
    if (_currentType == TimerType.timerBreak && _state == TimerState.idle) {
      _remainingSeconds = _breakDuration;
    }
    _saveToStorage();
    notifyListeners();
  }

  void continueAfterCompletion() {
    if (_state == TimerState.completed) {
      _state = TimerState.idle;
      _remainingSeconds = currentDuration;
      _saveToStorage();
      notifyListeners();
    }
  }

  static const String _selectedTasksKey = 'selected_tasks';

  // Modify the existing task selection code:
  final List<Task> _selectedTasks = [];

  List<Task> get selectedTasks => _selectedTasks;

  void addTask(Task task) {
    if (!_selectedTasks.contains(task)) {
      _selectedTasks.add(task);
      _saveSelectedTasksToStorage();
      notifyListeners();
    }
  }

  void removeTask(dynamic task) {
    _selectedTasks.remove(task);
    _saveSelectedTasksToStorage();
    notifyListeners();
  }

  void clearSelectedTasks() {
    _selectedTasks.clear();
    _saveSelectedTasksToStorage();
    notifyListeners();
  }

  bool isTaskSelected(Task task) {
    return _selectedTasks.contains(task);
  }

  int get selectedTasksCount => _selectedTasks.length;

  void toggleTaskSelection(dynamic task) {
    if (isTaskSelected(task)) {
      removeTask(task);
    } else {
      addTask(task);
    }
  }

  // Add these new methods for persistent storage:

  void _saveSelectedTasksToStorage() {
    try {
      // Convert tasks to JSON strings for storage
      final taskJsonList = _selectedTasks.map((task) => task.toJson()).toList();
      final jsonString = jsonEncode(taskJsonList);
      MiniBox().write(_selectedTasksKey, jsonString);
    } catch (e) {
      MiniLogger.dp('Error saving selected tasks to storage: $e');
    }
  }

  void _loadSelectedTasksFromStorage() {
    try {
      final jsonString = MiniBox().read(_selectedTasksKey);
      if (jsonString != null) {
        final List<dynamic> taskJsonList = jsonDecode(jsonString);
        _selectedTasks.clear();
        for (final taskJson in taskJsonList) {
          try {
            final task = Task.fromJson(taskJson);
            _selectedTasks.add(task);
          } catch (e) {
            MiniLogger.dp('Error parsing task from storage: $e');
          }
        }
      }
    } catch (e) {
      MiniLogger.dp('Error loading selected tasks from storage: $e');
      _selectedTasks.clear();
    }
  }

  void _handleTimerCompletion() {
    if (currentType == TimerType.focus) {
      final autoSwitchToBreak = MiniBox().read(mAutoSwitchToBreak);
      if (autoSwitchToBreak ?? false) {
        Future.delayed(const Duration(milliseconds: 700), () {
          switchToBreak();
          startTimer();
        });
      } else {
        stopTimer();
        if (MiniBox().read(mPauseResumeSoundWithTimer) ?? true) {
          g.audioController.pauseAudio();
        }
      }
      g.audioController.playSoundOnly('assets/sounds/focus_timer_end.mp3');
      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: DateTime.now().millisecondsSinceEpoch.remainder(1000000),
          channelKey: timerChannelKey,
          title: "⏳ Focus Session Complete!",
          body: "Great job! Time to relax and recharge 🌿",
          criticalAlert: true,
          wakeUpScreen: true,

        ),
      );
    } else {
      final autoSwitchToFocus = MiniBox().read(mAutoSwitchToFocus);
      if (autoSwitchToFocus ?? false) {
        Future.delayed(const Duration(milliseconds: 700), () {
          switchToFocus();
          startTimer();
        });
      } else {
        stopTimer();
        if (MiniBox().read(mPauseResumeSoundWithTimer) ?? true) {
          g.audioController.pauseAudio();
        }
      }
      g.audioController.playSoundOnly('assets/sounds/break_timer_end.mp3');
      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: DateTime.now().millisecondsSinceEpoch.remainder(1000000),
          channelKey: timerChannelKey,
          title: "🚨 Break’s Over!",
          body: "Let’s get moving and refocus your energy! 💪",
          criticalAlert: true,
          wakeUpScreen: true,
        ),
      );
    }
  }
  Future<void> _updatePersistentNotification() async {
    if(!MiniBox().read(mShowTimerNotification)) return;
    if (_state == TimerState.idle || _state == TimerState.completed) {
      await AwesomeNotifications().cancel(999); // 999: fixed ID for persistent
      return;
    }

    final typeLabel = _currentType == TimerType.focus ? 'Focus' : 'Break';
    final stateLabel = _state == TimerState.paused ? '⏸️ Paused' : '▶️ Running';
    final title = typeLabel == 'Focus' ? 'Focus session - $stateLabel' : 'Taking a break';
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 999, // Use a fixed ID for updating
        channelKey: timerChannelKey,
        title: title,
        body: 'Time left: $formattedTime',
        category: NotificationCategory.Status,
        notificationLayout: NotificationLayout.Default,
        wakeUpScreen: true,
        criticalAlert: true,
        autoDismissible: false,
        locked: true,
      ),
    );
  }
  String get formattedTime {
    final hours = _remainingSeconds ~/ 3600;
    final minutes = (_remainingSeconds % 3600) ~/ 60;
    final seconds = _remainingSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  @override
  void dispose() {
    _stopTicker();
    super.dispose();
  }
}
