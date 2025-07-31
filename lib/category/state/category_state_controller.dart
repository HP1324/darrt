import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:darrt/category/models/entity_category.dart';
import 'package:darrt/app/state/controllers/state_controller.dart';
part 'category_state_controller.freezed.dart';

///Immutable data-class to store the temporary state of the category add page
@freezed
abstract class CategoryState with _$CategoryState {
  const factory CategoryState({
    required String icon,
    required String color,
  }) = _CategoryState;
  const CategoryState._();
}

///Controls the temporary state of the category add page when category is being added or updated
class CategoryStateController extends StateController<CategoryState, EntityCategory> {
  @override
  void initState(bool edit, [EntityCategory? category]) {
    textController.text = edit ? category!.name : '';
    state = CategoryState(
      icon: edit ? category!.icon : 'folder',
      color: edit ? category!.color : 'primary',
    );
  }

  @override
  void clearState() {
    state = state.copyWith(
      icon: 'folder',
      color: 'primary',
    );
    textController.clear();
  }

  @override
  EntityCategory buildModel({required bool edit, EntityCategory? model}) {
    final category = model;
    return EntityCategory(
      name: textController.text,
      icon: icon,
      color: color,
      id: edit ? category!.id : 0,
      uuid: edit? category!.uuid : null,
    );
  }

  void setIcon(String newIcon) {
    state = state.copyWith(icon: newIcon);
    notifyListeners();
  }

  void setColor(String newColor) {
    state = state.copyWith(color: newColor);
    notifyListeners();
  }
}

extension AccessState on CategoryStateController {
  String get icon => state.icon;
  String get color => state.color;
}
