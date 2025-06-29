import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors, FocusNode;
import 'package:flutter_quill/flutter_quill.dart' show QuillController;
import 'package:minimaltodo/app/state/controllers/state_controller.dart';
import 'package:minimaltodo/helpers/globals.dart' as g;
import 'package:minimaltodo/helpers/icon_color_storage.dart';
import 'package:minimaltodo/helpers/object_box.dart';
import 'package:minimaltodo/note/models/folder.dart';
import 'package:minimaltodo/note/models/note.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'note_state_controller.freezed.dart';

@freezed
abstract class NoteState with _$NoteState {
  const factory NoteState({
    required String color,
    required DateTime createdAt,
    required DateTime updatedAt,
    required Map<Folder, bool> folderSelection,
  }) = _NoteState;
  const NoteState._();
}

class NoteStateController extends StateController<NoteState, Note> {

  QuillController controller = QuillController.basic();
  ScrollController scrollController = ScrollController();

  @override
  Note buildModel({required bool edit, Note? model}) {
    var note = Note.fromQuillController(controller, uuid: edit ? model!.uuid : null);
    note.id = edit ? model!.id : 0;
    final folders = g.folderVm.folders.where((f) =>g.noteSc.folderSelection[f] == true).toList();
    note.folders.clear();
    note.folders.addAll(folders);
    return note;
  }

  @override
  void clearState() {
    textController.clear();
    controller.clear();
  }

  @override
  void initState(bool edit, [Note? model]) {
    final folders = ObjectBox.store!.box<Folder>().getAll();

    state = NoteState(
      color: 'green',
      createdAt: edit ? model!.createdAt! : DateTime.now(),
      updatedAt: edit ? model!.updatedAt! : DateTime.now(),
      folderSelection: edit
          ? {for (var folder in folders) folder: model!.folders.contains(folder)}
          : {folders[0]: true},
    );
    controller = edit ? model!.toQuillController() : QuillController.basic();
    controller.moveCursorToEnd();
  }

  void setFolder(Folder folder, bool value) {
    state = state.copyWith(folderSelection: {...state.folderSelection, folder: value});
    notifyListeners();
  }
  void setColor(String newColor) {
    state = state.copyWith(color: newColor);
    notifyListeners();
  }
}

extension AccessState on NoteStateController {
  FocusNode get focusNode => textFieldNode;
  Color get color => IconColorStorage.colors[state.color] ?? Colors.white;
  DateTime get createdAt => state.createdAt;
  DateTime get updatedAt => state.updatedAt;
  Map<Folder, bool> get folderSelection => state.folderSelection;
}
