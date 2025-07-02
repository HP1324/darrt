import 'package:minimaltodo/app/state/viewmodels/view_model.dart';
import 'package:minimaltodo/helpers/messages.dart';
import 'package:minimaltodo/helpers/typedefs.dart';
import 'package:minimaltodo/note/models/note.dart';
import 'package:minimaltodo/objectbox.g.dart';

class NoteViewModel extends ViewModel<Note> {
  NoteViewModel() {
    super.initializeItems();
  }

  List<Note> get notes => items;
  @override
  String putItem(Note item, {required bool edit}) {
    final note = item;
    note.updatedAt = DateTime.now();
    final message = super.putItem(note, edit: edit);
    return message;
  }

  @override
  int getItemId(Note item) => item.id;

  @override
  String getCreateSuccessMessage() => Messages.mNoteAdded;

  @override
  String getDeleteSuccessMessage(int length) =>
      length == 1 ? '1 ${Messages.mNoteDeleted}' : '$length ${Messages.mNotesDeleted}';

  @override
  String getUpdateSuccessMessage() => Messages.mNoteEdited;

  @override
  void setItemId(Note item, int id) {
    item.id = id;
  }

  @override
  void putManyForRestore(List<Note> restoredItems) {
    box.putMany(restoredItems);
    initializeItems();
    notifyListeners();
  }

  void deleteNotesByFolder(int folderId) {
    final toDelete = items.where((n) => n.folders.any((f) => f.id == folderId)).toList();
    box.removeMany(toDelete.map((n) => n.id).toList());
    items.removeWhere((n) => n.folders.any((f) => f.id == folderId));
    notifyListeners();
  }


  @override
  String getItemUuid(Note item) => item.uuid;

  @override
  List<Note> convertJsonListToObjectList(List<Map<String, dynamic>> jsonList) {
    return jsonList.map(Note.fromJson).toList();
  }

  @override
  List<Map<String, dynamic>> convertObjectsListToJsonList(List<Note> objectList) {
    return objectList.map((note) => note.toJson()).toList();
  }
}
