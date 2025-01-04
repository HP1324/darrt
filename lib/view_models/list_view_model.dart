import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:minimaltodo/data_models/list_model.dart';
import 'package:minimaltodo/services/list_service.dart';
import 'package:minimaltodo/view_models/task_view_model.dart';

class ListViewModel extends ChangeNotifier {
  ListViewModel() {
    _refreshLists();
  }
  List<ListModel> lists = [];
  final listScrollController = ScrollController();

  // General list for tasks without a specific list
  final generalList = ListModel(
    id: -1, // Special ID for general list
    name: 'General',
    iconCode: 'folder',
  );
  ListModel? currentList = ListModel();
  String? selectedIcon = 'folder'; // Default icon

  void _refreshLists() async {
    lists = await ListService.getLists();
    // Always ensure General list is first in the list
    if (!lists.any((c) => c.id == generalList.id)) {
      lists.insert(0, generalList);
    }
    if (kDebugMode) {
      debugPrint(lists.toString());
    }
    notifyListeners();
  }

  Future<bool> addNewList(ListModel list) async {
    if (list.isValid()) {
      // Set the selected icon before adding
      list.iconCode = selectedIcon;
      final id = await ListService.addList(list);
      _refreshLists();
      // Reset selected icon after adding
      selectedIcon = 'folder';
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> deleteList(ListModel list, TaskViewModel taskVM) async {
    if (list.id == -1) return false; // Prevent deletion of General list

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

  Future<bool> editList(ListModel list, String newName) async {
    if (newName.trim().isEmpty) return false;

    list.name = newName.trim();
    int rowsAffected = await ListService.editList(list);
    if (rowsAffected > 0) {
      _refreshLists();
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
    notifyListeners();
  }

  void updateSelectedIcon(String iconCode) {
    selectedIcon = iconCode;
    notifyListeners();
  }

  void resetIconSelection() {
    selectedIcon = 'folder';
    notifyListeners();
  }
}
