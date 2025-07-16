class TaskStats {
  List<DateTime> completions;

  DateTime? currentStreakStart;

  int currentStreakLength;


  TaskStats({
    this.completions =const [],
    this.currentStreakLength = 0,
  });
}
