import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:minimaltodo/data_models/category_model.dart';
import 'package:minimaltodo/helpers/mini_utils.dart';
import 'package:minimaltodo/services/category_service.dart';
import 'package:minimaltodo/view_models/task_view_model.dart';

class CategoryViewModel extends ChangeNotifier {
  CategoryViewModel() {
    _refreshCategories();
  }
  List<CategoryModel> categories = [];
  final categoryBottomSheetScrollController = ScrollController();
  final categoryPageScrollController = ScrollController();
  CategoryModel? currentCategory = CategoryModel(iconCode: 'folder');
  set name(String name) => currentCategory!.name = name;
  set iconCode(String iconCode) => currentCategory!.iconCode = iconCode;
  set color(String listColor) => currentCategory!.color  = listColor;
  String? selectedIcon = 'folder'; // Default icon
  String? selectedColor;
  void _refreshCategories() async {
    categories = await CategoryService.getCategories();

    if (kDebugMode) {
      debugPrint(categories.toString());
    }
    notifyListeners();
  }

  Future<bool> addNewCategory() async {
    logger.d('AddNewList() called');
    if (currentCategory!.isValid()) {
    logger.d('currentList is valid');
      final id = await CategoryService.addCategory(currentCategory!);
      selectedIcon = 'folder';
      _refreshCategories();
      return true;
    }
    return false;
  }

  Future<bool> deleteCategory(CategoryModel category, TaskViewModel taskVM) async {
    int rowsAffected = await CategoryService.deleteCategory(category.id!);
    if (rowsAffected > 0) {
      categories.removeWhere((c) => c.id == category.id);

      // Update tasks directly using the passed taskVM
      taskVM.updateTasksAfterListDeletion(category.id!);

      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> editCategory() async {
    final changes = await CategoryService.editCategory(currentCategory!);
    if(changes > 0) {
      notifyListeners();
      return true;
    }
    return false;
  }

  CategoryModel? selectedList;
  void updateChosenCategory(CategoryModel selected) {
    selectedList = selected;
    //Not calling notify listeners here, because called it in TaskViewModel where the currentTask's list is selected, because of state reaction problems.
  }

  void resetCategory() {
    selectedList = null;
    selectedIcon = 'folder';
    selectedColor = 'primary';
    notifyListeners();
  }

  void updateSelectedIcon(String iconCode) {
    selectedIcon = iconCode;
    currentCategory!.iconCode = iconCode;
    notifyListeners();
  }

  void resetIconSelection() {
    selectedIcon = 'folder';
    notifyListeners();
  }

  void updateSelectedColor(String categoryColor,TaskViewModel taskVM){
    selectedColor = categoryColor;
    currentCategory!.color = categoryColor;
    notifyListeners();
  }
}
