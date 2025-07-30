
import 'package:darrt/app/state/controllers/state_controller.dart';
import 'package:darrt/habits/quit/state/quit_habit_state.dart';

import '../models/quit_habit.dart';

class QuitHabitStateController extends StateController<QuitHabitState, QuitHabit>{
  @override
  QuitHabit buildModel({required bool edit, QuitHabit? model}) {
    // TODO: implement buildModel
    throw UnimplementedError();
  }

  @override
  void clearState() {
    // TODO: implement clearState
  }

  @override
  void initState(bool edit, [QuitHabit? model]) {
    // TODO: implement initState
  }

}