import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static const createCategoriesTable = """
    CREATE TABLE categories(
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
        startDate TEXT NOT NULL,
        endDate TEXT,
        repeatConfig TEXT,
        reminderTimes TEXT,
        FOREIGN KEY(categoryId) REFERENCES categories (id) ON DELETE SET DEFAULT
      )
  """;
  static const createTaskCompletionTable = '''
  CREATE TABLE task_completion(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      task_id INTEGER NOT NULL,
      date TEXT NOT NULL,
      isCompleted INTEGER NOT NULL,
      FOREIGN KEY(task_id) references tasks(id) ON DELETE CASCADE
  )
  ''';
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
  static const createWishlistTable =  '''CREATE TABLE wishlists (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  isFulfilled INTEGER DEFAULT 0,
  createdAt TEXT DEFAULT CURRENT_TIMESTAMP
  )
  ''';

  static const createDefaultCategories =
      """INSERT INTO categories (name, icon_code) VALUES
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
    ('Family', 'home'),
    ('Projects', 'chart')
  """;

  static Future<Database> openDb() async {
    return openDatabase(
      'minimal_todo.db',
      version: 1, // Increment version if you need to migrate schema
      onCreate: (database, version) async {
        await database.transaction((txn) async {
          await txn.execute(createCategoriesTable);
          await txn.execute(createTasksTable);
          await txn.execute(createTaskCompletionTable);
          await txn.execute(createStatsTable);
          await txn.execute(createDefaultCategories);
          await txn.execute(createWishlistTable);
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
