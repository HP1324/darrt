import 'package:minimaltodo/global_utils.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static const createListsTable = """ CREATE TABLE lists(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL UNIQUE,
      icon_code TEXT DEFAULT 'folder'
      )
     """;
  static const createTasksTable = """CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        isDone INTEGER DEFAULT 0,
        list_id INTEGER DEFAULT 1,
        list_name TEXT,
        createdAt TEXT,
        dueDate TEXT,
        finishedAt TEXT,
        isNotifyEnabled INTEGER DEFAULT 0,
        notifType TEXT DEFAULT 'notif',
        notifyTime TEXT,
        priority TEXT DEFAULT 'Low',
        isRepeating INTEGER DEFAULT 0,
        FOREIGN KEY(list_id) REFERENCES lists (id) ON DELETE SET DEFAULT
      )
    """;
  static const createStatsTable = """CREATE TABLE stats (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        total_tasks INTEGER NOT NULL,
        completed_tasks INTEGER NOT NULL,
        urgent_tasks INTEGER NOT NULL,
        high_tasks INTEGER NOT NULL,
        medium_tasks INTEGER NOT NULL,
        low_tasks INTEGER NOT NULL
      )
    """;
  static const createDefaultLists =
      """INSERT INTO lists (name, icon_code) VALUES
('Sports', 'running'),
('Health', 'heart'),
('Work', 'briefcase'),
('Shopping', 'cart'),
('Groceries', 'shop'),
('Books', 'book'),
('Travel', 'airplane'),
('Education', 'teacher'),
('Personal', 'home'),
('Finance', 'wallet'),
('Hobbies', 'game'),
('Fitness', 'weight'),
('Food', 'apple'),
('Friends', 'heart'),
('Family', 'home'),
('Chores', 'task'),
('Projects', 'chart'),
('Entertainment', 'video');
""";

  static Future<Database> openDb() async {
    logger.d('${formatDateTime(DateTime.now())} openDb() called');
    return openDatabase(
      'minimal_todo.db',
      version: 1,
      onCreate: (database, version) async {
        await database.transaction((txn) async {
          await txn.execute(createListsTable);
          await txn.execute(createTasksTable);
          await txn.execute(createStatsTable);
          await txn.execute(createDefaultLists);
        });
      },
      onConfigure: (database) async {
        await database.transaction((txn) async {
          await txn.execute('PRAGMA foreign_keys = ON');
        });
      },
    );
  }
}
