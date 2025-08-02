import 'dart:convert';

import 'package:darrt/helpers/globals.dart' as g;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class QuitHabit {
  @Id()
  int id;
  String name;
  /// Relapse list stored as json string using [RelapseEntry.toJsonString]
  String? relapses;
  final String uuid;

  QuitHabit({
    this.id = 0,
    required this.name,
    String? uuid,
  }) : uuid = uuid ?? g.uuid.v4();
}



