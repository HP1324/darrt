import 'package:flutter/foundation.dart';
import 'package:minimaltodo/category/models/category_model.dart';
import 'package:minimaltodo/helpers/globals.dart' as g;
import 'package:minimaltodo/helpers/mini_logger.dart';
import 'package:minimaltodo/helpers/object_box.dart';
import 'package:minimaltodo/note/models/folder.dart';
import 'package:minimaltodo/note/models/note.dart';
import 'package:minimaltodo/objectbox.g.dart' show Box;
import 'package:minimaltodo/task/models/task.dart';

/// Generic abstract class for view models that manage collections of model objects
/// T is the model type (e.g., CategoryModel, Task)
abstract class ViewModel<T> extends ChangeNotifier {
  /// The list of model objects
  List<T> _items = [];

  /// Getter for the list of model objects
  List<T> get items => _items;

  set setItems(List<T> items) => _items = items;

  /// The ObjectBox store box for database operations
  final _box = ObjectBox.store.box<T>();

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

  void putManyItems(List<T> restoredItems) {
    MiniLogger.d('items length: ${restoredItems.length}');
    bool isEmptyDatabase = _box.getAll().isEmpty;

    //List to be put in database based on conditions
    // List<T> newItems = [];
    for (final item in restoredItems) {
      final localItem = _box.get(getItemId(item));
      if (localItem != null) {
        if ((item is Task && item.equals(localItem as Task, checkIdEquality: true)) ||
            (item is Note && item.equals(localItem as Note, checkIdEquality: true)) ||
            (item is Folder && item.equals(localItem as Folder, checkIdEquality: true)) ||
            (item is CategoryModel &&
                item.equals(localItem as CategoryModel, checkIdEquality: true))) {
          continue;
        } else {
          setItemId(item, 0);
        }
      } else {
        final duplicateExistsWithDifferentId = _box.getAll().any((e) {
          if (e is Task) {
            return e.equals(item as Task);
          } else if (e is Note) {
            return e.equals(item as Note);
          } else if (e is Folder) {
            return e.equals(item as Folder);
          } else if (e is CategoryModel) {
            return e.equals(item as CategoryModel);
          }
          return false;
        });
        if (duplicateExistsWithDifferentId) {
          continue;
        }
      }
      _box.put(item);
      initializeItemsWithRebuilding();
    }

    //Assign 0 to item id if database is empty or item is not in the database, so that objectbox doesn't throw id not valid error
    // for (final item in manyItems) {
    //   final id = getItemId(item);
    //   if (!isEmptyDatabase) {
    //     if (_box.contains(id)) {
    //       if (item is CategoryModel) {
    //         g.catVm.putItem(item, edit: true, scrollToBottom: false);
    //       } else {
    //         putItem(item, edit: true);
    //       }
    //     } else {
    //       debugPrint('');
    //       setItemId(item, 0);
    //       if (item is CategoryModel) {
    //         g.catVm.putItem(item, edit: false, scrollToBottom: false);
    //       } else {
    //         putItem(item, edit: false);
    //       }
    //     }
    //   } else {
    //     setItemId(item, 0);
    //     putItem(item, edit: false);
    //   }
    // }
    // for (final item in restoredItems) {
    //   if (item is Task && (!_box.contains(item.id) || isEmptyDatabase)) item.id = 0;
    //   if (item is Note && (!_box.contains(item.id) || isEmptyDatabase)) item.id = 0;
    //   if (item is Folder && (!_box.contains(item.id) || isEmptyDatabase)) item.id = 0;
    //   if (item is CategoryModel && (!_box.contains(item.id) || isEmptyDatabase)) item.id = 0;
    // }
    // newItems = List.from(restoredItems);
    //
    // final ids = _box.putMany(newItems);
    //
    // initializeItemsWithRebuilding();

    // MiniLogger.d('Items added/updated with ids: $ids');
    // notifyListeners();
  }

  String _getPrimaryLabel(T item) {
    if (item is Task) return item.title;
    if (item is Note) return item.content;
    if (item is Folder) return item.name;
    if (item is CategoryModel) return item.name;
    return '';
  }

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
}
