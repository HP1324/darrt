import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static const createCategoriesTable = """ CREATE TABLE categories(
      categoryId INTEGER PRIMARY KEY AUTOINCREMENT,
      categoryName TEXT NOT NULL UNIQUE
      )
     """;
  static const createTasksTable = """CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        isDone INTEGER DEFAULT 0,
        categoryId INTEGER DEFAULT 1,
        categoryName TEXT,
        createdAt TEXT,
        dueDate TEXT,
        finishedAt TEXT,
        isNotifyEnabled INTEGER DEFAULT 0,
        notifType TEXT DEFAULT 'notif',
        notifyTime TEXT,
        priority TEXT DEFAULT 'Low',
        isRepeating INTEGER DEFAULT 0,
        FOREIGN KEY(categoryId) REFERENCES categories (categoryId) ON DELETE SET DEFAULT
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


  static Future<Database> openDb() async {
    return openDatabase(
      'simple_todo.db',
      version: 4,
      onCreate: (database, version) async {
        await database.transaction((txn)async{
          await txn.execute(createCategoriesTable);
          await txn.execute(createTasksTable);
          await txn.execute(createStatsTable);
        });
      },
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
      },
    );
  }
}



