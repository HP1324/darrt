import 'package:minimaltodo/task/models/task.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class CategoryModel {
  CategoryModel({this.id = 0, required this.name, this.icon = 'folder', this.color = 'primary'});
  @Id()
  int id;
  String name;
  String icon;
  String color;
  @Backlink('categories')
  final tasks = ToMany<Task>();
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategoryModel &&
        other.id == id &&
        other.name == name &&
        icon == other.icon &&
        color == other.color;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ icon.hashCode ^ color.hashCode;


  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
        id: json["id"],
        name: json["name"],
        icon: json["icon_code"] ?? 'folder',
        color: json["color"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "icon_code": icon,
        "color": color,
      };
}
