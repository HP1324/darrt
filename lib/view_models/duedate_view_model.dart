import 'package:flutter/material.dart';
import 'package:minimaltodo/global_utils.dart';

class DuedateViewModel extends ChangeNotifier{
  DateTime? notifyAt;

  void updateDateTime(DateTime date, TimeOfDay time){
    notifyAt = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
      0 //seconds
    );
    if(!isValidDateTime(notifyAt!)){
      notifyAt = null;
    }
    notifyListeners();
  }
  void removeDueDate(){
    notifyAt = null;
  }
}