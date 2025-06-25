import 'dart:convert';

import 'package:flutter/material.dart' show TextSelection;
import 'package:flutter_quill/flutter_quill.dart' show Document, QuillController;
import 'package:flutter_quill/quill_delta.dart' show Delta;
import 'package:minimaltodo/helpers/mini_logger.dart';
import 'package:minimaltodo/helpers/object_box.dart';
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

  Map<String, dynamic> toJson() => {
    'id': id,
    'content': content,
    'createdAt': createdAt?.millisecondsSinceEpoch,
    'updatedAt': updatedAt?.millisecondsSinceEpoch,
    'folderIds': folders.where((f) => f.id > 0).map((f) => f.id).toList(),
  };

  factory Note.fromJson(Map<String, dynamic> json) {
    try {
      final note = Note(
        id: json['id'] ?? 0,
        content: json['content'],
        createdAt: json['createdAt'] != null
            ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'])
            : DateTime.now(),
        updatedAt: json['updatedAt'] != null
            ? DateTime.fromMillisecondsSinceEpoch(json['updatedAt'])
            : DateTime.now(),
      );

      final folderIds = (json['folderIds'] as List?)?.cast<int>() ?? [];
      final fetched = ObjectBox.folderBox.getMany(folderIds);

      final validFolders = <Folder>[];
      final missingIds = <int>[];

      for (var i = 0; i < folderIds.length; i++) {
        final folder = fetched[i];
        if (folder != null) {
          validFolders.add(folder);
        } else {
          missingIds.add(folderIds[i]);
        }
      }

      if (missingIds.isNotEmpty) {
        MiniLogger.w('Note "${note.id}" has missing folder IDs: $missingIds');
      }

      note.folders.addAll(validFolders);
      return note;
    } catch (e, t) {
      MiniLogger.e('Failed to parse Note from JSON: $e');
      MiniLogger.t('Stacktrace: $t');
      rethrow;
    }
  }

  bool equals(Note other) {
    // Compare basic fields
    if (content != other.content ||
        createdAt?.millisecondsSinceEpoch != other.createdAt?.millisecondsSinceEpoch ||
        updatedAt?.millisecondsSinceEpoch != other.updatedAt?.millisecondsSinceEpoch) {
      return false;
    }

    // Compare folders (ToMany relation)
    if (folders.length != other.folders.length) {
      return false;
    }

    final thisFoldersSorted = folders.toList()..sort((a, b) => a.name.compareTo(b.name));
    final otherFoldersSorted = other.folders.toList()..sort((a, b) => a.name.compareTo(b.name));

    for (int i = 0; i < thisFoldersSorted.length; i++) {
      if (!thisFoldersSorted[i].equals(otherFoldersSorted[i])) {
        return false;
      }
    }

    return true;
  }


}
