import 'package:minimaltodo/data_models/list_model.dart';
import 'package:minimaltodo/services/database_service.dart';

class ListService {
  static Future<List<ListModel>> getLists() async {
    final database = await DatabaseService.openDb();
    final List<Map<String,dynamic>> listMaps =  await database.query('lists');
    return List.generate(listMaps.length, (index){
      return ListModel.fromJson(listMaps[index]);
    });
  }

  static Future<int> addList( ListModel list) async {
    final database = await DatabaseService.openDb();
    final id = database.insert('lists', list.toJson());
    return id;
  }

  static Future<int> deleteList(int id) async {
    final database = await DatabaseService.openDb();
    
    // Begin transaction to ensure data consistency
    await database.transaction((txn) async {
      // First update all tasks in this list to set list to null
      await txn.update(
        'tasks',
        {
          'list_id': null,
          'list_name': null
        },
        where: 'list_id = ?',
        whereArgs: [id]
      );
      
      // Then delete the list
      await txn.delete('lists', where: 'id = ?', whereArgs: [id]);
    });
    
    return 1; // Return success
  }

  static ListModel? getListById(int id){
    ListModel lm = ListModel();
    DatabaseService.openDb().then((db){
        db.query('lists',where: 'id = ?', whereArgs: [id]).then((lists){
          if(lists.isNotEmpty){
            lm = ListModel.fromJson(lists.first);
          }
        } );
    });
   return lm;
  }

  static Future<int> editList(ListModel list) async {
    final database = await DatabaseService.openDb();
    int rowsAffected = await database.update(
      'lists',
      list.toJson(),
      where: 'id = ?',
      whereArgs: [list.id],
    );
    return rowsAffected;
  }
}
