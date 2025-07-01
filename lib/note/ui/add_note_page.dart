import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:minimaltodo/helpers/messages.dart' show Messages;
import 'package:minimaltodo/helpers/mini_router.dart';
import 'package:minimaltodo/helpers/utils.dart' show generateNotePdf, savePdfToDownloads, showToast;
import 'package:minimaltodo/note/models/note.dart';
import 'package:minimaltodo/note/state/note_state_controller.dart';
import 'package:minimaltodo/note/ui/add_folder_page.dart';
import 'package:toastification/toastification.dart';
import 'package:minimaltodo/helpers/globals.dart' as g;

class AddNotePage extends StatefulWidget {
  const AddNotePage({super.key, required this.edit, this.note}) : assert(!edit || note != null);
  final bool edit;
  final Note? note;
  @override
  State<AddNotePage> createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage> {
  @override
  void initState() {
    super.initState();
    g.noteSc.initState(widget.edit, widget.edit ? widget.note : null);
  }

  @override
  void dispose() {
    g.noteSc.clearState();
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
        await savePdfToDownloads(file, 'note${DateTime.now().millisecondsSinceEpoch}.pdf');
        if (context.mounted) {
          showToast(context, type: ToastificationType.success, description: 'PDF saved');
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
