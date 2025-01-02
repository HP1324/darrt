import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:minimaltodo/data_models/category.dart';
import 'package:minimaltodo/services/category_service.dart';
import 'package:minimaltodo/view_models/task_view_model.dart';

class CategoryViewModel extends ChangeNotifier {
  CategoryViewModel() {
    _refreshCategories();
  }
  List<CategoryModel> categories = [];
  final listScrollController = ScrollController();

  // General category for tasks without a specific category
  final generalCategory = CategoryModel(
    categoryId: -1,  // Special ID for general category
    categoryName: 'General',
  );

  void _refreshCategories() async {
    categories = await CategoryService.getCategories();
    // Always ensure General category is first in the list
    if (!categories.any((c) => c.categoryId == generalCategory.categoryId)) {
      categories.insert(0, generalCategory);
    }
    if(kDebugMode){
      debugPrint('${categories.toString()}');
    }
    notifyListeners();
  }

  Future<bool> addNewCategory(CategoryModel category) async {
    if(category.isValid()){
      final id = await CategoryService.addCategory(category);
      _refreshCategories();
      return true;
    }
    return false;
  }

  Future<bool> deleteCategory(CategoryModel category, TaskViewModel taskVM) async {
    if (category.categoryId == -1) return false; // Prevent deletion of General category
    
    int rowsAffected = await CategoryService.deleteCategory(category.categoryId!);
    if (rowsAffected > 0) {
      categories.removeWhere((c) => c.categoryId == category.categoryId);
      
      // Update tasks directly using the passed taskVM
      taskVM.updateTasksAfterCategoryDeletion(category.categoryId!);
      
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> editCategory(CategoryModel category, String newName) async {
    if(newName.trim().isEmpty) return false;
    
    category.categoryName = newName.trim();
    int rowsAffected = await CategoryService.editCategory(category);
    if(rowsAffected > 0){
      _refreshCategories();
      return true;
    }
    return false;
  }

  CategoryModel? chosenCategory;
  void updateChosenCategory(CategoryModel selected){
    chosenCategory = selected;
    //Not calling notify listeners here, because called it in TaskViewModel where the currenTask's category is selected, because of state reaction problems.
  }
  void resetCategory(){
    chosenCategory = null;
    notifyListeners();
  }

}

CategoryModel getCategoryById(int id){
  CategoryViewModel cvm = CategoryViewModel();
  CategoryModel cm = CategoryModel();
  cm = cvm.categories.firstWhere((c) => c.categoryId == id);
  return cm;
}
