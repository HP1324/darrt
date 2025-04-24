
import 'package:flutter/material.dart';
import 'package:minimaltodo/category/category_model.dart';

class CategoryStateController extends ChangeNotifier {
  TextEditingController nameController = TextEditingController();
  String icon = 'folder';
  String color = 'primary';
  void initCategoryState(CategoryModel category) {
    nameController.text = category.name;
    icon = category.icon;
    color = category.color;
  }
  void clearCategoryState(){
    nameController.clear();
    icon = 'folder';
    color = 'primary';
  }
  CategoryModel buildCategory({required bool edit, CategoryModel? category}) {
    return CategoryModel(
      id: edit? category!.id : 0,
      name: nameController.text,
      icon: icon,
      color: color,
    );
  }

  void setIcon(String newIcon) {
    icon = newIcon;
    notifyListeners();
  }

  void setColor(String newColor) {
    color = newColor;
    notifyListeners();
  }
}
