import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:minimaltodo/category/category_model.dart';
import 'package:minimaltodo/helpers/object_box.dart';

class CategoryViewModel extends ChangeNotifier {
  CategoryViewModel() {
    _categories = ObjectBox.store.box<CategoryModel>().getAll();
  }
  List<CategoryModel> _categories = [];
  final _box = ObjectBox.store.box<CategoryModel>();
  List<CategoryModel> get categories => _categories;

  String putCategory(CategoryModel category,{required bool edit}) {
    if (category.name.trim().isEmpty) return 'Enter a category name first';
    final id = _box.put(category);
    if(edit){
      int index = _categories.indexWhere((c)=>c.id == id);
      if(index != -1){
        _categories[index]=category;
      }
    }else{
      _categories.add(category);
    }
    notifyListeners();
    debugPrint('Category added with id: $id - ${category.name} ${category.color} ${category.icon}');
    return edit ? 'Category updated' : 'Category added';
  }
  void deleteCategory(int id){
    _box.remove(id);
    final index = _categories.indexWhere((c)=> c.id == id);
    _categories.removeAt(index);
    notifyListeners();
  }
}