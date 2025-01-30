// import 'package:flutter/material.dart';
//
// class CalendarViewModel extends ChangeNotifier {
//   DateTime _selectedDate = DateTime.now();
//   DateTime get selectedDate => _selectedDate;
//
//   final DateTime maxDate = DateTime.now().add(const Duration(days: 18263));
//   final DateTime minDate = DateTime.now().subtract(const Duration(days: 3650));
//
//   void setSelectedDate(DateTime newDate) {
//     if (newDate.isAfter(maxDate) || newDate.isBefore(minDate)) return;
//     _selectedDate = newDate;
//     notifyListeners();
//   }
//
//   static bool isSameDay(DateTime a, DateTime b) {
//     if (a == null || b == null) return false;
//     return a.year == b.year && a.month == b.month && a.day == b.day;
//   }
// }