import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:minimaltodo/helpers/messages.dart' show Messages;
import 'package:minimaltodo/helpers/mini_box.dart';
import 'package:minimaltodo/helpers/mini_logger.dart';
import 'package:minimaltodo/helpers/mini_router.dart';
import 'package:minimaltodo/helpers/utils.dart'
    show generateNotePdf, savePdfToDownloads, showToast, showSettingsDialog;
import 'package:minimaltodo/note/models/folder.dart';
import 'package:minimaltodo/note/models/note.dart';
import 'package:minimaltodo/note/state/note_state_controller.dart';
import 'package:minimaltodo/note/ui/add_folder_page.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:toastification/toastification.dart';
import 'package:minimaltodo/helpers/globals.dart' as g;

import '../../helpers/consts.dart';

class AddNotePage extends StatefulWidget {
  const AddNotePage({super.key, required this.edit, this.note, this.folder})
    : assert(!edit || note != null);
  final bool edit;
  final Note? note;
  final Folder? folder;
  @override
  State<AddNotePage> createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage> {
  @override
  void initState() {
    super.initState();
    g.noteSc.initState(widget.edit, widget.edit ? widget.note : null, widget.folder);
  }

  @override
  void dispose() {
    g.noteSc.clearState();
    g.noteSttController.clearSttState();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        actions: [
          const SaveNotePdfButton(),
          const FolderSelector(),
          SaveNoteButton(widget: widget),
        ],
      ),
      body: Column(
        children: [
          QuillSimpleToolbar(
            controller: g.noteSc.controller,
            config: QuillSimpleToolbarConfig(
              multiRowsDisplay: false,
              toolbarIconAlignment: WrapAlignment.start,
              buttonOptions: QuillSimpleToolbarButtonOptions(
                selectHeaderStyleDropdownButton: QuillToolbarSelectHeaderStyleDropdownButtonOptions(
                  attributes: [
                    Attribute.h1,
                    Attribute.h2,
                    Attribute.h3,
                    Attribute.h4,
                    Attribute.h5,
                    Attribute.h6,
                  ],
                ),
                fontFamily: QuillToolbarFontFamilyButtonOptions(attribute: Attribute.font),
                fontSize: QuillToolbarFontSizeButtonOptions(attribute: Attribute.size),
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: QuillEditor(
                scrollController: g.noteSc.scrollController,
                controller: g.noteSc.controller,
                focusNode: g.noteSc.focusNode,
                config: QuillEditorConfig(
                  placeholder: 'Enter your note here...',
                  autoFocus: true,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _handleSpeechToText(context),
        tooltip: 'Speak to write note',
        shape: StadiumBorder(),
        child: Icon(Icons.mic),
      ),
    );
  }

  Future<void> _handleSpeechToText(BuildContext context) async {
    showPermissionDeniedToast() {
      showToast(
        context,
        type: ToastificationType.error,
        description: 'Microphone permission denied',
      );
    }

    // Check permission status first using permission_handler
    final micPermissionStatus = await Permission.microphone.status;
    final nearbyDevicesStatus = await Permission.bluetoothConnect.status;

    bool allPermissionsGranted = micPermissionStatus.isGranted && (nearbyDevicesStatus.isGranted);

    if (allPermissionsGranted) {
      MiniLogger.d('All required permissions are granted');

      // Check if speech is initialized
      if (!g.noteSttController.speech.isAvailable) {
        MiniLogger.d('Speech not initialized, initializing...');
        final initResult = await g.noteSttController.initSpeech();
        if (initResult) {
          MiniLogger.d('Speech initialized successfully');
          g.noteSttController.startListening();
        } else {
          MiniLogger.d('Speech initialization failed');
          showPermissionDeniedToast();
        }
      } else {
        MiniLogger.d('Speech already initialized, starting listening');
        g.noteSttController.startListening();
      }
    } else {
      MiniLogger.d('Some permissions are missing');

      if (MiniBox.read(firstTimeMicTap) ?? true) {
        MiniLogger.d('First time requesting permissions');
        await MiniBox.write(firstTimeMicTap, false);

        // Request microphone permission first
        final micResult = await Permission.microphone.request();

        // Request nearby devices permission (for Bluetooth headsets)
        final nearbyResult = await Permission.bluetoothConnect.request();

        bool permissionsGranted = micResult.isGranted && (nearbyResult.isGranted);

        if (permissionsGranted) {
          MiniLogger.d('Permissions granted on first request');
          final initResult = await g.noteSttController.initSpeech();
          if (initResult) {
            g.noteSttController.startListening();
          } else {
            showToast(
              context,
              type: ToastificationType.error,
              description: 'All requested permissions are necessary for speech recognition',
            );
          }
        } else {
          MiniLogger.d('Some permissions denied on first request');
          showPermissionDeniedToast();
        }
      } else {
        MiniLogger.d('Not first time, checking if denied again flag is set');

        if (!(MiniBox.read(micPermissionDeniedAgain) ?? false)) {
          MiniLogger.d('Requesting permissions second time');

          // Request both permissions again
          final micResult = await Permission.microphone.request();
          final nearbyResult = await Permission.bluetoothConnect.request();

          bool permissionsGranted = micResult.isGranted && (nearbyResult.isGranted);

          if (permissionsGranted) {
            MiniLogger.d('Permissions granted on second request');
            // Force reinitialize speech since permission state changed
            final initResult = await g.noteSttController.initSpeech();
            if (initResult) {
              g.noteSttController.startListening();
            } else {
              showPermissionDeniedToast();
            }
          } else {
            MiniLogger.d('Some permissions denied on second request');
            await MiniBox.write(micPermissionDeniedAgain, true);
            showPermissionDeniedToast();
          }
        } else {
          MiniLogger.d('Permissions denied multiple times, showing settings dialog');
          if (context.mounted) {
            showSettingsDialog(context);
          }
        }
      }
    }
  }
}

class SaveNotePdfButton extends StatelessWidget {
  const SaveNotePdfButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        final file = await generateNotePdf(g.noteSc.controller);
        if (identical(file, noteEmptyErrorBytes) && context.mounted) {
          showToast(context, type: ToastificationType.error, description: Messages.mNoteEmpty);
          return;
        }
        await savePdfToDownloads(file, 'note${DateTime.now().millisecondsSinceEpoch}.pdf');
        if (context.mounted) {
          showToast(context, type: ToastificationType.success, description: 'PDF saved to device');
        }
      },
      icon: const Icon(FontAwesomeIcons.filePdf),
    );
  }
}

class SaveNoteButton extends StatelessWidget {
  const SaveNoteButton({super.key, required this.widget});

  final AddNotePage widget;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.check),
      onPressed: () {
        var message = '';
        if (!g.noteSc.controller.document.isEmpty()) {
          final note = g.noteSc.buildModel(
            edit: widget.edit,
            model: widget.edit ? widget.note : null,
          );
          message = g.noteVm.putItem(note, edit: widget.edit);
          Navigator.pop(context);
        } else {
          message = Messages.mNoteEmpty;
        }
        showToast(
          context,
          type: message == Messages.mNoteEmpty
              ? ToastificationType.error
              : ToastificationType.success,
          description: message,
        );
      },
    );
  }
}

class FolderSelector extends StatelessWidget {
  const FolderSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.folder_open),
      onPressed: () {
        showModalBottomSheet(
          context: context,
          builder: (context) => Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                ListTile(
                  title: Text('Add Folder'),
                  leading: Icon(Icons.add),
                  onTap: () {
                    Navigator.pop(context);
                    MiniRouter.to(context, AddFolderPage(edit: false));
                  },
                ),
                const Divider(),
                ListenableBuilder(
                  listenable: Listenable.merge([g.folderVm, g.noteSc]),
                  builder: (context, child) {
                    final folders = g.folderVm.folders;
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: folders.length,
                      itemBuilder: (context, index) {
                        final folder = folders[index];
                        // print('Folder Selection: ${controller.folderSelection}');
                        return CheckboxListTile(
                          title: Text(folder.name),
                          value: g.noteSc.folderSelection[folder] ?? false,
                          onChanged: (value) {
                            if (value != null) {
                              g.noteSc.setFolder(folder, value);
                            }
                          },
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class NoteSttController extends ChangeNotifier {
  final SpeechToText speech = SpeechToText();
  String hintText = "What's on your mind? ";

  Future<bool> initSpeech() async {
    return await speech.initialize();
  }

  void startListening() async {
    final quillController = g.noteSc.controller;

    // Store the original document content
    _originalDocumentLength =
        quillController.document.length - 1; // -1 to exclude the trailing newline
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

  int _originalDocumentLength = 0;
  String _speechFinalized = '';
  String _currentLiveSpeech = '';

  void onSpeechResult(SpeechRecognitionResult result) {
    final quillController = g.noteSc.controller;
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
      // Calculate where to insert/replace the speech text
      final currentDocLength = quillController.document.length - 1; // -1 for trailing newline
      final speechStartPosition = _originalDocumentLength;

      // If we have speech content that was previously added, replace it
      if (currentDocLength > _originalDocumentLength) {
        final speechLength = currentDocLength - _originalDocumentLength;
        // Delete the previously added speech text
        quillController.replaceText(
          speechStartPosition,
          speechLength,
          combinedSpeechText,
          TextSelection.collapsed(offset: speechStartPosition + combinedSpeechText.length),
        );
      } else {
        // Insert the speech text at the end
        quillController.replaceText(
          speechStartPosition,
          0,
          combinedSpeechText,
          TextSelection.collapsed(offset: speechStartPosition + combinedSpeechText.length),
        );
      }

      // Set cursor at the end of the inserted text
      final newCursorPosition = speechStartPosition + combinedSpeechText.length;
      quillController.updateSelection(
        TextSelection.collapsed(offset: newCursorPosition),
        ChangeSource.local,
      );
    }
  }
}
