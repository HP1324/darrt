import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
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
    // context.read<NoteStateController>().initState(widget.edit, widget.edit ? widget.note : null);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: BackButton()),
      body: QuillEditor.basic(
        controller: QuillController.basic(),
        // controller: context.read<NoteStateController>().controller,
        scrollController: ScrollController(),
        focusNode: FocusNode(),
      ),
    );
  }
}
