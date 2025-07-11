// timer_controller.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:minimaltodo/app/services/mini_box.dart';

import '../../helpers/globals.dart' as g;

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

  String get formattedTime {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get timerTypeLabel => _currentType == TimerType.focus ? 'Focus' : 'Break';

  TimerController() {
    _initializeFromStorage();
  }

  Future<void> _initializeFromStorage() async {
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
            _completeTimer();
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
    } catch (e) {
      debugPrint('Error initializing timer from storage: $e');
      _resetToDefaults();
    }
    notifyListeners();
  }

  void _resetToDefaults() {
    _state = TimerState.idle;
    _currentType = TimerType.focus;
    _remainingSeconds = currentDuration;
    _startTime = null;
    _pausedSeconds = 0;
    _clearStorage();
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
      debugPrint('Error saving timer to storage: $e');
    }
  }

  void _clearStorage() {
    try {
      MiniBox().remove(_timerStateKey);
      MiniBox().remove(_timerTypeKey);
      MiniBox().remove(_startTimeKey);
      MiniBox().remove(_durationKey);
      MiniBox().remove(_pausedTimeKey);
    } catch (e) {
      debugPrint('Error clearing timer storage: $e');
    }
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_startTime != null) {
        final elapsed = DateTime.now().difference(_startTime!).inSeconds;
        _remainingSeconds = currentDuration - elapsed;

        if (_remainingSeconds <= 0) {
          _completeTimer();
        } else {
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
    notifyListeners();
  }
  void stopTimer() {
    _stopTicker();
    _state = TimerState.idle;
    _remainingSeconds = currentDuration;
    _startTime = null;
    _pausedSeconds = 0;
    _saveToStorage();
    g.soundController.stopAudio();
    notifyListeners();
  }

  void resetTimer() {
    _stopTicker();
    _state = TimerState.idle;
    _remainingSeconds = currentDuration;
    _startTime = null;
    _pausedSeconds = 0;
    _saveToStorage();
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

  @override
  void dispose() {
    _stopTicker();
    super.dispose();
  }
}
