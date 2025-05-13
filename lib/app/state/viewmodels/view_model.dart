import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:minimaltodo/helpers/object_box.dart';
import 'package:minimaltodo/objectbox.g.dart' show Box;

/// Generic abstract class for view models that manage collections of model objects
/// T is the model type (e.g., CategoryModel, Task)
abstract class ViewModel<T> extends ChangeNotifier {
  /// The list of model objects
  List<T> _items = [];

  /// Getter for the list of model objects
  List<T> get items => _items;

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

  // bool validateItem(T item);
  /// Add or update an item in the database and the local list.
  /// Returns a message indicating success or failure.
  /// Child classes may override this method for implementing custom behavior (i.e., Validating [item])
  String putItem(T item, {required bool edit}) {
    final id = _box.put(item);
    if(edit){
      int index = _items.indexWhere((i)=>getItemId(i) == id);
      if(index != -1){
        _items[index] = item;
        debugPrint('Item id: ${getItemId(item)}');
      }
    }else{
      _items.add(item);
    }
    if(kDebugMode){
      debugPrint('Item added/updated with id: $id, item type: ${item.runtimeType}');
    }
    notifyListeners();
    return edit ? getUpdateSuccessMessage() : getCreateSuccessMessage();
  }

  /// Delete an item from the database and the local list.
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

}
