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
}