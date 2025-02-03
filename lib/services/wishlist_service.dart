import 'package:minimaltodo/data_models/wishlist.dart';
import 'package:minimaltodo/services/database_service.dart';

class WishListService {
  static Future<List<WishList>> getWishLists() async {
    final database = await DatabaseService.openDb();
    final List<Map<String, dynamic>> maps = await database.query(
      'wishlists',
      orderBy: 'createdAt DESC',
    );
    return List.generate(maps.length, (i) => WishList.fromJson(maps[i]));
  }

  static Future<int> addWishList(WishList wishList) async {
    final database = await DatabaseService.openDb();
    return await database.insert('wishlists', wishList.toJson());
  }

  static Future<int> updateWishList(WishList wishList) async {
    final database = await DatabaseService.openDb();
    return await database.update(
      'wishlists',
      wishList.toJson(),
      where: 'id = ?',
      whereArgs: [wishList.id],
    );
  }

  static Future<int> deleteWishList(int id) async {
    final database = await DatabaseService.openDb();
    return await database.delete(
      'wishlists',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int> toggleFulfilled(int id, bool isFulfilled) async {
    final database = await DatabaseService.openDb();
    return await database.update(
      'wishlists',
      {'isFulfilled': isFulfilled ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
