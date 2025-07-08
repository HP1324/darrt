
import 'package:objectbox/objectbox.dart';

@Entity()
class BoxPref{
  @Id()
  int id = 0;

  @Unique()
  String key;

  String type;
  String value;

  BoxPref({required this.key,required this.type,required this.value});

}