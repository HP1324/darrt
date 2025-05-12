import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:minimaltodo/helpers/utils.dart' show getIt;
import 'package:minimaltodo/note/models/note.dart';
import 'package:minimaltodo/note/state/note_state_controller.dart';
import 'package:provider/provider.dart';

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
    context.read<NoteStateController>().initState(widget.edit, widget.edit ? widget.note : null);
    final c = context.read<NoteStateController>().controller;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              // Save note logic would go here
              // Provider.of<NoteStateController>(context, listen: false).addNote(newNote);
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: QuillEditor(
                scrollController: getIt<NoteStateController>().scrollController,
                controller: getIt<NoteStateController>().controller,
                focusNode: getIt<NoteStateController>().focusNode,
                config: QuillEditorConfig(
                  placeholder: 'Enter your note here...',
                  autoFocus: true,
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
