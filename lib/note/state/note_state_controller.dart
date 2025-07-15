import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_quill/flutter_quill.dart' show QuillController;
import 'package:darrt/app/state/controllers/state_controller.dart';
import 'package:darrt/helpers/globals.dart' as g;
import 'package:darrt/app/services/object_box.dart';
import 'package:darrt/note/models/folder.dart';
import 'package:darrt/note/models/note.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'note_state_controller.freezed.dart';

@freezed
abstract class NoteState with _$NoteState {
  const factory NoteState({
    required DateTime createdAt,
    required DateTime updatedAt,
    required Map<Folder, bool> folderSelection,
  }) = _NoteState;
  const NoteState._();
}

class NoteStateController extends StateController<NoteState, Note> {
  QuillController controller = QuillController.basic();
  final ScrollController _scrollController = ScrollController();

  ScrollController get scrollController => _scrollController;
  @override
  Note buildModel({required bool edit, Note? model}) {
    Note note;
    final content = jsonEncode(controller.document.toDelta().toJson());
    if (edit) {
      note = model!;
      note.content = content;
      note.updatedAt = DateTime.now();
    } else {
      note = Note(
        id: 0,
        content: content,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
    final folders = g.folderVm.folders.where((f) => g.noteSc.folderSelection[f] == true).toList();
    note.folders.clear();
    if (folders.isEmpty) {
      final generalFolder = ObjectBox().folderBox.get(1) ?? Folder(id: 1, name: 'General');
      note.folders.add(generalFolder);
      note.folderUuids = [generalFolder.uuid];
    } else {
      note.folders.addAll(folders);
      note.folderUuids = folders.map((f) => f.uuid).toList();
    }
    return note;
  }

  @override
  void clearState() {
    textController.clear();
    controller.clear();
  }

  ///[initialFolder] is for opening the note from a folder, so this folder will be selected by default, when adding note for a folder
  @override
  void initState(bool edit, [Note? model, Folder? initialFolder]) {
    final folders = g.folderVm.folders;
    state = NoteState(
      folderSelection: initialFolder == null
          ? edit
                ? {for (var folder in folders) folder: model!.folders.contains(folder)}
                : {folders[0]: true}
          : {initialFolder: true},
      createdAt: edit ? model!.createdAt! : DateTime.now(),
      updatedAt: edit ? model!.updatedAt! : DateTime.now(),
    );
    controller = edit ? model!.quillController : QuillController.basic();
    controller.moveCursorToEnd();
  }

  void setFolder(Folder folder, bool value) {
    state = state.copyWith(folderSelection: {...state.folderSelection, folder: value});
    notifyListeners();
  }
}

extension AccessState on NoteStateController {
  FocusNode get focusNode => textFieldNode;
  DateTime get createdAt => state.createdAt;
  DateTime get updatedAt => state.updatedAt;
  Map<Folder, bool> get folderSelection => state.folderSelection;
}
