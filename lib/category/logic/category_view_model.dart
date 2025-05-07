import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:minimaltodo/category/category_model.dart';
import 'package:minimaltodo/helpers/messages.dart';
import 'package:minimaltodo/state/view_model.dart';

class CategoryViewModel extends ViewModel<CategoryModel> {

  List<CategoryModel> get categories => items;
  @override
  String putItem(CategoryModel item,{required bool edit}) {
    final category = item;
    if (category.name.trim().isEmpty) return Messages.mCategoryEmpty;
    final message = super.putItem(category, edit: edit);
    notifyListeners();
    return message;
  }


  @override
  int getItemId(CategoryModel item) =>item.id;

  @override
  String getCreateSuccessMessage() => Messages.mCategoryAdded;

  @override
  String getUpdateSuccessMessage() => Messages.mCategoryEdited;

  @override
  String getDeleteSuccessMessage(int length) => length == 1 ? '1 ${Messages.mCategoryDeleted}' : '$length ${Messages.mCategoriesDeleted}';
}