
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors, FocusNode;
import 'package:flutter_quill/flutter_quill.dart' show Document, QuillController;
import 'package:minimaltodo/app/state/controllers/state_controller.dart';
import 'package:minimaltodo/helpers/icon_color_storage.dart';
import 'package:minimaltodo/note/models/note.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'note_state_controller.freezed.dart';
@freezed
abstract class NoteState with _$NoteState{
  const factory NoteState({
    required String content,
    required String color,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _NoteState;
  const NoteState._();
}

class NoteStateController extends StateController<NoteState,Note>{
  QuillController controller = QuillController.basic();


  ScrollController scrollController = ScrollController();

  @override
  Note buildModel({required bool edit, Note? model}) {
    return Note.fromQuillController(controller);
  }

  @override
  void clearState() {
    controller.clear();
  }

  @override
  void initState(bool edit, [Note? model]) {
      controller =  edit ? model!.toQuillController() : QuillController.basic();
  }

}
extension AccessState on NoteStateController{
  FocusNode get focusNode => textFieldNode;
  Color get color => IconColorStorage.colors[state.color] ?? Colors.white;
  DateTime get createdAt => state.createdAt;
  DateTime get updatedAt => state.updatedAt;
}