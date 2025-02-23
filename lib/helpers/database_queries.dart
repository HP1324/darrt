class DatabaseQueries {
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
        createdAt INTEGER,
        dueDate INTEGER,
        finishedAt INTEGER,
        isNotifyEnabled INTEGER DEFAULT 0,
        notifType TEXT DEFAULT 'notif',
        notifyTime INTEGER,
        priority TEXT DEFAULT 'Low',
        isRepeating INTEGER DEFAULT 0,
        startDate INTEGER NOT NULL,
        endDate INTEGER,
        repeatConfig TEXT,
        reminderTimes TEXT
      )
  """;
  static const createTaskCompletionTable = '''
  CREATE TABLE task_completion(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      task_id INTEGER NOT NULL,
      date INTEGER NOT NULL,
      isCompleted INTEGER NOT NULL,
      FOREIGN KEY(task_id) references tasks(id) ON DELETE CASCADE
  )
  ''';
  static const createTaskCategoriesTable = '''
  CREATE TABLE task_categories(
  task_id INTEGER,
  category_id INTEGER,
  FOREIGN KEY(task_id) references tasks(id) ON DELETE CASCADE,
  FOREIGN KEY(category_id) references categories(id) ON DELETE CASCADE  ,
  PRIMARY KEY(task_id, category_id)  -- Composite primary key
  )
  ''';
  static const createWishlistTable = '''CREATE TABLE wishlists (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  isFulfilled INTEGER DEFAULT 0,
  createdAt TEXT DEFAULT CURRENT_TIMESTAMP
  )
  ''';
  static const createDefaultCategories = """INSERT INTO categories (name, icon_code) VALUES
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
}
