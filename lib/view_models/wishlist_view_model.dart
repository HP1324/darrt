import 'package:flutter/material.dart';
import 'package:minimaltodo/data_models/wishlist.dart';
import 'package:minimaltodo/services/wishlist_service.dart';

class WishListViewModel extends ChangeNotifier {
  List<WishList> _wishLists = [];
  List<int> selectedIds = [];
  bool isSelectionMode = false;
  final TextEditingController titleController = TextEditingController();
  WishList? editingWishList;
  bool isAddingNew = false;

  List<WishList> get wishLists => _wishLists;

  WishListViewModel() {
    _loadWishLists();
  }

  Future<void> _loadWishLists() async {
    _wishLists = await WishListService.getWishLists();
    notifyListeners();
  }

  Future<void> addWishList(String title) async {
    if (title.trim().isEmpty) return;

    final wishList = WishList(title: title.trim());
    await WishListService.addWishList(wishList);
    isAddingNew = false;
    titleController.clear();
    await _loadWishLists();
  }

  Future<void> updateWishList(WishList wishList, String newTitle) async {
    if (newTitle.trim().isEmpty) return;

    wishList.title = newTitle.trim();
    await WishListService.updateWishList(wishList);
    editingWishList = null;
    await _loadWishLists();
  }

  Future<void> toggleFulfilled(WishList wishList) async {
    await WishListService.toggleFulfilled(wishList.id!, !wishList.isFulfilled);
    await _loadWishLists();
  }

  void clearSelection() {
    selectedIds.clear();
    isSelectionMode = false;
    notifyListeners();
  }

  void toggleSelection(int id) {
    if (selectedIds.contains(id)) {
      selectedIds.remove(id);
    } else {
      selectedIds.add(id);
    }
    isSelectionMode = selectedIds.isNotEmpty;
    notifyListeners();
  }

  Future<void> deleteSelected() async {
    for (var id in selectedIds) {
      await WishListService.deleteWishList(id);
    }
    selectedIds.clear();
    isSelectionMode = false;
    await _loadWishLists();
  }

  void startEditing(WishList wishList) {
    editingWishList = wishList;
    titleController.text = wishList.title;
    notifyListeners();
  }

  void cancelEditing() {
    editingWishList = null;
    titleController.clear();
    notifyListeners();
  }

  void startNewWish() {
    isAddingNew = true;
    titleController.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }
}
