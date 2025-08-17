import 'package:darrt/helpers/globals.dart' as g;
import 'package:darrt/task/models/task.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class TaskCategory {
  TaskCategory({
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
  @Backlink('categories')
  final tasks = ToMany<Task>();

  bool didUpdateCategory(TaskCategory oldCategory){
    return name != oldCategory.name || icon != oldCategory.icon || color != oldCategory.color;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TaskCategory &&
        other.id == id &&
        other.name == name &&
        icon == other.icon &&
        uuid == other.uuid &&
        color == other.color;
  }

  @override
  int get hashCode => Object.hash(id, name, icon, color, uuid);

  factory TaskCategory.fromJson(Map<String, dynamic> json) => TaskCategory(
    id: json["id"],
    name: json["name"],
    icon: json["icon_code"] ?? 'folder',
    color: json["color"],
    uuid: json['uuid'],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "icon_code": icon,
    "color": color,
    'uuid': uuid,
  };

  static List<TaskCategory> convertJsonListToObjectList(List<Map<String, dynamic>> jsonList) {
    return jsonList.map(TaskCategory.fromJson).toList();
  }

  static List<Map<String, dynamic>> convertObjectsListToJsonList(List<TaskCategory> objectList) {
    return objectList.map((category) => category.toJson()).toList();
  }
}
