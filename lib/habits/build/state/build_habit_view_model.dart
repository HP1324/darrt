import 'package:darrt/app/state/viewmodels/view_model.dart';
import 'package:darrt/habits/build/models/build_habit.dart';
import 'package:darrt/helpers/messages.dart';

class BuildHabitViewModel extends ViewModel<BuildHabit>{
  @override
  List<BuildHabit> convertJsonListToObjectList(List<Map<String, dynamic>> jsonList) {
    return jsonList.map(BuildHabit.fromJson).toList();
  }

  @override
  List<Map<String, dynamic>> convertObjectsListToJsonList(List<BuildHabit> objectList) {
    // TODO: implement convertObjectsListToJsonList
    throw UnimplementedError();
  }

  @override
  String getCreateSuccessMessage()=> Messages.mHabitCreated;

  @override
  String getDeleteSuccessMessage(int length) {
    return length == 1 ? Messages.mHabitDeleted : Messages.mHabitsDeleted;
  }

  @override
  int getItemId(BuildHabit item) => item.id;

  @override
  String getItemUuid(BuildHabit item) => item.uuid;

  @override
  String getUpdateSuccessMessage() => Messages.mHabitEdited;

  @override
  void putManyForRestore(List<BuildHabit> restoredItems) {
    // TODO: implement putManyForRestore
  }

  @override
  void setItemId(BuildHabit item, int id) => item.id = id;

}