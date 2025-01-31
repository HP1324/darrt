import 'package:get_storage/get_storage.dart';

class MiniBox{
  static final _box = GetStorage();

  static Future<void> write(String key, dynamic value)async{
    await _box.write(key, value);
  }

  static T? read<T>(String key){
    return _box.read(key);
  }

}