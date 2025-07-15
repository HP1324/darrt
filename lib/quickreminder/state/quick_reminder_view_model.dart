import 'package:darrt/app/state/viewmodels/view_model.dart';
import 'package:darrt/quickreminder/model/quick_reminder.dart';

class QuickReminderViewModel extends ViewModel<QuickReminder> {


  @override
  String putItem(QuickReminder item, {required bool edit}) {
    if(items.length == 30) {
      final removed = items.removeAt(0);
      box.remove(removed.id);
  }
    final message = super.putItem(item, edit: edit);

    return message;
  }


  @override
  String getCreateSuccessMessage() => '';

  @override
  String getDeleteSuccessMessage(int length) => '';

  @override
  int getItemId(QuickReminder item) => item.id;

  @override
  String getItemUuid(QuickReminder item) => '';

  @override
  String getUpdateSuccessMessage() => '';

  @override
  void putManyForRestore(List<QuickReminder> restoredItems) {
    // TODO: implement putManyForRestore
  }

  @override
  void setItemId(QuickReminder item, int id) {
    // TODO: implement setItemId
  }

  @override
  List<QuickReminder> convertJsonListToObjectList(List<Map<String, dynamic>> jsonList) => [];

  @override
  List<Map<String, dynamic>> convertObjectsListToJsonList(List<QuickReminder> objectList) => [];
}
