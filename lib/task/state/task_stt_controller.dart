import 'package:flutter/material.dart';
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
}