import 'dart:convert';
import 'dart:io' as dart;
import 'package:archive/archive_io.dart';
import 'dart:developer' as dev;
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:darrt/app/exceptions.dart';
import 'package:darrt/app/services/google_sign_in_service.dart';
import 'package:darrt/category/models/task_category.dart';
import 'package:darrt/helpers/globals.dart' as g;
import 'package:darrt/helpers/mini_logger.dart';
import 'package:darrt/app/services/object_box.dart';
import 'package:darrt/task/models/task_completion.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:darrt/note/models/folder.dart';
import 'package:darrt/note/models/note.dart';
import 'package:darrt/task/models/task.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as auth show AuthClient;

const String backupFileJsonName = 'darrt_backup.json';
const String backupFileZipName = 'darrt_backup.zip';

class BackupService {
  static final BackupService _instance = BackupService._internal();
  factory BackupService() => _instance;
  BackupService._internal();

  /// Google account's authenticated client
  auth.AuthClient? _authClient;

  Future<void> init() async {
    if (!await InternetConnection().hasInternetAccess) throw InternetOffError();

    _authClient = await GoogleSignInService().getAuthenticatedClient();

    if (_authClient == null) throw GoogleClientNotAuthenticatedError();
    // return true;
  }

  Future<void> initForAnotherIsolate()async{
    if (!await InternetConnection().hasInternetAccess) throw InternetOffError();

;
  }
  Future<void> performBackup({bool? isAutoBackup}) async {
    //1. Init the service
    // if(isAutoBackup != null && isAutoBackup) {
      await init();
    // }

    //2. Generate backup json file
    final backupJsonFile = await _generateBackupFile();

    //3. Upload backup file to google drive after compressing to zip
    await uploadFileToGoogleDrive(backupJsonFile);

    //4. Close [_authClient]
    _authClient?.close();
  }

  Future<dart.File> _generateBackupFile() async {
    //Get local data
    final localData = ObjectBox().getLocalData();

    Map<String, dynamic> mergedData = Map.from(localData);

    // Download old backup file in compressed zip format
    final oldCompressedFile = await downloadCompressedFileFromGoogleDrive();

    if (oldCompressedFile != null) {
      //If there exists an old backup file, then 1. Decompress it to json file
      final oldDecompressedFile = _decompressToJsonFile(oldCompressedFile);

      // 2. Parse the old json file as [Map<String, dynamic>]
      final oldData = await _parseBackupJsonFileAsMap(oldDecompressedFile);

      // 3. Merge the old and new data
      mergedData = BackupMergeService.mergeData(
        oldData,
        localData,
        mergeType: MergeType.backup,
      );

      dev.log('Merged json data: $mergedData');
    }

    // Convert the merged data to json string
    final backupJsonString = jsonEncode(mergedData);

    // Create a file reference on device
    final dir = await getApplicationDocumentsDirectory();
    final file = dart.File(path.join(dir.path, backupFileJsonName));

    // Write the json string to the file
    await file.writeAsString(backupJsonString);

    return file;
  }

  /// Takes json file as input, compresses it using [_compressJsonFile] and uploads it to google drive.
  Future<void> uploadFileToGoogleDrive(dart.File jsonFile) async {
    final driveApi = drive.DriveApi(_authClient!);

    // Check if file already exists
    final existingFiles = await driveApi.files.list(
      q: "name='$backupFileZipName' and trashed=false",
      spaces: 'appDataFolder',
    );

    if (existingFiles.files != null && existingFiles.files!.isNotEmpty) {
      await driveApi.files.delete(existingFiles.files!.first.id!);
    }

    // Compress JSON file
    final zipFile = _compressJsonFile(jsonFile);

    final driveFile = drive.File()
      ..name = backupFileZipName
      ..parents = ['appDataFolder'];

    final media = drive.Media(
      zipFile.openRead(),
      await zipFile.length(),
      contentType: 'application/zip',
    );

    final drive.File uploadedFile = await driveApi.files.create(driveFile, uploadMedia: media);

    MiniLogger.d(
      'File uploaded to Google Drive: {id: ${uploadedFile.id}, name: ${uploadedFile.name}}',
    );

  }

  ///Downloads the compressed backup file(not json) from google drive,stores it in the platform's temporary directory and returns it as a dart [File] object. The temporary directory is retrieved using [getTemporaryDirectory] method from the path_provider package.
  Future<dart.File?> downloadCompressedFileFromGoogleDrive() async {
    final driveApi = drive.DriveApi(_authClient!);
    // 1. Search for the file by name
    final searchResult = await driveApi.files.list(
      q: "name='$backupFileZipName' and trashed=false",
      spaces: 'appDataFolder',
      $fields: 'files(id, name)',
    );
    //If there is no existing backup file in google drive, return null
    if (searchResult.files == null || searchResult.files!.isEmpty) {
      return null;
    }

    final fileId = searchResult.files!.first.id;

    final tempDir = await getTemporaryDirectory();

    // Here we are just creating a reference to an empty file object with the
    // same name as the backup file, we will write data to the file using stream
    final localPath = path.join(tempDir.path, backupFileZipName);

    final outFile = dart.File(localPath);

    //2.Download file as media
    final media =
        await driveApi.files.get(fileId!, downloadOptions: drive.DownloadOptions.fullMedia)
            as drive.Media;

    final sink = outFile.openWrite();
    await media.stream.pipe(sink);
    await sink.close();
    return outFile;
  }

  Future<void> performRestore()async{
    //1. Init the service
    await init();

    //2. Download compressed zip backup file from google drive
    final backupZipFile = await downloadCompressedFileFromGoogleDrive();

    if(backupZipFile==null) throw BackupFileNotFoundError();

    //3. Decompress zip file to json file
    final backupJsonFile = _decompressToJsonFile(backupZipFile);

    //4. Parse json file as [Map<String,dynamic>]
    final driveData = await _parseBackupJsonFileAsMap(backupJsonFile);

    //5. Retrieve local data
    final localData = ObjectBox().getLocalData();

    //6. Merge local and drive data using uuid merging strategy
    final mergedData = BackupMergeService.mergeData(localData, driveData,mergeType: MergeType.restore);

    //7. Put merged data to local database
    _putMergedDataToLocalDatabase(mergedData);

    // await compute(_putMergedDataToLocalDatabase, mergedData);
    //8. Close [_authClient]
    _authClient?.close();
  }
  void _putMergedDataToLocalDatabase(Map<String, dynamic> mergedData) {
   final tasks = (mergedData['tasks'] as List).map((e) => Task.fromJson(e)).toList();

    final categories = (mergedData['categories'] as List)
        .map((e) => TaskCategory.fromJson(e))
        .toList();
    g.catVm.putManyForRestore(categories, tasks: tasks);

    final completions = (mergedData['completions'] as List)
        .map((e) => TaskCompletion.fromJson(e))
        .toList();

    g.taskVm.putManyForRestore(tasks, completions: completions);

    final notes = (mergedData['notes'] as List).map((e) => Note.fromJson(e)).toList();
    final folders = (mergedData['folders'] as List).map((e) => Folder.fromJson(e)).toList();
    g.folderVm.putManyForRestore(folders, notes: notes);

    g.noteVm.putManyForRestore(notes);
  }

  Future<Map<String, dynamic>> _parseBackupJsonFileAsMap(dart.File jsonFile) async {
    try {
      final jsonString = await jsonFile.readAsString();
      final jsonMap = jsonDecode(jsonString);

      if (jsonMap is Map<String, dynamic>) {
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
    await init();


    final driveApi = drive.DriveApi(_authClient!);

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
  static Map<String, List<dynamic>> oldCacheObjects = {};

  static Map<String, dynamic> mergeData(
    Map<String, dynamic> oldData,
    Map<String, dynamic> newData, {
    required MergeType mergeType,
  }) {
    // Convert JSON data to objects once
    final oldObjects = convertJsonDataToObjects(oldData);
    final newObjects = convertJsonDataToObjects(newData);

    final mergedData = <String, List<dynamic>>{};

    // Get all unique keys from both datasets
    final allKeys = {...oldObjects.keys, ...newObjects.keys};

    for (var key in allKeys) {
      final oldList = oldObjects[key] ?? [];
      final newList = newObjects[key] ?? [];

      List mergedList = List.from(oldList);

      switch (key) {
        case 'categories':
          mergedList = g.catVm.mergeItemLists(
            oldList.cast<TaskCategory>(),
            newList.cast<TaskCategory>(),
            mergeType: mergeType,
          );
          mergedData[key] = g.catVm.convertObjectsListToJsonList(mergedList.cast<TaskCategory>());
          break;

        case 'folders':
          mergedList = g.folderVm.mergeItemLists(
            oldList.cast<Folder>(),
            newList.cast<Folder>(),
            mergeType: mergeType,
          );
          mergedData[key] = g.folderVm.convertObjectsListToJsonList(mergedList.cast<Folder>());
          break;

        case 'tasks':
          mergedList = g.taskVm.mergeItemLists(
            oldList.cast<Task>(),
            newList.cast<Task>(),
            mergeType: mergeType,
          );
          mergedData[key] = g.taskVm.convertObjectsListToJsonList(mergedList.cast<Task>());
          break;

        case 'notes':
          mergedList = g.noteVm.mergeItemLists(
            oldList.cast<Note>(),
            newList.cast<Note>(),
            mergeType: mergeType,
          );
          mergedData[key] = g.noteVm.convertObjectsListToJsonList(mergedList.cast<Note>());
          break;

        case 'completions':
          mergedList = g.completionVm.mergeItemLists(
            oldList.cast<TaskCompletion>(),
            newList.cast<TaskCompletion>(),
            mergeType: mergeType,
          );
          mergedData[key] = g.completionVm.convertObjectsListToJsonList(
            mergedList.cast<TaskCompletion>(),
          );
          break;

        default:
          // For unknown keys, just use the new list
          mergedList = newList;
          mergedData[key] = mergedList;
      }
    }

    return mergedData;
  }

  static Map<String, dynamic> convertJsonDataToObjects(Map<String, dynamic> jsonData) {
    final convertedData = <String, List<dynamic>>{};

    for (var key in jsonData.keys) {
      final jsonList = jsonData[key] as List<dynamic>? ?? [];
      List<dynamic> objectList = [];

      switch (key) {
        case 'tasks':
          objectList = jsonList.map((json) => Task.fromJson(json)).toList();
          break;
        case 'categories':
          objectList = jsonList.map((json) => TaskCategory.fromJson(json)).toList();
          break;
        case 'completions':
          objectList = jsonList.map((json) => TaskCompletion.fromJson(json)).toList();
          break;
        case 'notes':
          objectList = jsonList.map((json) => Note.fromJson(json)).toList();
          break;
        case 'folders':
          objectList = jsonList.map((json) => Folder.fromJson(json)).toList();
          break;
        default:
          objectList = jsonList; // Keep as is for unknown keys
      }

      convertedData[key] = objectList;
    }

    return convertedData;
  }

  static Map<String, dynamic> convertObjectsToJsonData(Map<String, dynamic> objectData) {
    final Map<String, dynamic> convertedData = {};

    for (var key in objectData.keys) {
      final objectList = objectData[key] ?? [];
      List<dynamic> jsonList = [];

      switch (key) {
        case 'tasks':
          jsonList = objectList.map((obj) => (obj as Task).toJson()).toList();
          break;
        case 'categories':
          jsonList = objectList.map((obj) => (obj as TaskCategory).toJson()).toList();
          break;
        case 'completions':
          jsonList = objectList.map((obj) => (obj as TaskCompletion).toJson()).toList();
          break;
        case 'notes':
          jsonList = objectList.map((obj) => (obj as Note).toJson()).toList();
          break;
        case 'folders':
          jsonList = objectList.map((obj) => (obj as Folder).toJson()).toList();
          break;
        default:
          jsonList = objectList; // Keep as is for unknown keys
      }

      convertedData[key] = jsonList;
    }

    return convertedData;
  }
}

enum MergeType {
  backup,
  restore,
}
