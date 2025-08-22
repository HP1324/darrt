import 'package:darrt/app/state/viewmodels/view_model.dart';
import 'package:darrt/helpers/messages.dart';
import 'package:darrt/note/models/note.dart';

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

  void deleteNotesByFolder(List<Note> notesForFolder, int folderId) {
    box.removeMany(notesForFolder.map((n) => n.id).toList());
    items.removeWhere((n) => n.folders.any((f) => f.id == folderId));
    notifyListeners();
  }


  @override
  String getItemUuid(Note item) => item.uuid;


  /// [notify] decides whether to call [notifyListeners] or not, usually, we don't need to do this when this method is called from inside the class, this can be set to true when changes are made from outside the class
  void updateNoteFromAppWideStateChanges(Note note,{bool notify = false}) {
    final id = box.put(note);
    int index = notes.indexWhere((i) => getItemId(i) == id);
    if (index != -1) {
      notes[index] = note;
    }
    if(notify) notifyListeners();
  }
}
