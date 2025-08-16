import 'package:darrt/app/services/mini_box.dart';
import 'package:darrt/app/services/toast_service.dart';
import 'package:darrt/helpers/consts.dart';
import 'package:darrt/helpers/mini_logger.dart';
import 'package:darrt/helpers/utils.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../helpers/globals.dart' as g show taskSc;

class TaskSttController{
  final SpeechToText speech = SpeechToText();
  String hintText = "What's on your mind? ";
  String _speechFinalized = '';
  String _currentLiveSpeech = '';
  int previousSpeechLength = 0;
  int originalCursorPosition = 0;
  Future<bool> initSpeech() async {
    return await speech.initialize();
  }

  void startListening() async {
    originalCursorPosition = g.taskSc.textController.selection.baseOffset;
    previousSpeechLength = 0;
    _speechFinalized = '';
    _currentLiveSpeech = '';
    await speech.listen(
      onResult: onSpeechResult,
      pauseFor: Duration(seconds: 10),
      listenOptions: SpeechListenOptions(
        listenMode: ListenMode.dictation,
        autoPunctuation: true,
      ),
    );
  }

  void clearSttState() async {
    await speech.stop();
    _speechFinalized = '';
    _currentLiveSpeech = '';
  }

  void onSpeechResult(SpeechRecognitionResult result) {
    final titleController = g.taskSc.textController;
    _currentLiveSpeech = result.recognizedWords.trim();

    if (result.finalResult) {
      // Append only once, when final
      if (_currentLiveSpeech.isNotEmpty) {
        _speechFinalized = ('$_speechFinalized $_currentLiveSpeech').trim();
      }
      _currentLiveSpeech = '';
    }

    // Combine finalized + live speech
    final combinedSpeechText = [
      _speechFinalized,
      _currentLiveSpeech,
    ].where((text) => text.isNotEmpty).join(' ');

    if (combinedSpeechText.isNotEmpty) {
      // Get current text and cursor position
      final currentText = titleController.text;
      final cursorPosition = originalCursorPosition;

      // Calculate text parts
      final textBeforeCursor = currentText.substring(0, cursorPosition);
      final textAfterSpeech = currentText.substring(cursorPosition + previousSpeechLength);

      // Combine: text before cursor + new speech + text after previous speech
      final newText = textBeforeCursor + combinedSpeechText + textAfterSpeech;

      // Update controller
      titleController.text = newText;

      // Update tracked length for next iteration
      previousSpeechLength = combinedSpeechText.length;

      // Set cursor at the end of the inserted speech
      final newCursorPosition = cursorPosition + combinedSpeechText.length;
      titleController.selection = TextSelection.collapsed(offset: newCursorPosition);
    }
  }

  Future<void> handleSpeechToText(BuildContext context) async {
    showPermissionDeniedToast() {
      showErrorToast(context, 'All requested permissions are required');
    }

    // Check permission status first using permission_handler
    final micPermissionStatus = await Permission.microphone.status;
    final nearbyDevicesStatus = await Permission.bluetoothConnect.status;

    bool allPermissionsGranted =
        micPermissionStatus.isGranted && (nearbyDevicesStatus.isGranted);

    if (allPermissionsGranted) {
      MiniLogger.d('All required permissions are granted');

      // Check if speech is initialized
      if (!speech.isAvailable) {
        MiniLogger.d('Speech not initialized, initializing...');
        final initResult = await initSpeech();
        if (initResult) {
          MiniLogger.d('Speech initialized successfully');
          startListening();
        } else {
          MiniLogger.d('Speech initialization failed');
          showPermissionDeniedToast();
        }
      } else {
        MiniLogger.d('Speech already initialized, starting listening');
        startListening();
      }
    } else {
      MiniLogger.d('Some permissions are missing');

      if (MiniBox().read(firstTimeMicTap) ?? true) {
        MiniLogger.d('First time requesting permissions');
        MiniBox().write(firstTimeMicTap, false);

        // Request microphone permission first
        final micResult = await Permission.microphone.request();

        // Request nearby devices permission (for Bluetooth headsets)
        final nearbyResult = await Permission.bluetoothConnect.request();

        bool permissionsGranted =
            micResult.isGranted && (nearbyResult.isGranted);

        if (permissionsGranted) {
          MiniLogger.d('Permissions granted on first request');
          final initResult = await initSpeech();
          if (initResult) {
            startListening();
          } else {
            if (context.mounted) {
              showPermissionDeniedToast();
            }
          }
        } else {
          MiniLogger.d('Some permissions denied on first request');
          showPermissionDeniedToast();
        }
      } else {
        MiniLogger.d('Not first time, checking if denied again flag is set');

        if (!(MiniBox().read(micPermissionDeniedAgain) ?? false)) {
          MiniLogger.d('Requesting permissions second time');

          // Request both permissions again
          final micResult = await Permission.microphone.request();
          final nearbyResult = await Permission.bluetoothConnect.request();

          bool permissionsGranted =
              micResult.isGranted && (nearbyResult.isGranted);

          if (permissionsGranted) {
            MiniLogger.d('Permissions granted on second request');
            // Force reinitialize speech since permission state changed
            final initResult = await initSpeech();
            if (initResult) {
              startListening();
            } else {
              showPermissionDeniedToast();
            }
          } else {
            MiniLogger.d('Some permissions denied on second request');
            MiniBox().write(micPermissionDeniedAgain, true);
            showPermissionDeniedToast();
          }
        } else {
          MiniLogger.d(
            'Permissions denied multiple times, showing settings dialog',
          );
          if (context.mounted) {
            showSettingsDialog(context);
          }
        }
      }
    }
  }
}