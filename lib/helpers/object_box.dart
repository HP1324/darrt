
import 'package:get_storage/get_storage.dart';
import 'package:minimaltodo/category/category_model.dart';
import 'package:minimaltodo/objectbox.g.dart';
import 'package:objectbox/objectbox.dart';

class ObjectBox {
  static late final Store _store;
  static bool _initialized = false;
  static Future<void> init() async {
    if(_initialized) return;
    _store = await openStore();
    _initialized = true;
    _putInitialCategories();
  }

  static Store get store => _store;

  static void close(){
    _store.close();
  }

  static void _putInitialCategories()async{
    final box = _store.box<CategoryModel>();
    if(box.isEmpty() && GetStorage().read('first_time') == null){
      final Map<String, String> categories = {
        'General': 'folder',
        'Work': 'briefcase',
        'Study': 'book',
        'Personal': 'heart',
        'Fitness': 'dumbbell',
        'Shopping': 'cart',
      };
      categories.forEach((k,v) {
        box.put(CategoryModel(name: k, icon: v));
      });
      await GetStorage().write('first_time', false);
    }
  }
}

