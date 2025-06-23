import 'dart:convert';
import 'dart:io' as dart;
import 'package:archive/archive_io.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:minimaltodo/app/services/google_sign_in_service.dart';
import 'package:minimaltodo/category/models/category_model.dart';
import 'package:minimaltodo/helpers/globals.dart' as g;
import 'package:minimaltodo/helpers/mini_logger.dart';
import 'package:minimaltodo/helpers/object_box.dart';
import 'package:minimaltodo/task/models/task_completion.dart';
import 'package:path_provider/path_provider.dart';

import '../../note/models/folder.dart';
import '../../note/models/note.dart';
import '../../task/models/task.dart';

const String backupFileZipName = 'minitodo_backup.zip';
const String backupFileJsonName = 'minitodo_backup.json';

class BackupService {
  static final BackupService _instance = BackupService._internal();
  factory BackupService() => _instance;
  BackupService._internal();

  Future<dart.File> generateBackupFile() async {
    try {
      final tasks = ObjectBox.taskBox.getAll();
      final categories = ObjectBox.categoryBox.getAll();
      final notes = ObjectBox.noteBox.getAll();
      final folders = ObjectBox.folderBox.getAll();
      final completions = ObjectBox.completionBox.getAll();

      final newData = {
        'tasks': tasks.map((task) => task.toJson()).toList(),
        'categories': categories.map((category) => category.toJson()).toList(),
        'notes': notes.map((note) => note.toJson()).toList(),
        'folders': folders.map((folder) => folder.toJson()).toList(),
        'completions': completions.map((completion) => completion.toJson()).toList(),
      };

      Map<String, dynamic> mergedData = Map.from(newData);
      try {
        final oldJson = await downloadFileFromGoogleDrive();
        final oldData = await parseBackupJsonFileAsMap(oldJson);
        mergedData = {
          for (final key in newData.keys)
            key: _mergeUniqueById(
              oldData[key] as List<dynamic>? ?? [],
              newData[key] ?? [],
            ),
        };
      } catch (e, t) {
        MiniLogger.e('Error downloading old backup file ${e.toString()}, type: ${t.runtimeType}');
        MiniLogger.t('Stacktrace: ${t.toString()}');
      }
      final jsonString = jsonEncode(mergedData);
      final dir = await getApplicationDocumentsDirectory();
      final file = dart.File('${dir.path}/$backupFileJsonName');
      await file.writeAsString(jsonString);

      // final compressedFile = await _compressBackupFileAsZip(file);

      return file;
    } catch (e, t) {
      MiniLogger.e('Error generating backup file ${e.toString()}, type: ${t.runtimeType}');
      MiniLogger.t('Stacktrace: ${t.toString()}');
      rethrow;
    }
  }

  List<Map<String, dynamic>> _mergeUniqueById(List oldList, List newList) {
    final merged = [...oldList.cast<Map<String, dynamic>>()];
    final existingIds = merged.map((e) => e['id']).toSet();

    for (final item in newList) {
      final mapItem = item as Map<String, dynamic>;
      if (!existingIds.contains(mapItem['id'])) {
        merged.add(mapItem);
      }
    }

    return merged;
  }

  Future<dart.File> _compressBackupFileAsZip(dart.File jsonFile) async {
    final encoder = ZipFileEncoder();
    final zipPath = jsonFile.path.replaceAll('.json', '.zip');
    encoder.create(zipPath);
    encoder.addFile(jsonFile);
    encoder.close();
    return dart.File(zipPath);
  }

  Future<void> uploadFileToGoogleDrive(dart.File jsonFile) async {
    try {
      final client = await GoogleSignInService().getAuthenticatedClient();

      if (client == null) {
        throw Exception('Google client is not authenticated');
      }
      final driveApi = drive.DriveApi(client);

      // 1. Check if file already exists
      final existingFiles = await driveApi.files.list(
        q: "name='$backupFileZipName' and trashed=false",
      );
      if (existingFiles.files != null && existingFiles.files!.isNotEmpty) {
        await driveApi.files.delete(existingFiles.files!.first.id!);
      }

      // 2. Upload the new file
      final driveFile = drive.File()..name = backupFileJsonName;
      final media = drive.Media(
        jsonFile.openRead(),
        await jsonFile.length(),
        contentType: 'application/json',
      );
      MiniLogger.d('File size: ${driveFile.size}');
      final uploaded = await driveApi.files.create(driveFile, uploadMedia: media);

      if (uploaded.id != null) {
        MiniLogger.d('Backup file uploaded to Google Drive (fileId: ${uploaded.id})');
      } else {
        throw Exception('Failed to upload file');
      }

      client.close();
    } catch (e, t) {
      MiniLogger.e('Error uploading file to Google Drive ${e.toString()}, type: ${t.runtimeType}');
      MiniLogger.t('Stacktrace: ${t.toString()}');
      rethrow;
    }
  }

  Future<dart.File> downloadFileFromGoogleDrive() async {
    final client = await GoogleSignInService().getAuthenticatedClient();
    if (client == null) {
      throw Exception('Google client is not authenticated');
    }
    final driveApi = drive.DriveApi(client);

    // 1. Search for the file by name
    final searchResult = await driveApi.files.list(
      q: "name='$backupFileJsonName' and trashed=false",
      spaces: 'drive',
      $fields: 'files(id, name)',
    );

    if (searchResult.files == null || searchResult.files!.isEmpty) {
      throw Exception('No backup file "$backupFileJsonName" found in Google Drive.');
    }

    final fileId = searchResult.files!.first.id;
    final tempDir = await getTemporaryDirectory();
    final localPath = '${tempDir.path}/$backupFileJsonName';
    final outFile = dart.File(localPath);

    //2.Download file as media
    final mediaStream = await driveApi.files.get(fileId!, downloadOptions: drive.DownloadOptions.fullMedia)
            as drive.Media;

    final sink = outFile.openWrite();
    await mediaStream.stream.pipe(sink);
    await sink.close();

    client.close();
    return outFile;
  }

  Future<void> restoreDataFromBackupFile(dart.File backupFile) async {
    Map<String, dynamic> backupMap = await parseBackupJsonFileAsMap(backupFile);

    final tasks = (backupMap['tasks'] as List).map((e) => Task.fromJson(e)).toList();
    g.taskVm.putManyItems(tasks);

    final categories = (backupMap['categories'] as List)
        .map((e) => CategoryModel.fromJson(e))
        .toList();
    g.catVm.putManyItems(categories);

    final notes = (backupMap['notes'] as List).map((e) => Note.fromJson(e)).toList();
    g.noteVm.putManyItems(notes);

    final folders = (backupMap['folders'] as List).map((e) => Folder.fromJson(e)).toList();
    g.folderVm.putManyItems(folders);

    final completions = (backupMap['completions'] as List)
        .map((e) => TaskCompletion.fromJson(e))
        .toList();
    ObjectBox.completionBox.putMany(completions);

    MiniLogger.d('Data restored from google drive');
  }

  Future<Map<String, dynamic>> parseBackupJsonFileAsMap(dart.File jsonFile) async {
    try {
      final jsonString = await jsonFile.readAsString();
      final jsonMap = jsonDecode(jsonString);

      if (jsonMap is Map<String, dynamic>) {
        return jsonMap;
      } else {
        throw Exception('Invalid JSON structure: not a Map');
      }
    } catch (e) {
      throw Exception('Failed to parse backup JSON: $e');
    }
  }

  Future<Map<String, dynamic>> _decompressBackupZipFileAsMap(dart.File zipFile) async {
    // Read raw zip bytes
    final zipBytes = await zipFile.readAsBytes();

    // Decode zip archive
    final archive = ZipDecoder().decodeBytes(zipBytes);

    // Look for a JSON file inside
    for (final file in archive) {
      if (file.isFile && file.name.endsWith('.json')) {
        final jsonString = utf8.decode(file.content as List<int>);
        return jsonDecode(jsonString) as Map<String, dynamic>;
      }
    }

    // If no JSON found, throw error
    throw Exception('❌ No JSON file found inside ZIP.');
  }
}
