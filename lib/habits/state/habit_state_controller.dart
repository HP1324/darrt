import 'package:darrt/habits/models/habit.dart';
import 'package:darrt/habits/state/habit_state.dart';
import 'package:darrt/app/state/controllers/state_controller.dart';

class HabitStateController extends StateController<HabitState,BuildHabit>{
  @override
  BuildHabit buildModel({required bool edit, BuildHabit? model}) {
    // TODO: implement buildModel
    throw UnimplementedError();
  }

  @override
  void clearState() {
    // TODO: implement clearState
  }

  @override
  void initState(bool edit, [BuildHabit? model]) {
    // TODO: implement initState
  }

  
}


