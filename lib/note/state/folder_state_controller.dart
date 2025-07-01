import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:minimaltodo/app/state/controllers/state_controller.dart';
import 'package:minimaltodo/note/models/folder.dart';
part 'folder_state_controller.freezed.dart';

@freezed
abstract class FolderState with _$FolderState {
  const factory FolderState({
    required String color,
    required String icon,
  }) = _FolderState;
  const FolderState._();
}

class FolderStateController extends StateController<FolderState, Folder> {
  @override
  void initState(bool edit, [Folder? model]) {
    textController.text = edit ? model!.name : '';
    state = FolderState(
      color: edit ? model!.color : 'primary',
      icon: edit ? model!.icon : 'folder',
    );
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
      uuid: color,
      icon: icon,
      color: color,
    );
  }

  void setColor(String newColor) {
    state = state.copyWith(color: newColor);
    notifyListeners();
  }

  void setIcon(String icon) {
    state = state.copyWith(icon: icon);
    notifyListeners();
  }
}

extension AccessState on FolderStateController {
  String get color => state.color;
  String get icon => state.icon;
}
