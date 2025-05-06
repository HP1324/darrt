import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:minimaltodo/category/category_model.dart';
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
class CategoryStateController extends ChangeNotifier {
  late CategoryState _state;

  CategoryState get state => _state;

  final TextEditingController nameController = TextEditingController();

  final FocusNode textFieldNode = FocusNode();

  void initCategoryState(bool edit, [CategoryModel? category]) {
    nameController.text = edit ? category!.name : '';
    _state = CategoryState(
      icon: edit ? category!.icon : 'folder',
      color: edit ? category!.color : 'primary',
    );
  }

  void clearCategoryState() {
    _state = _state.copyWith(
      icon: 'folder',
      color: 'primary',
    );
    nameController.clear();
  }

  CategoryModel buildCategory({required bool edit, CategoryModel? category}) {
    return CategoryModel(
      name: nameController.text,
      icon: icon,
      color: color,
      id: edit ? category!.id : 0,
    );
  }

  void setIcon(String newIcon) {
    _state = _state.copyWith(icon: newIcon);
    notifyListeners();
  }

  void setColor(String newColor) {
    _state = _state.copyWith(color: newColor);
    notifyListeners();
  }
}

extension AccessState on CategoryStateController {
  String get icon => _state.icon;
  String get color => _state.color;
}