import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:minimaltodo/category/models/category_model.dart';
import 'package:minimaltodo/helpers/mini_box.dart';
import 'package:minimaltodo/objectbox.g.dart';
import 'package:minimaltodo/task/models/task.dart';
import 'package:minimaltodo/task/models/task_completion.dart';

late final Admin admin;

class ObjectBox {
  static late final Store _store;
  static bool _initialized = false;
  static Future<void> init() async {
    if (_initialized) return;
    _store = await openStore();
    _initialized = true;
    _putInitialCategories();
    if (kDebugMode) {
      if (Admin.isAvailable()) {
        admin = Admin(ObjectBox.store);
      }
    }
  }

  static Store get store => _store;

  static Box get taskBox => _store.box<Task>();

  static Box get categoryBox => _store.box<CategoryModel>();

  static Box get completionBox => _store.box<TaskCompletion>();
  static void close() {
    _store.close();
  }

  static void _putInitialCategories() async {
    final box = categoryBox;
    if (box.isEmpty() && MiniBox.read('first_time') == null) {
      final Map<String, String> categories = {
        'General': 'folder',
        'Work': 'briefcase',
        'Study': 'book',
        'Personal': 'heart',
        'Fitness': 'dumbbell',
        'Shopping': 'cart',
      };
      categories.forEach((k, v) {
        box.put(CategoryModel(name: k, icon: v));
      });
      await MiniBox.write('first_time', false);
    }
  }
}
