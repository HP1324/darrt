import 'package:darrt/app/state/viewmodels/view_model.dart';
import 'package:darrt/habits/build/models/build_habit.dart';

class BuildHabitViewModel extends ViewModel<BuildHabit>{
  @override
  List<BuildHabit> convertJsonListToObjectList(List<Map<String, dynamic>> jsonList) {
    // TODO: implement convertJsonListToObjectList
    throw UnimplementedError();
  }

  @override
  List<Map<String, dynamic>> convertObjectsListToJsonList(List<BuildHabit> objectList) {
    // TODO: implement convertObjectsListToJsonList
    throw UnimplementedError();
  }

  @override
  String getCreateSuccessMessage() {
    // TODO: implement getCreateSuccessMessage
    throw UnimplementedError();
  }

  @override
  String getDeleteSuccessMessage(int length) {
    // TODO: implement getDeleteSuccessMessage
    throw UnimplementedError();
  }

  @override
  int getItemId(BuildHabit item) {
    // TODO: implement getItemId
    throw UnimplementedError();
  }

  @override
  String getItemUuid(BuildHabit item) {
    // TODO: implement getItemUuid
    throw UnimplementedError();
  }

  @override
  String getUpdateSuccessMessage() {
    // TODO: implement getUpdateSuccessMessage
    throw UnimplementedError();
  }

  @override
  void putManyForRestore(List<BuildHabit> restoredItems) {
    // TODO: implement putManyForRestore
  }

  @override
  void setItemId(BuildHabit item, int id) {
    // TODO: implement setItemId
  }

}