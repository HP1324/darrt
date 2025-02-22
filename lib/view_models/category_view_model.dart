import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:minimaltodo/data_models/category_model.dart';
import 'package:minimaltodo/data_models/task.dart';
import 'package:minimaltodo/helpers/mini_utils.dart';
import 'package:minimaltodo/services/category_service.dart';
import 'package:minimaltodo/services/task_service.dart';
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
  Map<int, bool> selectedCategories = {};
  void updateSelectedCategories(int id, bool updatedStatus){
    selectedCategories[id] = updatedStatus;
    if (!selectedCategories.entries.any((entry) => entry.key != 1 && entry.value)) {
      selectedCategories[1] = true;
    }

    if (id == 1 && !updatedStatus) {
      if (!selectedCategories.entries
          .any((entry) => entry.key != 1 && entry.value)) {
        selectedCategories[1] = true;
      }
    }
    notifyListeners();
  }
  void _refreshCategories() async {
    categories = await CategoryService.getCategories();
    for(var c in categories){
      selectedCategories[c.id!] = c.id! ==1 ? true : false;
    }
    notifyListeners();
  }

  void resetCategorySelectionStatus(bool editMode, [Task? task]) async {
    if (!editMode) {
      for (var c in categories) {
        selectedCategories[c.id!] = c.id! == 1; // Select default category only
      }
    } else {
      if (task != null) {
        final taskCategories = await TaskService.getTaskCategories(task.id!);
        for (var c in categories) {
          selectedCategories[c.id!] = taskCategories.contains(c);
        }
      }
    }
    notifyListeners(); // Ensure UI updates if using ChangeNotifier
  }


  Future<bool> addNewCategory() async {
    if (currentCategory!.isValid()) {
      final id = await CategoryService.addCategory(currentCategory!);
      selectedIcon = 'folder';
      _refreshCategories();
      return true;
    }
    return false;
  }

  Future<bool> deleteCategory(CategoryModel category) async {
    int rowsAffected = await CategoryService.deleteCategory(category.id!);
    if (rowsAffected > 0) {
      //Have to create new list because selector does not update the ui because it checks with == operator which for lists only checks reference equality.
      categories = categories.where((item) => item != category).toList();
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



  void resetCategory() {
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
