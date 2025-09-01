import 'package:darrt/helpers/utils.dart';
import 'package:flutter/material.dart' show ScrollController;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'calendar_providers.g.dart';

@riverpod
List<DateTime> dates(Ref ref) {
  final firstDate = getFirstDate();
  final lastDate = getLastDate();

  return List.generate(
    lastDate.difference(firstDate).inDays + 1,
        (index) => firstDate.add(Duration(days: index)),
  );
}

final dateBarControllerProvider = ChangeNotifierProvider<ScrollController>((ref) => ScrollController());
