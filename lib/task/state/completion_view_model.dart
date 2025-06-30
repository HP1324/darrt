import 'package:flutter/foundation.dart' show debugPrint;
import 'package:minimaltodo/app/state/viewmodels/view_model.dart';
import 'package:minimaltodo/helpers/typedefs.dart';
import 'package:minimaltodo/task/models/task_completion.dart';

class CompletionViewModel extends ViewModel<TaskCompletion> {

  @override
  void setItemId(TaskCompletion item, int id) => item.id = id;

  @override
  int getItemId(TaskCompletion item) => item.id;

  // @override
  // void mergeItems(EntityObjectListMap<TaskCompletion> oldItems, EntityObjectListMap<TaskCompletion> newItems){
  //
  // }

  @override
  void putManyForRestore(List<TaskCompletion> restoredItems) {
    // TODO: implement putManyForRestore
  }


  @override
  EntityObjectList<TaskCompletion> convertJsonListToObjectList(EntityJsonList jsonList) {
    return jsonList.map(TaskCompletion.fromJson).toList();
  }

  @override
  EntityJsonList convertObjectsListToJsonList(EntityObjectList<TaskCompletion> objectList) {
    debugPrint('no error until now');
    return objectList.map((completion) => completion.toJson()).toList();
  }


  //The following methods are only overridden to avoid not implemented error. this class does not need to override them functionally
  @override
  String getCreateSuccessMessage() => '';
  @override
  String getDeleteSuccessMessage(int length)=> '';
  @override
  String getUpdateSuccessMessage() =>'';

  @override
  String getItemUuid(TaskCompletion item) => item.uuid!;


}
