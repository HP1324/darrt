import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:minimaltodo/data_models/list_model.dart';
import 'package:minimaltodo/global_utils.dart';
import 'package:minimaltodo/services/list_service.dart';
import 'package:minimaltodo/view_models/task_view_model.dart';

class ListViewModel extends ChangeNotifier {
  ListViewModel() {
    _refreshLists();
  }
  List<ListModel> lists = [];
  final listScrollController = ScrollController();
  ListModel? currentList = ListModel(iconCode: 'folder');
  set name(String name) => currentList!.name = name;
  set iconCode(String iconCode) => currentList!.iconCode = iconCode;
  set listColor(String listColor) => currentList!.listColor  = listColor;
  String? selectedIcon = 'folder'; // Default icon
  String? selectedColor;
  void _refreshLists() async {
    lists = await ListService.getLists();

    if (kDebugMode) {
      debugPrint(lists.toString());
    }
    notifyListeners();
  }

  Future<bool> addNewList() async {
    logger.d('AddNewList() called');
    if (currentList!.isValid()) {
    logger.d('currentList is valid');
      final id = await ListService.addList(currentList!);
      // Reset selected icon after adding
      selectedIcon = 'folder';
      _refreshLists();
      return true;
    }
    return false;
  }

  Future<bool> deleteList(ListModel list, TaskViewModel taskVM) async {
    int rowsAffected = await ListService.deleteList(list.id!);
    if (rowsAffected > 0) {
      lists.removeWhere((c) => c.id == list.id);

      // Update tasks directly using the passed taskVM
      taskVM.updateTasksAfterListDeletion(list.id!);

      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> editList() async {
    final changes = await ListService.editList(currentList!);
    if(changes > 0) {
      notifyListeners();
      return true;
    }
    return false;
  }

  ListModel? selectedList;
  void updateChosenList(ListModel selected) {
    selectedList = selected;
    //Not calling notify listeners here, because called it in TaskViewModel where the currentTask's list is selected, because of state reaction problems.
  }

  void resetList() {
    selectedList = null;
    selectedIcon = 'folder';
    selectedColor = 'primary';
    notifyListeners();
  }

  void updateSelectedIcon(String iconCode) {
    selectedIcon = iconCode;
    currentList!.iconCode = iconCode;
    notifyListeners();
  }

  void resetIconSelection() {
    selectedIcon = 'folder';
    notifyListeners();
  }

  void updateSelectedColor(String listColor){
    selectedColor = listColor;
    currentList!.listColor = listColor;
    notifyListeners();
  }
}
