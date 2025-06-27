import 'package:minimaltodo/category/models/category_model.dart';
import 'package:minimaltodo/helpers/messages.dart';
import 'package:minimaltodo/app/state/viewmodels/view_model.dart';
import 'package:flutter/material.dart';
class CategoryViewModel extends ViewModel<CategoryModel> {
  final ScrollController scrollController = ScrollController();

  List<CategoryModel> get categories => items;
  @override
  String putItem(CategoryModel item,{required bool edit, bool scrollToBottom = true}) {
    final category = item;
    if(!edit && items.indexWhere((c) => c.name == category.name) != -1) return Messages.mCategoryExists;
    if (category.name.trim().isEmpty) return Messages.mCategoryEmpty;
    final message = super.putItem(category, edit: edit);

    if(scrollToBottom) {
      scrollController.animateTo(
          scrollController.position.maxScrollExtent, duration: Duration(milliseconds: 300),
          curve: Curves.easeIn);
    }

    return message;
  }
@override
  String deleteItem(int id) {

    final message = super.deleteItem(id);
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

  @override
  void setItemId(CategoryModel item, int id) {
    item.id =id;
  }
}