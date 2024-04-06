import 'package:hive/hive.dart';
import 'package:tasktracker/models/notes_model.dart';

class Boxes {
  static Box<NotesModel> getdata() => Hive.box<NotesModel>("tasks");
}
