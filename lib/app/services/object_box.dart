import 'package:darrt/habits/build/models/build_habit.dart';
import 'package:darrt/habits/build/models/habit_completion.dart';
import 'package:darrt/habits/quit/models/quit_habit.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:darrt/app/services/boxpref.dart';
import 'package:darrt/category/models/entity_category.dart';
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

  Box<EntityCategory> get categoryBox => _store!.box<EntityCategory>();

  Box<TaskCompletion> get completionBox => _store!.box<TaskCompletion>();

  Box<Folder> get folderBox => _store!.box<Folder>();

  Box<Note> get noteBox => _store!.box<Note>();

  Box<BoxPref> get prefsBox => _store!.box<BoxPref>();

  Box<BuildHabit> get buildHabitBox => _store!.box<BuildHabit>();

  Box<QuitHabit> get quitHabitBox => _store!.box<QuitHabit>();

  Box<HabitCompletion> get habitCompletionBox => _store!.box<HabitCompletion>();
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

  List<EntityCategory> _getInitialCategories() {
    return [
        EntityCategory(name: 'General', icon: 'folder',uuid: 'general'),
        EntityCategory(name: 'Work', icon: 'briefcase',uuid: 'work'),
        EntityCategory(name: 'Study', icon: 'book',uuid: 'study'),
        EntityCategory(name: 'Personal', icon: 'heart',uuid: 'personal'),
        EntityCategory(name: 'Fitness', icon: 'dumbbell',uuid: 'fitness'),
        EntityCategory(name: 'Shopping', icon: 'cart',uuid: 'shopping'),
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
    late final List<EntityCategory> categories;
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
