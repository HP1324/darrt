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

  // void putManyItems(List<T> restoredItems) {
  //   MiniLogger.d('items length: ${restoredItems.length}');
  //   bool isEmptyDatabase = _box.getAll().isEmpty;
  //
  //   //List to be put in database based on conditions
  //   // List<T> newItems = [];
  //   final allLocalItems = _box.getAll();
  //   for (final item in restoredItems) {
  //     final localItem = _box.get(getItemId(item));
  //     if (localItem != null) {
  //       if ((item is Task && item.equals(localItem as Task, checkIdEquality: true)) ||
  //           (item is Note && item.equals(localItem as Note, checkIdEquality: true)) ||
  //           (item is Folder && item.equals(localItem as Folder, checkIdEquality: true)) ||
  //           (item is CategoryModel &&
  //               item.equals(localItem as CategoryModel, checkIdEquality: true))) {
  //         continue;
  //       } else {
  //         setItemId(item, 0);
  //       }
  //     } else {
  //       final duplicateExistsWithDifferentId = allLocalItems.any((e) {
  //         if (e is Task) {
  //           debugPrint('Duplicate task ${e.title} exists with id ${e.id}');
  //           return e.equals(item as Task);
  //         } else if (e is Note) {
  //           return e.equals(item as Note);
  //         } else if (e is Folder) {
  //           return e.equals(item as Folder);
  //         } else if (e is CategoryModel) {
  //           return e.equals(item as CategoryModel);
  //         }
  //         return false;
  //       });
  //       if (duplicateExistsWithDifferentId) {
  //         continue;
  //       }
  //     }
  //     _box.put(item);
  //   }
  //   initializeItemsWithRebuilding();
  //
  // }
  void putManyItems(List<T> restoredItems) {
    MiniLogger.d('items length: ${restoredItems.length}');

    final allLocalItems = _box.getAll();

    for (final item in restoredItems) {
      final localItemById = _box.get(getItemId(item));

      // Case 1: Same ID, same content -> skip
      final isIdentical = (item is Task && localItemById is Task && item.equals(localItemById, checkIdEquality: true)) ||
          (item is Note && localItemById is Note && item.equals(localItemById, checkIdEquality: true)) ||
          (item is Folder && localItemById is Folder && item.equals(localItemById, checkIdEquality: true)) ||
          (item is CategoryModel && localItemById is CategoryModel && item.equals(localItemById, checkIdEquality: true));

      if (isIdentical) continue;

      // Case 2: Same content exists under different ID -> skip
      final contentDuplicateExists = allLocalItems.any((e) {
        if (e.runtimeType != item.runtimeType) return false;

        if (item is Task) return e is Task && item.equals(e, checkIdEquality: false);
        if (item is Note) return e is Note && item.equals(e, checkIdEquality: false);
        if (item is Folder) return e is Folder && item.equals(e, checkIdEquality: false);
        if (item is CategoryModel) return e is CategoryModel && item.equals(e, checkIdEquality: false);
        return false;
      });

      if (contentDuplicateExists) {
        MiniLogger.d('Skipping duplicate item (content matched but id different): ${getItemId(item)}');
        continue;
      }

      // Case 3: Same ID but different content -> insert as new
      if (localItemById != null) {
        setItemId(item, 0);
      }

      _box.put(item);
    }

    initializeItemsWithRebuilding();
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
