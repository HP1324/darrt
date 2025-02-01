import 'package:minimaltodo/helpers/mini_utils.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static const createCategoriesTable = """ CREATE TABLE categories(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL UNIQUE,
      icon_code TEXT DEFAULT 'folder',
      color TEXT
      )
     """;
  static const createTasksTable = """CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        isDone INTEGER DEFAULT 0,
        categoryId INTEGER DEFAULT 1,
        categoryName TEXT,
        catIconCode TEXT,
        categoryColor TEXT,
        createdAt TEXT,
        dueDate TEXT,
        finishedAt TEXT,
        isNotifyEnabled INTEGER DEFAULT 0,
        notifType TEXT DEFAULT 'notif',
        notifyTime TEXT,
        priority TEXT DEFAULT 'Low',
        isRepeating INTEGER DEFAULT 0,
        FOREIGN KEY(categoryId) REFERENCES categories (id) ON DELETE SET DEFAULT
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
  static const createDefaultCategories ="""INSERT INTO categories (name, icon_code) VALUES
  ('General','folder'),
('Sports', 'football'),
('Health', 'heart'),
('Work', 'briefcase'),
('Shopping', 'cart'),
('Groceries', 'shop'),
('Books', 'book'),
('Travel', 'airplane'),
('Education', 'graduation_cap'),
('Personal', 'home'),
('Finance', 'wallet'),
('Hobbies', 'gamepad'),
('Fitness', 'dumbbell'),
('Food', 'utensils'),
('Friends', 'people'),
('Family', 'home'),
('Chores', 'task'),
('Projects', 'chart'),
('Entertainment', 'video');
""";

  static Future<Database> openDb() async {
    return openDatabase(
      'minimal_todo.db',
      version: 1,
      onCreate: (database, version) async {
        await database.transaction((txn) async {
          await txn.execute(createCategoriesTable);
          await txn.execute(createTasksTable);
          await txn.execute(createStatsTable);
          await txn.execute(createDefaultCategories);
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
