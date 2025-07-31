import 'package:darrt/category/models/entity_category.dart';
import 'package:darrt/habits/build/models/build_habit.dart';
import 'package:darrt/habits/build/state/build_habit_state.dart';
import 'package:darrt/app/state/controllers/state_controller.dart';
import 'package:darrt/task/models/repeat_config.dart';

class HabitStateController extends StateController<BuildHabitState,BuildHabit>{
  @override
  BuildHabit buildModel({required bool edit, BuildHabit? model}) {
    // TODO: implement buildModel
    throw UnimplementedError();
  }

  @override
  void clearState() {
    state = state.copyWith(
      categorySelection: {EntityCategory(id: 1, name: 'General'): true},
      startDate: DateTime.now(),
      endDate: null,
      endTime: null,
      repeatConfig: RepeatConfig(),
      reminders: [],

    );
  }

  @override
  void initState(bool edit, [BuildHabit? model]) {
    // TODO: implement initState
  }

  
}


