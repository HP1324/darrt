import 'package:darrt/app/state/controllers/state_controller.dart';
import 'package:darrt/folder/models/folder.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'folder_state_controller.freezed.dart';

@freezed
abstract class FolderState with _$FolderState {
  const factory FolderState({
    required String name,
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
      name: edit ? model!.name : '',
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
      name: name,
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

  void setName(String value){
    state = state.copyWith(name: value);
  }
}

extension AccessState on FolderStateController {
  String get color => state.color;
  String get icon => state.icon;
  String get name => state.name;
}
