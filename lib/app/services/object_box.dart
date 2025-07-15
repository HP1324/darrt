import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:darrt/app/services/boxpref.dart';
import 'package:darrt/category/models/task_category.dart';
import 'package:darrt/note/models/folder.dart';
import 'package:darrt/note/models/note.dart';
import 'package:darrt/objectbox.g.dart';
import 'package:darrt/task/models/task.dart';
import 'package:darrt/task/models/task_completion.dart';
import 'package:objectbox_flutter_libs/objectbox_flutter_libs.dart';
late final Admin admin;

class ObjectBox {
  static final ObjectBox _instance = ObjectBox._internal();
  factory ObjectBox() => _instance;
  ObjectBox._internal();

  Store? _store;

  Future<void> init() async {
    Store.debugLogs = true;
    final path = (await defaultStoreDirectory()).path;
    if(Store.isOpen(path)) {
      _store = Store.attach(getObjectBoxModel(), path);
    }else {
      _store = await openStore(directory: path);
    }
    _putInitialData();
    if (kDebugMode) {
      if (Admin.isAvailable()) {
        admin = Admin(ObjectBox().store!);
      }
    }
  }

  Future<void> initForAnotherIsolate(String dbPath) async {
    _store = Store.attach(getObjectBoxModel(), dbPath);
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
    return [
        TaskCategory(name: 'General', icon: 'folder',uuid: 'general'),
        TaskCategory(name: 'Work', icon: 'briefcase',uuid: 'work'),
        TaskCategory(name: 'Study', icon: 'book',uuid: 'study'),
        TaskCategory(name: 'Personal', icon: 'heart',uuid: 'personal'),
        TaskCategory(name: 'Fitness', icon: 'dumbbell',uuid: 'fitness'),
        TaskCategory(name: 'Shopping', icon: 'cart',uuid: 'shopping'),
    ];
  }

  List<Folder> _getInitialFolders() {
    return [
      Folder(name: 'General', uuid: 'general', icon: 'folder'),
      Folder(name: 'Work', uuid: 'work', icon: 'briefcase'),
      Folder(name: 'Study', uuid: 'study', icon: 'graduation_cap'),
      Folder(name: 'Journal', uuid: 'journal', icon: 'book'),
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
