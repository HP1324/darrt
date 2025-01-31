import 'package:flutter/material.dart';

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