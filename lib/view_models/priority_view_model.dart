import 'package:flutter/material.dart';
import 'package:minimaltodo/theme/app_theme.dart';

class PriorityViewModel extends ChangeNotifier{

  List<String> priorities = ["Urgent",  "High", "Medium", "Low"];
  int currentValue = 3;  // Default to Low
  String get currentPriority => priorities[currentValue];

  void navigatePriority(bool isNext) {
    if (isNext) {
      currentValue = (currentValue + 1) % priorities.length;
    } else {
      currentValue = (currentValue - 1 + priorities.length) % priorities.length;
    }

    notifyListeners();
  }


}