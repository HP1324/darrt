import 'package:minimaltodo/app/state/viewmodels/view_model.dart';
import 'package:minimaltodo/helpers/messages.dart';
import 'package:minimaltodo/note/models/note.dart';

class NoteViewModel extends ViewModel<Note>{

  List<Note> get notes => items;

  @override
  int getItemId(Note item) => item.id;

  @override
  String getCreateSuccessMessage() => Messages.mNoteAdded;

  @override
  String getDeleteSuccessMessage(int length)=> length == 1 ? '1 ${Messages.mNoteDeleted}' : '$length ${Messages.mNotesDeleted}';

  @override
  String getUpdateSuccessMessage() => Messages.mNoteEdited;

}