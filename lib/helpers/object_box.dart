import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:minimaltodo/category/models/category_model.dart';
import 'package:minimaltodo/helpers/mini_box.dart';
import 'package:minimaltodo/note/models/folder.dart';
import 'package:minimaltodo/note/models/note.dart';
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
    _putInitialData();
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

  static Box get folderBox => _store.box<Folder>();

  static Box get noteBox => _store.box<Note>();
  static void close() {
    _store.close();
  }

  static void _putInitialData() async {
    if (MiniBox.read('first_time') == null) {
      if (categoryBox.isEmpty()) {
        categoryBox.putMany(_getInitialCategories());
      }

      if (folderBox.isEmpty()) {
        folderBox.putMany(_getInitialFolders());
      }
      await MiniBox.write('first_time', false);
    }
  }

  static List<CategoryModel> _getInitialCategories() {
    final Map<String, String> categories = {
      'General': 'folder',
      'Work': 'briefcase',
      'Study': 'book',
      'Personal': 'heart',
      'Fitness': 'dumbbell',
      'Shopping': 'cart',
    };

    return categories.entries.map((e) => CategoryModel(name: e.key, icon: e.value)).toList();
  }

  static List<Folder> _getInitialFolders() {
    return [
      Folder(name: 'General'),
      Folder(name: 'Work'),
      Folder(name: 'Study'),
      Folder(name: 'Journal'),
    ];
  }
}
