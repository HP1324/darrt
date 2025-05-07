import 'package:flutter/material.dart';
import 'package:minimaltodo/helpers/object_box.dart';

/// Generic abstract class for view models that manage collections of model objects
/// T is the model type (e.g., CategoryModel, Task)
abstract class ViewModel<T> extends ChangeNotifier {
  /// The list of model objects
  List<T> _items = [];

  /// The ObjectBox store box for database operations
  final _box = ObjectBox.store.box<T>();

  /// Getter for the list of model objects
  List<T> get items => _items;

  /// Constructor initializes the items from the database
  ViewModel() {
    _initializeItems();
  }

  /// Initialize the list of items from the database.
  /// Child classes may override this method for implementing custom behavior
  void _initializeItems() {
    _items = _box.getAll();
  }

  ///Validate the item before saving
  bool validateItem(T item);

  /// Add or update an item in the database and the local list.
  /// Returns a message indicating success or failure.
  /// Child classes may override this method for implementing custom behavior (i.e., Validating [item])
  String putItem(T item, {required bool edit}) {

    final id = _box.put(item);
    if(edit){
      int index = _items.indexWhere((i)=>i == item);
      if(index != -1){
        _items[index] = item;
      }
    }else{
      _items.add(item);
    }
    notifyListeners();
    return edit ? getUpdateSuccessMessage() : getCreateSuccessMessage();
  }

  /// Delete an item from the database and the local list.
  /// Child classes may override this method for implementing custom behavior
  void deleteItem(int id) {
    _box.remove(id);
    _items.removeWhere((i) => getItemId(i) == id);
    notifyListeners();
  }

  /// Get success message for item creation
  String getCreateSuccessMessage();

  /// Get success message for item update
  String getUpdateSuccessMessage();

  /// Get the ID of an item
  int getItemId(T item);

}
