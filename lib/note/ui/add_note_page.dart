import 'package:darrt/app/ads/my_banner_ad_widget.dart';
import 'package:darrt/app/ads/timed_banner_ad_widget.dart';
import 'package:darrt/app/services/mini_box.dart';
import 'package:darrt/app/services/toast_service.dart';
import 'package:darrt/folder/models/folder.dart';
import 'package:darrt/folder/ui/add_folder_page.dart';
import 'package:darrt/helpers/globals.dart' as g;
import 'package:darrt/helpers/icon_color_storage.dart';
import 'package:darrt/helpers/messages.dart' show Messages;
import 'package:darrt/helpers/mini_logger.dart';
import 'package:darrt/helpers/mini_router.dart';
import 'package:darrt/helpers/utils.dart';
import 'package:darrt/note/models/note.dart';
import 'package:darrt/note/state/note_state_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../helpers/consts.dart';
import '../../task/models/task.dart';

class AddNotePage extends StatefulWidget {
  const AddNotePage({
    super.key,
    required this.edit,
    this.note,
    this.folder,
    this.isTaskNote,
    this.task,
  }) : assert(!edit || note != null);
  final bool edit;
  final Note? note;
  final Folder? folder;
  final bool? isTaskNote;
  final Task? task;

  @override
  State<AddNotePage> createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage> {
  @override
  void initState() {
    super.initState();
    g.noteSc.initState(
      widget.edit,
      widget.edit ? widget.note : null,
      widget.folder,
    );
    g.adsController.initializeFullPageAdOnAddNotePagePop();
  }

  @override
  void dispose() {
    g.noteSc.clearState();
    g.noteSttController.clearSttState();
    super.dispose();
  }

  Future<void> showFullPageAd() async {
    if (g.adsController.isFullPageOnAddNotePagePopAdLoaded) {
      final popCount = MiniBox().read('add_note_pop_count') ?? 1;
      if (popCount % 2 == 0) {
        MiniLogger.dp("pop count $popCount");
        await g.adsController.fullPageAdOnAddNotePagePop.show();
      }
      MiniBox().write('add_note_pop_count', popCount + 1);
    }
  }

  bool _isHandlingPop = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,

      onPopInvokedWithResult: (didPop, result) async {
        if (_isHandlingPop) return;

        if (!didPop) {
          final navigator = Navigator.of(context);
          final shouldPop = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Quit without saving?'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Are you sure you want to quit without saving?'),
                ],
              ),
              actions: [
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text('Yes'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text('No'),
                ),
              ],
            ),
          );

          // If user confirmed, actually pop the page
          if (shouldPop == true) {
            _isHandlingPop = true;
            navigator.pop();
            await showFullPageAd();
            _isHandlingPop = false;
          }
        } else {
          // Only show ad if we haven't already handled this pop
          if (!_isHandlingPop) {
            await showFullPageAd();
          }
        }
      },
      child: Scaffold(
        backgroundColor: getSurfaceColor(context),
        appBar: AppBar(
          backgroundColor: getSurfaceColor(context),
          leading: const BackButton(),
          actions: [
            // const SaveNotePdfButton(),
            if (widget.isTaskNote == null) const FolderSelector(),
          ],
        ),
        body: Column(
          children: [
            ListenableBuilder(
              listenable: g.adsController,
              builder: (context, child) {
                return TimedBannerAdWidget(
                  hideFor: Duration(seconds: 10),
                  showFor: Duration(seconds: 35),
                  adInitializer: () =>
                      g.adsController.initializeAddNotePageBannerAd(),
                  childBuilder: () {
                    if (g.adsController.isAddNotePageBannerAdLoaded) {
                      return MyBannerAdWidget(
                        bannerAd: g.adsController.addNotePageBannerAd,
                      );
                    }
                    return const SizedBox.shrink();
                  },
                  showFirst: false,
                );
              },
            ),
            NotesQuillToolbar(),
            NotesQuillEditor(),
          ],
        ),
        floatingActionButton: Column(
          spacing: 7,
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton.small(
              heroTag: null,
              onPressed: () => _handleSpeechToText(context),
              tooltip: 'Speak to write note',
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              foregroundColor: Theme.of(context).colorScheme.surface,
              backgroundColor: Theme.of(context).colorScheme.onSurface,
              child: Icon(Icons.mic),
            ),
            FloatingActionButton(
              heroTag: null,
              onPressed: () => _saveNote(context),
              tooltip: 'Save note',
              shape: StadiumBorder(),
              child: const Icon(Icons.check),
            ),
          ],
        ),
      ),
    );
  }

  void _saveNote(BuildContext context) {
    if (widget.isTaskNote != null && widget.task != null) {
      MiniLogger.dp('we are here');
      if (!g.noteSc.controller.document.isEmpty()) {
        final note = g.noteSc.buildModel(
          edit: widget.edit,
          model: widget.edit ? widget.note : null,
        );
        g.taskVm.putNote(task: widget.task!, note: note, edit: widget.edit);
        Navigator.pop(context);
      }
      return;
    } else if (widget.isTaskNote != null) {
      if (!g.noteSc.controller.document.isEmpty()) {
        final note = g.noteSc.buildModel(
          edit: widget.edit,
          model: widget.edit ? widget.note : null,
        );
        g.taskSc.putNote(note: note, edit: widget.edit);
        Navigator.pop(context);
      }
      return;
    } else {
      String message = '';
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
      if (message == Messages.mNoteEmpty)
        showErrorToast(context, message);
      else
        showSuccessToast(context, message);
    }
  }

  void showMicrophonePermissionDeniedToast() => showErrorToast(
    context,
    'All requested permissions are necessary for speech recognition',
  );

  Future<void> _handleSpeechToText(BuildContext context) async {
    // Check permission status first using permission_handler
    final micPermissionStatus = await Permission.microphone.status;
    final nearbyDevicesStatus = await Permission.bluetoothConnect.status;

    bool allPermissionsGranted =
        micPermissionStatus.isGranted && (nearbyDevicesStatus.isGranted);

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
          showMicrophonePermissionDeniedToast();
        }
      } else {
        MiniLogger.d('Speech already initialized, starting listening');
        g.noteSttController.startListening();
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
          final initResult = await g.noteSttController.initSpeech();
          if (initResult) {
            g.noteSttController.startListening();
          } else {
            if (context.mounted) {
              showMicrophonePermissionDeniedToast();
            }
          }
        } else {
          MiniLogger.d('Some permissions denied on first request');
          showMicrophonePermissionDeniedToast();
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
            final initResult = await g.noteSttController.initSpeech();
            if (initResult) {
              g.noteSttController.startListening();
            } else {
              showMicrophonePermissionDeniedToast();
            }
          } else {
            MiniLogger.d('Some permissions denied on second request');
            MiniBox().write(micPermissionDeniedAgain, true);
            showMicrophonePermissionDeniedToast();
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

class NotesQuillToolbar extends StatelessWidget {
  const NotesQuillToolbar({super.key});

  Map<String, String> _getFontSizeMap() {
    return {
      'Clear': '0',
      for (var i = 1; i <= 48; i++) '$i': '$i',
    };
  }

  @override
  Widget build(BuildContext context) {
    return QuillSimpleToolbar(
      controller: g.noteSc.controller,
      config: QuillSimpleToolbarConfig(
        multiRowsDisplay: false,
        toolbarIconAlignment: WrapAlignment.start,
        buttonOptions: QuillSimpleToolbarButtonOptions(
          selectHeaderStyleDropdownButton:
              QuillToolbarSelectHeaderStyleDropdownButtonOptions(
                attributes: [
                  Attribute.h1,
                  Attribute.h2,
                  Attribute.h3,
                  Attribute.h4,
                  Attribute.h5,
                  Attribute.h6,
                ],
              ),
          fontFamily: QuillToolbarFontFamilyButtonOptions(
            attribute: Attribute.font,
          ),
          fontSize: QuillToolbarFontSizeButtonOptions(
            items: _getFontSizeMap(),
            initialValue: '16',
          ),
          codeBlock: QuillToolbarToggleStyleButtonOptions(
            iconData: FontAwesomeIcons.solidFileCode,
          ),
        ),
      ),
    );
  }
}

class NotesQuillEditor extends StatelessWidget {
  const NotesQuillEditor({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = TextTheme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: QuillEditor(
          scrollController: g.noteSc.scrollController,
          controller: g.noteSc.controller,
          focusNode: g.noteSc.focusNode,
          config: QuillEditorConfig(
            padding: EdgeInsets.only(bottom: 200),
            contextMenuBuilder: (context, editableTextState) {
              final TextSelectionToolbarAnchors anchors =
                  editableTextState.contextMenuAnchors;

              return AdaptiveTextSelectionToolbar(
                // Position below text
                anchors: TextSelectionToolbarAnchors(
                  primaryAnchor: anchors.primaryAnchor + const Offset(0, 80),
                  secondaryAnchor:
                      anchors.secondaryAnchor! + const Offset(0, 80),
                ),
                children: [
                  // Your custom toolbar buttons
                  TextSelectionToolbarTextButton(
                    onPressed: () => editableTextState.cutSelection(
                      SelectionChangedCause.toolbar,
                    ),
                    padding: TextSelectionToolbarTextButton.getPadding(0, 4),
                    child: const Text('Cut'),
                  ),
                  TextSelectionToolbarTextButton(
                    onPressed: () => editableTextState.copySelection(
                      SelectionChangedCause.toolbar,
                    ),
                    padding: TextSelectionToolbarTextButton.getPadding(0, 4),
                    child: const Text('Copy'),
                  ),
                  TextSelectionToolbarTextButton(
                    onPressed: () => editableTextState.pasteText(
                      SelectionChangedCause.toolbar,
                    ),
                    padding: TextSelectionToolbarTextButton.getPadding(0, 4),
                    child: const Text('Paste'),
                  ),
                  TextSelectionToolbarTextButton(
                    onPressed: () => editableTextState.selectAll(
                      SelectionChangedCause.toolbar,
                    ),
                    padding: TextSelectionToolbarTextButton.getPadding(0, 4),
                    child: const Text('Select All'),
                  ),
                ],
              );
            },
            // textSelectionControls: ,
            placeholder: 'Write your thoughts here...',
            autoFocus: true,
            textCapitalization: TextCapitalization.sentences,
            customStyles: DefaultStyles(
              inlineCode: InlineCodeStyle(
                style: textTheme.labelMedium!.copyWith(
                  fontFamily: 'SourceCodePro',
                  color: scheme.onSurfaceVariant,
                ),
                backgroundColor: scheme.surfaceContainerHighest,
              ),
              code: DefaultTextBlockStyle(
                textTheme.labelMedium!.copyWith(
                  fontFamily: 'SourceCodePro',
                  color: scheme.onSurfaceVariant,
                ),
                HorizontalSpacing(5, 5),
                VerticalSpacing(10, 10),
                VerticalSpacing(5, 5),
                BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ),
      ),
    );
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
          showErrorToast(context, Messages.mNoteEmpty);
          return;
        }
        await savePdfToDownloads(
          file,
          'DarrtNote${DateTime.now().millisecondsSinceEpoch.remainder(100000)}.pdf',
        );
        if (context.mounted) {
          showSuccessToast(context, 'PDF saved to device');
        }
      },
      icon: const Icon(FontAwesomeIcons.filePdf),
    );
  }
}

class FolderSelector extends StatelessWidget {
  const FolderSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.create_new_folder_outlined),
      onPressed: () => _showFolderSelectionBottomSheet(context),
    );
  }

  Future<dynamic> _showFolderSelectionBottomSheet(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),
              ListTile(
                onTap: () => MiniRouter.to(context, AddFolderPage(edit: false)),
                title: const Text(
                  'Create New Folder',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.add),
                ),
                trailing: const Icon(Icons.list_alt),
              ),
              Expanded(
                child: Scrollbar(
                  thickness: 8,
                  radius: const Radius.circular(4),
                  child: ListenableBuilder(
                    listenable: Listenable.merge([g.noteSc, g.folderVm]),
                    builder: (context, child) => ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: g.folderVm.folders.length,
                      itemBuilder: (_, index) {
                        final folder = g.folderVm.folders[index];
                        final map = g.noteSc.folderSelection;
                        return ListTile(
                          selected: map[folder] ?? false,
                          selectedColor: IconColorStorage.colors[folder.color],
                          leading: Icon(
                            IconColorStorage.flattenedIcons[folder.icon],
                          ),
                          trailing: Checkbox(
                            fillColor: WidgetStateProperty.resolveWith((states) {
                              if (states.contains(WidgetState.selected)) {
                                return IconColorStorage.colors[folder.color];
                              }
                              return null;
                            }),
                            value: map[folder] ?? false,
                            onChanged: (selected) {
                              if (selected != null) {
                                g.noteSc.setFolder(folder, selected);
                              }
                            },
                          ),
                          title: Text(
                            folder.name,
                            style: const TextStyle(
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
    originalCursorPosition =
        quillController.selection.baseOffset; // Store cursor position
    speechFinalized = '';
    currentLiveSpeech = '';
    previousSpeechLength = 0;
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
    speechFinalized = '';
    currentLiveSpeech = '';
  }

  int originalCursorPosition = 0;
  String speechFinalized = '';
  String currentLiveSpeech = '';
  int previousSpeechLength = 0;

  void onSpeechResult(SpeechRecognitionResult result) {
    final quillController = g.noteSc.controller;
    currentLiveSpeech = result.recognizedWords.trim();

    if (result.finalResult) {
      // Append only once, when final
      if (currentLiveSpeech.isNotEmpty) {
        speechFinalized = ('$speechFinalized $currentLiveSpeech').trim();
      }
      currentLiveSpeech = '';
    }

    // Combine finalized + live speech
    final combinedSpeechText = [
      speechFinalized,
      currentLiveSpeech,
    ].where((text) => text.isNotEmpty).join(' ');

    if (combinedSpeechText.isNotEmpty) {
      // Track the length of previously inserted speech text
      // Instead of calculating from document length, track it directly
      if (previousSpeechLength > 0) {
        // Replace only the previously added speech text
        quillController.replaceText(
          originalCursorPosition,
          previousSpeechLength,
          combinedSpeechText,
          TextSelection.collapsed(
            offset: originalCursorPosition + combinedSpeechText.length,
          ),
        );
      } else {
        // Insert the speech text at cursor position
        quillController.replaceText(
          originalCursorPosition,
          0,
          combinedSpeechText,
          TextSelection.collapsed(
            offset: originalCursorPosition + combinedSpeechText.length,
          ),
        );
      }

      // Update the tracked length for next iteration
      previousSpeechLength = combinedSpeechText.length;

      // Set cursor at the end of the inserted text
      final newCursorPosition =
          originalCursorPosition + combinedSpeechText.length;
      quillController.updateSelection(
        TextSelection.collapsed(offset: newCursorPosition),
        ChangeSource.local,
      );
    }
  }

  // void onSpeechResult(SpeechRecognitionResult result) {
  //   final quillController = g.noteSc.controller;
  //   currentLiveSpeech = result.recognizedWords.trim();
  //
  //   if (result.finalResult) {
  //     // Append only once, when final
  //     if (currentLiveSpeech.isNotEmpty) {
  //       speechFinalized = ('$speechFinalized $currentLiveSpeech').trim();
  //     }
  //     currentLiveSpeech = '';
  //   }
  //
  //   // Combine finalized + live speech
  //   final combinedSpeechText = [
  //     speechFinalized,
  //     currentLiveSpeech,
  //   ].where((text) => text.isNotEmpty).join(' ');
  //
  //   if (combinedSpeechText.isNotEmpty) {
  //     // Calculate current speech length that was previously inserted
  //     final currentDocLength = quillController.document.length - 1;
  //     final previousSpeechLength = currentDocLength - originalCursorPosition;
  //
  //     if (previousSpeechLength > 0) {
  //       // Replace the previously added speech text
  //       quillController.replaceText(
  //         originalCursorPosition,
  //         previousSpeechLength,
  //         combinedSpeechText,
  //         TextSelection.collapsed(offset: originalCursorPosition + combinedSpeechText.length),
  //       );
  //     } else {
  //       // Insert the speech text at cursor position
  //       quillController.replaceText(
  //         originalCursorPosition,
  //         0,
  //         combinedSpeechText,
  //         TextSelection.collapsed(offset: originalCursorPosition + combinedSpeechText.length),
  //       );
  //     }
  //
  //     // Set cursor at the end of the inserted text
  //     final newCursorPosition = originalCursorPosition + combinedSpeechText.length;
  //     quillController.updateSelection(
  //       TextSelection.collapsed(offset: newCursorPosition),
  //       ChangeSource.local,
  //     );
  //   }
  // }
}
