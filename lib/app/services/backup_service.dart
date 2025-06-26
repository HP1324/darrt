import 'dart:convert';
import 'dart:io' as dart;
import 'package:archive/archive_io.dart';
import 'dart:developer' as dev;
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:minimaltodo/app/exceptions.dart';
import 'package:minimaltodo/app/services/content_comparator.dart';
import 'package:minimaltodo/app/services/google_sign_in_service.dart';
import 'package:minimaltodo/category/models/category_model.dart';
import 'package:minimaltodo/helpers/globals.dart' as g;
import 'package:minimaltodo/helpers/mini_logger.dart';
import 'package:minimaltodo/helpers/object_box.dart';
import 'package:minimaltodo/task/models/task_completion.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../../note/models/folder.dart';
import '../../note/models/note.dart';
import '../../task/models/task.dart';

const String backupFileJsonName = 'minitodo_backup.json';
const String backupFileZipName = 'minitodo_backup.zip';

class BackupService {
  static final BackupService _instance = BackupService._internal();
  factory BackupService() => _instance;
  BackupService._internal();

  Future<dart.File> generateBackupJsonFile() async {
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
        // Download the Old zip file which already exists in google drive
        final oldCompressedFile = await downloadCompressedFileFromGoogleDrive();

        // Decompress the old zip file to json file
        final oldDecompressedFile = _decompressToJsonFile(oldCompressedFile);

        // Parse the old json file as map
        final oldData = await parseBackupJsonFileAsMap(oldDecompressedFile);

        // Merge the old and new data
        BackupMergeService.mergeData(oldData, newData);
        // mergedData = _mergeData(oldData, newData);
      } catch (e, t) {
        MiniLogger.e('Error downloading old backup file ${e.toString()}, type: ${e.runtimeType}');
        MiniLogger.t(t.toString());
      }

      final jsonString = jsonEncode(mergedData);

      final dir = await getApplicationDocumentsDirectory();

      final file = dart.File(path.join(dir.path, backupFileJsonName));

      await file.writeAsString(jsonString);

      return file;
    } catch (e, t) {
      MiniLogger.e('Error generating backup file ${e.toString()}, type: ${t.runtimeType}');
      MiniLogger.t('Stacktrace: ${t.toString()}');
      rethrow;
    }
  }

  /// Takes json file as input, compresses it using [_compressJsonFile] and uploads it to google drive.
  Future<void> uploadFileToGoogleDrive(dart.File jsonFile) async {
    try {
      //Retrieve authenticated client to work with drive API
      final client = await GoogleSignInService().getAuthenticatedClient();

      if (client == null) {
        throw GoogleClientNotAuthenticatedError();
      }
      final driveApi = drive.DriveApi(client);

      //Check if file already exists
      final existingFiles = await driveApi.files.list(
        q: "name='$backupFileZipName' and trashed=false",
        spaces: 'appDataFolder'
      );

      if (existingFiles.files != null && existingFiles.files!.isNotEmpty) {
        await driveApi.files.delete(existingFiles.files!.first.id!);
      }

      // 2. Upload the new file
      final zipFile = _compressJsonFile(jsonFile);
      //Uploading to appDataFolder to make it hidden from the user's drive interface
      final driveFile = drive.File()
        ..name = backupFileZipName
        ..parents = ['appDataFolder'];

      final media = drive.Media(
        zipFile.openRead(),
        await zipFile.length(),
        contentType: 'application/zip',
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
    }
  }

  ///Downloads the compressed backup file(not json) from google drive,stores it in the platform's temporary directory and returns it as a dart [File] object. The temporary directory is retrieved using [getTemporaryDirectory] method from the path_provider package.
  Future<dart.File> downloadCompressedFileFromGoogleDrive() async {
    final client = await GoogleSignInService().getAuthenticatedClient();

    if (client == null) {
      throw GoogleClientNotAuthenticatedError();
    }
    final driveApi = drive.DriveApi(client);

    // 1. Search for the file by name
    final searchResult = await driveApi.files.list(
      q: "name='$backupFileZipName' and trashed=false",
      spaces: 'appDataFolder',
      $fields: 'files(id, name)',
    );

    if (searchResult.files == null || searchResult.files!.isEmpty) {
      throw BackupFileNotFoundError();
    }

    final fileId = searchResult.files!.first.id;

    final tempDir = await getTemporaryDirectory();

    // Here we are just creating a reference to an empty file object with the
    // same name as the backup file, we will write data to the file using stream
    final localPath = '${tempDir.path}/$backupFileZipName';

    final outFile = dart.File(localPath);

    //2.Download file as media
    final media =
        await driveApi.files.get(fileId!, downloadOptions: drive.DownloadOptions.fullMedia)
            as drive.Media;

    final sink = outFile.openWrite();
    await media.stream.pipe(sink);
    await sink.close();

    client.close();
    return outFile;
  }

  Future<void> restoreDataFromBackupFile(dart.File backupFile) async {
    //Decompress zip file back to JSON file
    final jsonBackupFile = _decompressToJsonFile(backupFile);

    //Parse the json file as map to work on it
    Map<String, dynamic> backupMap = await parseBackupJsonFileAsMap(jsonBackupFile);

    final categories = (backupMap['categories'] as List)
        .map((e) => CategoryModel.fromJson(e))
        .toList();
    g.catVm.putManyItems(categories);

    final tasks = (backupMap['tasks'] as List).map((e) => Task.fromJson(e)).toList();
    g.taskVm.putManyItems(tasks);

    final folders = (backupMap['folders'] as List).map((e) => Folder.fromJson(e)).toList();
    g.folderVm.putManyItems(folders);

    final notes = (backupMap['notes'] as List).map((e) => Note.fromJson(e)).toList();
    g.noteVm.putManyItems(notes);

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
        dev.log('JSON Map: $jsonMap');
        return jsonMap;
      } else {
        throw FormatException('Invalid JSON structure: not a Map');
      }
    } catch (e) {
      throw Exception('Failed to parse backup JSON: $e');
    }
  }

  dart.File _compressJsonFile(dart.File jsonFile) {
    final jsonBytes = jsonFile.readAsBytesSync();
    final archive = Archive();

    final file = ArchiveFile(
      backupFileJsonName, // filename
      jsonBytes.length,
      jsonBytes,
    );

    archive.addFile(file);
    final zipBytes = ZipEncoder().encode(archive);

    final compressedFile = dart.File(
      jsonFile.path.replaceAll(backupFileJsonName, backupFileZipName),
    );
    compressedFile.writeAsBytesSync(zipBytes);

    return compressedFile;
  }

  // Decompress zip file back to JSON file
  dart.File _decompressToJsonFile(dart.File zipFile) {
    final zipBytes = zipFile.readAsBytesSync();
    final archive = ZipDecoder().decodeBytes(zipBytes);

    final jsonBytes = archive.first.content as List<int>;
    final originalFileName = archive.first.name;

    MiniLogger.d('original name: $originalFileName');

    final filePath = path.join(zipFile.parent.path, originalFileName);
    final jsonFile = dart.File(filePath);
    jsonFile.writeAsBytesSync(jsonBytes);

    return jsonFile;
  }

  Future<void> deleteBackupFromGoogleDrive() async {
    final client = await GoogleSignInService().getAuthenticatedClient();

    if (client == null) {
      throw GoogleClientNotAuthenticatedError();
    }

    final driveApi = drive.DriveApi(client);

    final searchResult = await driveApi.files.list(
      q: "name='$backupFileZipName' and trashed=false",
      spaces: 'appDataFolder',
      $fields: 'files(id,name)',
    );

    if (searchResult.files != null && searchResult.files!.isNotEmpty) {
      await driveApi.files.delete(searchResult.files!.first.id!);
    } else {
      throw BackupFileNotFoundError('No backup to delete');
    }
  }
}

class BackupMergeService {
  static Map<String, dynamic> mergeData(
    Map<String, dynamic> oldData,
    Map<String, dynamic> newData,
  ) {
    final merged = Map<String, dynamic>.from(oldData);

    newData.forEach((key, newList) {
      if (merged.containsKey(key)) {
        final oldList = List<Map<String, dynamic>>.from(merged[key]);
        final newItems = List<Map<String, dynamic>>.from(newList);

        // Add items from newData that don't exist in oldData (content-wise)
        for (var newItem in newItems) {
          if (!_itemExistsInList(key, newItem, oldList)) {
            oldList.add(newItem);
          }
        }

        merged[key] = oldList;
      } else {
        // Key doesn't exist in old data, add entire list
        merged[key] = List<Map<String, dynamic>>.from(newList);
      }
    });

    return merged;
  }

  static bool _itemExistsInList(
    String entityType,
    Map<String, dynamic> newItem,
    List<Map<String, dynamic>> existingList,
  ) {
    try {
      return existingList.any(
        (existingItem) => EntityTypeResolver.areItemsEqual(entityType, newItem, existingItem),
      );
    } catch (e) {
      // Fallback to ID comparison if entity type is unknown
      final newId = newItem['id']?.toString();
      if (newId == null) return false;

      return existingList.any((existingItem) => existingItem['id']?.toString() == newId);
    }
  }
}
