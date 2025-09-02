import 'package:darrt/app/extensions/extensions.dart';
import 'package:darrt/app/state/viewmodels/view_model.dart';
import 'package:darrt/helpers/globals.dart' as g;
import 'package:darrt/helpers/messages.dart';
import 'package:darrt/helpers/mini_logger.dart';
import 'package:darrt/folder/models/folder.dart';

import '../../note/models/note.dart';

class FolderViewModel extends ViewModel<Folder> {
  List<Folder> get folders => items;

  @override
  String putItem(Folder item, {required bool edit}) {
    final folder = item;
    final folderName = folder.name.trim();
    if (folderName.isEmpty) {
      return Messages.mFolderEmpty;
    }
    folder.name = folderName;
    final message = super.putItem(folder, edit: edit);
    return message;
  }

  @override
  String getCreateSuccessMessage() => Messages.mFolderAdded;

  @override
  String getDeleteSuccessMessage(int length) => Messages.mFolderDeleted;

  @override
  String deleteItem(int id, {bool? deleteNotes}) {
    final notesForFolder = g.noteVm.notes.forFolderById(id);
    if (deleteNotes!) {
      g.noteVm.deleteNotesByFolder(notesForFolder, id);
      return super.deleteItem(id);
    }
    for(final note in notesForFolder){
      note.folders.removeWhere((folder) => folder.id == id);
      if(note.folders.isEmpty){
        note.folders.add(g.folderVm.folders.first);
      }
      g.noteVm.updateNoteFromAppWideStateChanges(note);
    }
    return super.deleteItem(id);
  }

  @override
  int getItemId(Folder item) => item.id;

  @override
  String getUpdateSuccessMessage() => Messages.mFolderEdited;

  @override
  void setItemId(Folder item, int id) {
    item.id = id;
  }

  @override
  void putManyForRestore(List<Folder> folders, {List<Note>? notes}) {
    box.putMany(folders);
    restoreFolderRelations(folders, notes: notes!);
    initializeItems();
    notifyListeners();
  }

  void restoreFolderRelations(
    List<Folder> restoredFolders, {
    required List<Note> notes,
  }) {
    // Build a UUID → Folder map for fast access
    final folderByUuid = {
      for (final folder in restoredFolders) folder.uuid: folder,
    };

    for (final note in notes) {
      note.folders.clear();

      final uuids = note.folderUuids; // Assuming you restored this from backup
      for (final uuid in uuids) {
        final folder = folderByUuid[uuid];
        if (folder != null) {
          note.folders.add(folder);
        } else {
          MiniLogger.dp(
            'Folder with UUID $uuid not found for note "${note.content}"',
          );
        }
      }
    }
  }

  @override
  String getItemUuid(Folder item) => item.uuid;
}
