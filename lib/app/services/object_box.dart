import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:minimaltodo/app/services/boxpref.dart';
import 'package:minimaltodo/category/models/task_category.dart';
import 'package:minimaltodo/helpers/consts.dart';
import 'package:minimaltodo/app/services/mini_box.dart';
import 'package:minimaltodo/note/models/folder.dart';
import 'package:minimaltodo/note/models/note.dart';
import 'package:minimaltodo/objectbox.g.dart';
import 'package:minimaltodo/task/models/task.dart';
import 'package:minimaltodo/task/models/task_completion.dart';

late final Admin admin;

class ObjectBox {
  static final ObjectBox _instance = ObjectBox._internal();
  factory ObjectBox() => _instance;
  ObjectBox._internal();

  Store? _store;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _store = await openStore();
    _initialized = true;
    _putInitialData();
    if (kDebugMode) {
      if (Admin.isAvailable()) {
        admin = Admin(ObjectBox().store!);
      }
    }
  }

  void initForAnotherIsolate(String dbPath) async {
    _store = Store.attach(getObjectBoxModel(), dbPath);
    _initialized = true;
    _putInitialData();
  }

  Store? get store => _store;

  Box<Task> get taskBox => _store!.box<Task>();

  Box<TaskCategory> get categoryBox => _store!.box<TaskCategory>();

  Box<TaskCompletion> get completionBox => _store!.box<TaskCompletion>();

  Box<Folder> get folderBox => _store!.box<Folder>();

  Box<Note> get noteBox => _store!.box<Note>();

  Box<BoxPref> get prefsBox => _store!.box<BoxPref>();

  void close() {
    _store!.close();
  }

  void _putInitialData() async {
    if (categoryBox.isEmpty()) {
      categoryBox.putMany(_getInitialCategories());
    }

    if (folderBox.isEmpty()) {
      folderBox.putMany(_getInitialFolders());
    }
  }

  List<TaskCategory> _getInitialCategories() {
    final Map<String, String> categories = {
      'General': 'folder',
      'Work': 'briefcase',
      'Study': 'book',
      'Personal': 'heart',
      'Fitness': 'dumbbell',
      'Shopping': 'cart',
    };

    return categories.entries.map((e) => TaskCategory(name: e.key, icon: e.value)).toList();
  }

  List<Folder> _getInitialFolders() {
    return [
      Folder(name: 'General'),
      Folder(name: 'Work'),
      Folder(name: 'Study'),
      Folder(name: 'Journal'),
    ];
  }

  Map<String, dynamic> getLocalData() {
    late final List<Task> tasks;
    late final List<TaskCategory> categories;
    late final List<Note> notes;
    late final List<Folder> folders;
    late final List<TaskCompletion> completions;

    store!.runInTransaction(TxMode.read, () {
      tasks = taskBox.getAll();
      categories = categoryBox.getAll();
      notes = noteBox.getAll();
      folders = folderBox.getAll();
      completions = completionBox.getAll();
    });

    return {
      'tasks': tasks.map((task) => task.toJson()).toList(),
      'categories': categories.map((category) => category.toJson()).toList(),
      'notes': notes.map((note) => note.toJson()).toList(),
      'folders': folders.map((folder) => folder.toJson()).toList(),
      'completions': completions.map((completion) => completion.toJson()).toList(),
    };
  }
}
