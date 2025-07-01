import 'package:minimaltodo/helpers/globals.dart' as g;
import 'package:minimaltodo/task/models/task.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class CategoryModel {
  CategoryModel({
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
  int get hashCode => Object.hash(id, name, icon, color);

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
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

  /// Compares this [CategoryModel] with another to determine equality.
  ///
  /// This method checks whether two [CategoryModel] instances have identical
  /// values across their key fields: [name], [icon], and [color].
  ///
  /// The optional [checkIdEquality] flag controls whether the [id] field
  /// should be included in the comparison:
  ///
  /// - If `checkIdEquality` is `true`, the [id] values must match for the two
  ///   categories to be considered equal.
  /// - If `false` (default), the [id] is ignored and only the content fields
  ///   are compared.
  ///
  /// Returns `true` if all relevant fields match; otherwise, returns `false`.

  bool equals(CategoryModel other, {bool? checkIdEquality = false}) {
    if (checkIdEquality! && id != other.id) {
      return false;
    }
    return contentHash() == other.contentHash();
  }

  String contentHash() {
    return '$name|$icon|$color';
  }
}
