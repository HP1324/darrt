import 'package:flutter/foundation.dart';
import 'package:darrt/helpers/globals.dart' as g;
import 'package:darrt/helpers/mini_logger.dart';
import 'package:darrt/note/models/note.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class Folder {
  Folder({
    this.id = 0,
    required this.name,
    this.icon = 'folder',
    this.color = 'primary',
    String? uuid,
  }) : uuid = uuid ?? g.uuid.v4();
  @Id()
  int id;
  String name;
  String icon;
  String color;
  final String uuid;
  @Backlink('folders')
  final notes = ToMany<Note>();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Folder && other.id == id && other.name == name && listEquals(
        other.notes.map((n) => n.id).toList()..sort(),
        notes.map((n) => n.id).toList()..sort()
    );
  }
  @override
  int get hashCode => Object.hash(id, name);

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'color': color,
    'icon' :icon,
    'uuid': uuid,
  };
  factory Folder.fromJson(Map<String, dynamic> json) {
    try {
      return Folder(
        id: json['id'] ?? 0,
        name: json['name'],
        color: json['color'],
        icon: json['icon'],
        uuid: json['uuid'],
      );
    } catch (e, t) {
      MiniLogger.e('Failed to parse Folder from JSON: $e');
      MiniLogger.t('Stacktrace: $t');
      rethrow;
    }
  }

  static List<Map<String, dynamic>> convertObjectsListToJsonList(List<Folder> objectList) {
    return objectList.map((folder) => folder.toJson()).toList();
  }
  static List<Folder> convertJsonListToObjectList(List<Map<String, dynamic>> jsonList) {
    return jsonList.map(Folder.fromJson).toList();
  }
}
