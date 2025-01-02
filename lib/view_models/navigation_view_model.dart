import 'package:flutter/material.dart';

class NavigationViewModel extends ChangeNotifier {
  var selectedDestination = 0;
  void onDestinationSelected(int selected) {
    selectedDestination = selected;
    notifyListeners();
  }
}
