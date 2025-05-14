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
    return other is Folder && other.id == id && other.name == name;
  }
  @override
  int get hashCode => Object.hash(id, name);
}
