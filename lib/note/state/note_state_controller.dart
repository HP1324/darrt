
import 'package:flutter_quill/flutter_quill.dart' show QuillController;
import 'package:freezed_annotation/freezed_annotation.dart' show freezed;
import 'package:minimaltodo/app/state/controllers/state_controller.dart';
import 'package:minimaltodo/note/models/note.dart';
// @freezed
// abstract class NoteState with _$NoteState{
//   const factory NoteState({
//     required String content,
//   }) = _NoteState;
//   const NoteState._();
// }

// class NoteStateController extends StateController<NoteState,Note>{
//   QuillController _controller = QuillController.basic();
//   QuillController get controller => _controller;
//
//   @override
//   Note buildModel({required bool edit, Note? model}) {
//     return Note.fromQuillController(_controller);
//   }
//
//   @override
//   void clearState() {
//     _controller.clear();
//   }
//
//   @override
//   void initState(bool edit, [Note? model]) {
//       _controller =  edit ? model!.toQuillController() : QuillController.basic();
//   }
//
// }