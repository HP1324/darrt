import 'package:minimaltodo/data_models/category.dart';
import 'package:minimaltodo/services/database_service.dart';

class CategoryService {
  static Future<List<CategoryModel>> getCategories() async {
    final database = await DatabaseService.openDb();
    final List<Map<String,dynamic>> categoryMaps =  await database.query('categories');
    return List.generate(categoryMaps.length, (index){
      return CategoryModel.fromJson(categoryMaps[index]);
    });
  }

  static Future<int> addCategory( CategoryModel category) async {
    final database = await DatabaseService.openDb();
    final id = database.insert('categories', category.toJson());
    return id;
  }

  static Future<int> deleteCategory(int id) async {
    final database = await DatabaseService.openDb();
    
    // Begin transaction to ensure data consistency
    await database.transaction((txn) async {
      // First update all tasks in this category to set category to null
      await txn.update(
        'tasks',
        {
          'categoryId': null,
          'categoryName': null
        },
        where: 'categoryId = ?',
        whereArgs: [id]
      );
      
      // Then delete the category
      await txn.delete('categories', where: 'categoryId = ?', whereArgs: [id]);
    });
    
    return 1; // Return success
  }

  static CategoryModel? getCategoryById(int id){
    CategoryModel cm = CategoryModel();
    DatabaseService.openDb().then((db){
        db.query('categories',where: 'categoryId = ?', whereArgs: [id]).then((categories){
          if(categories.isNotEmpty){
            cm = CategoryModel.fromJson(categories.first);
          }
        } );
    });
   return cm;
  }

  static Future<int> editCategory(CategoryModel category) async {
    final database = await DatabaseService.openDb();
    int rowsAffected = await database.update(
      'categories',
      category.toJson(),
      where: 'categoryId = ?',
      whereArgs: [category.categoryId],
    );
    return rowsAffected;
  }
}
