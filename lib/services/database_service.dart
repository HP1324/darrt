import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:minimaltodo/helpers/database_queries.dart';
class DatabaseService {


  static Future<Database> openDb() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'mini_todo.db');
    return openDatabase(
      path,
      version: 1, // Increment version if you need to migrate schema
      onCreate: (database, version) async {
        await database.transaction((txn) async {
          await txn.execute(DatabaseQueries.createCategoriesTable);
          await txn.execute(DatabaseQueries.createTasksTable);
          await txn.execute(DatabaseQueries.createTaskCategoriesTable);
          await txn.execute(DatabaseQueries.createTaskCompletionTable);
          await txn.execute(DatabaseQueries.createDefaultCategories);
          await txn.execute(DatabaseQueries.createWishlistTable);
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
