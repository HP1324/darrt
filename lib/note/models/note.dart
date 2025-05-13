import 'dart:convert';

import 'package:flutter/material.dart' show TextSelection;
import 'package:flutter_quill/flutter_quill.dart' show Document, QuillController;
import 'package:flutter_quill/quill_delta.dart' show Delta;
import 'package:minimaltodo/helpers/mini_logger.dart' show MiniLogger;
import 'package:minimaltodo/note/models/folder.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class Note {
  Note({
    this.id = 0,
    required this.content,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();
  @Id()
  int id;
  String content;
  DateTime? createdAt, updatedAt;
  final folders = ToMany<Folder>();

  factory Note.fromQuillController(QuillController controller) {
    final deltaJson = jsonEncode(controller.document.toDelta().toJson());
    final now = DateTime.now();
    return Note(content: deltaJson, createdAt: now, updatedAt: now);
  }

  QuillController toQuillController() {
    final delta = Delta.fromJson(jsonDecode(content));
    final doc =   Document.fromDelta(delta);
    return QuillController(document: doc, selection: const TextSelection.collapsed(offset: 0));
  }
}
