import 'package:minimaltodo/app/state/viewmodels/view_model.dart';
import 'package:minimaltodo/helpers/messages.dart';
import 'package:minimaltodo/note/models/folder.dart';

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
  int getItemId(Folder item) => item.id;

  @override
  String getUpdateSuccessMessage() => Messages.mFolderEdited;

  @override
  void setItemId(Folder item, int id) {
    item.id = id;
  }
}
