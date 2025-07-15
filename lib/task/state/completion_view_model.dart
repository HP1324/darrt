import 'package:darrt/helpers/mini_logger.dart';
import 'package:darrt/app/state/viewmodels/view_model.dart';
import 'package:darrt/task/models/task_completion.dart';

class CompletionViewModel extends ViewModel<TaskCompletion> {

  @override
  void setItemId(TaskCompletion item, int id) => item.id = id;

  @override
  int getItemId(TaskCompletion item) => item.id;

  // @override
  // void mergeItems(Map<String,dynamic><TaskCompletion> oldItems, Map<String,dynamic><TaskCompletion> newItems){
  //
  // }

  @override
  void putManyForRestore(List<TaskCompletion> restoredItems) {
    // TODO: implement putManyForRestore
  }


  @override
  List<TaskCompletion> convertJsonListToObjectList(List<Map<String,dynamic>> jsonList) {
    return jsonList.map(TaskCompletion.fromJson).toList();
  }

  @override
  List<Map<String,dynamic>> convertObjectsListToJsonList(List<TaskCompletion> objectList) {
    MiniLogger.dp('no error until now');
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
