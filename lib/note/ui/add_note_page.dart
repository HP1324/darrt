import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:minimaltodo/helpers/messages.dart' show Messages;
import 'package:minimaltodo/helpers/mini_router.dart';
import 'package:minimaltodo/helpers/utils.dart' show generateNotePdf, getIt, savePdf, savePdfToDownloads, showToast;
import 'package:minimaltodo/note/models/folder.dart';
import 'package:minimaltodo/note/models/note.dart';
import 'package:minimaltodo/note/state/folder_view_model.dart';
import 'package:minimaltodo/note/state/note_state_controller.dart';
import 'package:minimaltodo/note/state/note_view_model.dart';
import 'package:minimaltodo/note/ui/add_folder_page.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';

class AddNotePage extends StatefulWidget {
  const AddNotePage({super.key, required this.edit, this.note}) : assert(!edit || note != null);
  final bool edit;
  final Note? note;
  @override
  State<AddNotePage> createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage> {
  late final QuillController _controller;
  @override
  void initState() {
    super.initState();
    _controller = getIt<NoteStateController>().controller;
    context.read<NoteStateController>().initState(widget.edit, widget.edit ? widget.note : null);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading:const BackButton(),
        actions: [
          const SaveNotePdfButton(),
          const FolderSelector(),
          SaveNoteButton(widget: widget),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 15),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: QuillEditor(
                scrollController: getIt<NoteStateController>().scrollController,
                controller: getIt<NoteStateController>().controller,
                focusNode: getIt<NoteStateController>().focusNode,
                config: QuillEditorConfig(
                  placeholder: 'Enter your note here...',
                  autoFocus:  true,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ),
            ),
          ),
          QuillSimpleToolbar(
            controller: getIt<NoteStateController>().controller,
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
                  fontFamily: QuillToolbarFontFamilyButtonOptions(attribute: Attribute.font),
                  fontSize: QuillToolbarFontSizeButtonOptions(attribute: Attribute.size)),
            ),
          ),
        ],
      ),
    );
  }
}

class SaveNotePdfButton extends StatelessWidget {
  const SaveNotePdfButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: ()async {
        final file = await generateNotePdf(getIt<NoteStateController>().controller);
        final path = await savePdfToDownloads(file, 'note${DateTime.now().millisecondsSinceEpoch}.pdf');
        if(context.mounted) {
          showToast( context, type: ToastificationType.success,  description: 'PDF saved');
        }
      },
      icon: const Icon(FontAwesomeIcons.filePdf),
    );
  }
}

class SaveNoteButton extends StatelessWidget {
  const SaveNoteButton({
    super.key,
    required this.widget,
  });

  final AddNotePage widget;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.check),
      onPressed: () {
        var message = '';
        final stateController = context.read<NoteStateController>();
        if (!stateController.controller.document.isEmpty()) {
          final note = stateController.buildModel(
              edit: widget.edit, model: widget.edit ? widget.note : null);
          message = context.read<NoteViewModel>().putItem(note, edit: widget.edit);
          Navigator.pop(context);
        } else {
          message = Messages.mNoteEmpty;
        }
        showToast(context,
            type: message == Messages.mNoteEmpty
                ? ToastificationType.error
                : ToastificationType.success,
            description: message);
      },
    );
  }
}

class FolderSelector extends StatelessWidget {
  const FolderSelector({
    super.key,
  });

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
                Consumer2<FolderViewModel, NoteStateController>(
                  builder: (context, folderVM,controller, _) {
                    final folders = folderVM.folders;
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: folders.length,
                      itemBuilder: (context, index) {
                        final folder = folders[index];
                        // print('Folder Selection: ${controller.folderSelection}');
                        return CheckboxListTile(
                          title: Text(folder.name),
                          value: controller.folderSelection[folder] ?? false,
                          onChanged: (value) {
                            if (value != null) {
                              context.read<NoteStateController>().setFolder(folder, value);
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
