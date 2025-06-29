import 'package:minimaltodo/app/state/viewmodels/view_model.dart';
import 'package:minimaltodo/task/models/task_completion.dart';

/// Making this class abstract because it does not directly belong to ViewModel family.
/// it should not implement some of the methods in that class.
class CompletionViewModel extends ViewModel<TaskCompletion> {

  @override
  void setItemId(TaskCompletion item, int id) => item.id = id;

  @override
  int getItemId(TaskCompletion item) => item.id;

  @override
  void mergeItems(List<TaskCompletion> oldItems, List<TaskCompletion> newItems){

  }

  @override
  String getCreateSuccessMessage() => '';

  @override
  String getDeleteSuccessMessage(int length)=> '';

  @override
  String getUpdateSuccessMessage() =>'';

  @override
  void putManyForRestore(List<TaskCompletion> restoredItems) {
    // TODO: implement putManyForRestore
  }
}
