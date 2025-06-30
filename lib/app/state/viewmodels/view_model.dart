import 'dart:developer' as dev;

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:minimaltodo/app/services/backup_service.dart' show MergeType;
import 'package:minimaltodo/helpers/mini_logger.dart';
import 'package:minimaltodo/helpers/object_box.dart';
import 'package:minimaltodo/helpers/typedefs.dart';
import 'package:minimaltodo/objectbox.g.dart' show Box;

/// Generic abstract class for view models that manage collections of model objects
/// T is the model type (e.g., CategoryModel, Task)
abstract class ViewModel<T> extends ChangeNotifier {
  /// The list of model objects
  List<T> _items = [];

  /// Getter for the list of model objects
  List<T> get items => _items;

  set setItems(List<T> items) => _items = items;

  /// The ObjectBox store box for database operations
  final _box = ObjectBox.store!.box<T>();

  /// Getter or _box
  Box<T> get box => _box;

  /// Selected item IDs, for handling operations like multiple item deletion etc.
  final Set<int> _selectedItemIds = {};

  Set<int> get selectedItemIds => _selectedItemIds;

  /// Constructor initializes the items from the database
  ViewModel() {
    initializeItems();
  }

  /// Initialize the list of items from the database.
  /// Child classes may override this method for implementing custom behavior
  void initializeItems() {
    _items = _box.getAll();
  }

  void initializeItemsWithRebuilding() {
    _items = _box.getAll();
    notifyListeners();
  }

  // bool validateItem(T item);
  /// Add or update an item in the Local ObjectBox database and the in-memory list.
  /// Returns a message indicating success or failure.
  /// Child classes may override this method for implementing custom behavior (i.e., Validating [item])
  String putItem(T item, {required bool edit}) {
    final id = _box.put(item);

    if (edit) {
      int index = _items.indexWhere((i) => getItemId(i) == id);
      if (index != -1) {
        _items[index] = item;
        MiniLogger.d('Item id: ${getItemId(item)}');
      }
    } else {
      _items.add(item);
    }

    MiniLogger.d('Item added/updated with id: $id, item type: ${item.runtimeType}');

    notifyListeners();
    return edit ? getUpdateSuccessMessage() : getCreateSuccessMessage();
  }

  void putManyForRestore(List<T> restoredItems);

  /// Delete an item from the local ObjectBox database and the in-memory list.
  /// Child classes may override this method for implementing custom behavior
  String deleteItem(int id) {
    _box.remove(id);
    _items.removeWhere((i) => getItemId(i) == id);
    notifyListeners();
    return getDeleteSuccessMessage(1);
  }

  String deleteMultipleItems() {
    _box.removeMany(_selectedItemIds.toList());
    _items.removeWhere((i) => _selectedItemIds.contains(getItemId(i)));
    notifyListeners();
    final length = _selectedItemIds.length;
    _selectedItemIds.clear();
    return getDeleteSuccessMessage(length);
  }

  void toggleSelection(int id) {
    if (selectedItemIds.contains(id)) {
      selectedItemIds.remove(id);
    } else {
      selectedItemIds.add(id);
    }
    notifyListeners();
  }

  void clearSelection() {
    _selectedItemIds.clear();
    notifyListeners();
  }

  /// Get success message for item creation
  String getCreateSuccessMessage();

  /// Get success message for item update
  String getUpdateSuccessMessage();

  /// Get success message for item deletion
  String getDeleteSuccessMessage(int length);

  /// Get the ID of an item
  int getItemId(T item);

  /// Set the ID of an item
  void setItemId(T item, int id);

  EntityObjectListMap<T> mergeItems(
    EntityObjectListMap<T> oldItems,
    EntityObjectListMap<T> newItems, {
    required MergeType mergeType,
  }) {
    // If any item with same 'uuid' field exists in oldItems, then if mergeType is MergeType.backup, just update it with the item with same uuid in newItems. and if mergeType is MergeType.restore, skip the item and keep the item in oldItems as it is. and if an item with same uuid does not exist in oldItems, just add it in both mode. also in restore mode, set the item.id field to zero before merging it
    EntityObjectListMap<T> mergedItems = EntityObjectListMap.from(oldItems);
    for (var key in newItems.keys) {
      final oldList = mergedItems[key] ?? [];
      final newList = newItems[key] ?? [];
      List<T> mergedList = List.from(oldList);
      for (var item in newList) {
        final oldItemWithSameUuid = oldList.firstWhereOrNull(
          (e) => getItemUuid(e) == getItemUuid(item),
        );
        if (oldItemWithSameUuid != null) {
          if (mergeType == MergeType.backup) {
            final index = mergedList.indexOf(oldItemWithSameUuid);
            if (index != -1) mergedList[index] = item;
          }
        } else {
          if (mergeType == MergeType.restore) setItemId(item, 0);
          mergedList.add(item);
        }
      }
      mergedItems[key] = mergedList;
    }
    return mergedItems;
  }

    EntityObjectList<T> mergeItemLists(
      EntityObjectList<T> oldList,
      EntityObjectList<T> newList, {
      required MergeType mergeType,
    }) {
      // If any item with same 'uuid' field exists in oldItems, then if mergeType is MergeType.backup, just update it with the item with same uuid in newItems. and if mergeType is MergeType.restore, skip the item and keep the item in oldItems as it is. and if an item with same uuid does not exist in oldItems, just add it in both mode. also in restore mode, set the item.id field to zero before merging it
      dev.log('Old list ids: ${oldList.map((e) {getItemId(e); print('item type: ${e.runtimeType}');})}');
      dev.log('New list ids: ${oldList.map((e) {getItemId(e); print('item type: ${e.runtimeType}');})}');
      EntityObjectList<T> mergedList = EntityObjectList.from(oldList);
      for (var item in newList) {
        final oldItemWithSameUuid = mergedList.firstWhereOrNull(
          (e) => getItemUuid(e) == getItemUuid(item),
        );
        if (oldItemWithSameUuid != null) {
          if (mergeType == MergeType.backup) {
            final index = mergedList.indexOf(oldItemWithSameUuid);
            if (index != -1) mergedList[index] = item;
          }
        } else {
          if (mergeType == MergeType.restore) setItemId(item, 0);
          mergedList.add(item);
        }
      }

      return mergedList;
    }

  /// Convert [EntityJsonList] to [EntityObjectList]
  EntityObjectList<T> convertJsonListToObjectList(EntityJsonList jsonList);

  /// Convert [EntityObjectList] to [EntityJsonList]
  EntityJsonList convertObjectsListToJsonList(EntityObjectList<T> objectList);

  String getItemUuid(T item);
}
