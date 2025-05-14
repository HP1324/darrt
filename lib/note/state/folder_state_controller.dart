import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:minimaltodo/app/state/controllers/state_controller.dart';
import 'package:minimaltodo/note/models/folder.dart';
part 'folder_state_controller.freezed.dart';

@freezed
class FolderState with _$FolderState{
  const factory FolderState() = _FolderState;
  const FolderState._();
}
class FolderStateController extends StateController<FolderState, Folder> {
  @override
  void initState(bool edit, [Folder? model]) {
    textController.text = edit ? model!.name : '';
  }

  @override
  void clearState() {
    textController.clear();
  }

  @override
  Folder buildModel({required bool edit, Folder? model}) {
    final folder = model;
    return Folder(
      name: textController.text,
      id: edit ? folder!.id : 0,
    );
  }
}