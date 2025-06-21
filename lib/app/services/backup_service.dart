import 'dart:convert';
import 'dart:io' as dart;
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:minimaltodo/helpers/mini_logger.dart';
import 'package:minimaltodo/helpers/object_box.dart';
import 'package:path_provider/path_provider.dart';

class BackupService{
  static final BackupService _instance = BackupService._internal();
  factory BackupService() => _instance;
  BackupService._internal();

  Future<dart.File> generateBackupJsonFile()async{
    try {
      final tasks = ObjectBox.taskBox.getAll();
      final categories = ObjectBox.categoryBox.getAll();
      final notes = ObjectBox.noteBox.getAll();
      final folders = ObjectBox.folderBox.getAll();
      final completions = ObjectBox.completionBox.getAll();

      final data = {
        'tasks': tasks.map((task) => task.toJson()).toList(),
        'categories': categories.map((category) => category.toJson()).toList(),
        'notes': notes.map((note) => note.toJson()).toList(),
        'folders': folders.map((folder) => folder.toJson()).toList(),
        'completions': completions.map((completion) => completion.toJson()).toList(),
      };

      final jsonString = jsonEncode(data);
      final dir = await getApplicationDocumentsDirectory();
      final file = dart.File('${dir.path}/minitodo_backup.json');
      await file.writeAsString(jsonString);

      return file;
    }catch(e,t){
      MiniLogger.e('Error generating backup file ${e.toString()}, type: ${t.runtimeType}');
      MiniLogger.t('Stacktrace: ${t.toString()}');
      rethrow;
    }
  }


}