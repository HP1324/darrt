import 'package:flutter/foundation.dart';
import 'package:minimaltodo/helpers/mini_logger.dart';
import 'package:minimaltodo/note/models/note.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class Folder {
  Folder({
    this.id = 0,
    required this.name,
  });
  @Id()
  int id;
  String name;
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
  };
  factory Folder.fromJson(Map<String, dynamic> json) {
    try {
      return Folder(
        id: json['id'] ?? 0,
        name: json['name'],
      );
    } catch (e, t) {
      MiniLogger.e('Failed to parse Folder from JSON: $e');
      MiniLogger.t('Stacktrace: $t');
      rethrow;
    }
  }

  /// Compares this [Folder] with another to determine equality.
  ///
  /// Two [Folder] instances are considered equal if their [name] fields match.
  ///
  /// The optional [checkIdEquality] parameter controls whether the [id] field
  /// is included in the comparison:
  ///
  /// - If `true`, both the [id] and [name] must be equal.
  /// - If `false` (default), only the [name] field is compared.
  ///
  /// The associated notes (via backlink) are intentionally not compared
  /// to avoid circular reference issues.
  ///
  /// Returns `true` if the relevant fields match; otherwise, `false`.

  bool equals(Folder other, {bool? checkIdEquality = false}) {
    if (checkIdEquality! && id != other.id) {
      return false;
    }
    return name == other.name;
    // Note: Not comparing notes backlink to avoid circular reference
  }

}
