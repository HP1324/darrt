import 'dart:convert';

import 'package:darrt/helpers/globals.dart' as g;
import 'package:darrt/helpers/mini_logger.dart';
import 'package:darrt/note/models/folder.dart';
import 'package:flutter/material.dart' show TextSelection;
import 'package:flutter_quill/flutter_quill.dart' show Document, QuillController;
import 'package:flutter_quill/quill_delta.dart' show Delta;
import 'package:objectbox/objectbox.dart';

@Entity()
class Note {
  Note({
    this.id = 0,
    required this.content,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? uuid,
    List<String>? folderUuids
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now(),
        uuid = uuid ?? g.uuid.v4(),
        folderUuids = folderUuids ?? [];
  @Id()
  int id;
  String content;
  @Property(type: PropertyType.date)
  DateTime? createdAt, updatedAt;
  final String uuid;
  List<String> folderUuids;
  final folders = ToMany<Folder>();

  factory Note.fromQuillController(QuillController controller,{String? uuid}) {
    final deltaJson = jsonEncode(controller.document.toDelta().toJson());
    final now = DateTime.now();
    return Note(content: deltaJson, createdAt: now, updatedAt: now,uuid: uuid ?? g.uuid.v4());
  }

  QuillController get quillController {
    final delta = Delta.fromJson(jsonDecode(content));
    final doc =   Document.fromDelta(delta);
    return QuillController(document: doc, selection: const TextSelection.collapsed(offset: 0));
  }

  /// Extracts note content as plain text, note content is stored as deltaJson, using ```
  ///     final deltaJson = jsonEncode(controller.document.toDelta().toJson());
  ///     final now = DateTime.now();
  ///     return Note(content: deltaJson, createdAt: now, updatedAt: now,uuid: uuid ?? g.uuid.v4());
  ///     ```
  String extractPlainTextFromContent() {
    if (content.isEmpty) return '';

    try {
      // Parse the JSON content from Quill
      final Map<String, dynamic> delta = jsonDecode(content);
      final List<dynamic> ops = delta['ops'] ?? [];

      StringBuffer textBuffer = StringBuffer();
      for (var op in ops) {
        if (op is Map<String, dynamic> && op.containsKey('insert')) {
          final insert = op['insert'];
          if (insert is String) {
            textBuffer.write(insert);
          }
        }
      }

      return textBuffer.toString();
    } catch (e) {
      // If parsing fails, return the raw content
      return content;
    }
  }
  Map<String, dynamic> toJson() => {
    'id': id,
    'content': content,
    'createdAt': createdAt?.millisecondsSinceEpoch,
    'updatedAt': updatedAt?.millisecondsSinceEpoch,
    'folderIds': folders.where((f) => f.id > 0).map((f) => f.id).toList(),
    'uuid': uuid,
    'folderUuids':folderUuids,
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
        uuid: json['uuid'],
        folderUuids: List<String>.from(json['folderUuids']),
      );

      // final folderIds = (json['folderIds'] as List?)?.cast<int>() ?? [];
      // final fetched = ObjectBox().folderBox.getMany(folderIds);
      //
      // final validFolders = <Folder>[];
      // final missingIds = <int>[];
      //
      // for (var i = 0; i < folderIds.length; i++) {
      //   final folder = fetched[i];
      //   if (folder != null) {
      //     validFolders.add(folder);
      //   } else {
      //     missingIds.add(folderIds[i]);
      //   }
      // }
      //
      // if (missingIds.isNotEmpty) {
      //   MiniLogger.w('Note "${note.id}" has missing folder IDs: $missingIds');
      // }
      //
      // note.folders.addAll(validFolders);
      return note;
    } catch (e, t) {
      MiniLogger.e('Failed to parse Note from JSON: $e');
      MiniLogger.t('Stacktrace: $t');
      rethrow;
    }
  }



  static String? notesToJsonString(List<Note>? notes) {
    if (notes == null) return null;

    final Map<String, String> notesMap = {};
    for (final note in notes) {
      notesMap[note.uuid] = note.content;
    }

    return jsonEncode(notesMap);
  }
  static List<Note>? notesFromJsonString(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty || jsonString == '{}') {
      return null;
    }

    try {
      final Map<String, dynamic> decoded = jsonDecode(jsonString);
      return decoded.entries.map((entry) {
        return Note(
          uuid: entry.key,        // UUID from JSON key
          content: entry.value.toString(),  // Content from JSON value
        );
      }).toList();
    } catch (e) {
      MiniLogger.dp('Error parsing notes JSON: $e');
      return [];
    }
  }


  static List<Note> convertJsonListToObjectList(List<Map<String, dynamic>> jsonList) {
    return jsonList.map(Note.fromJson).toList();
  }

  static List<Map<String, dynamic>> convertObjectsListToJsonList(List<Note> objectList) {
    return objectList.map((note) => note.toJson()).toList();
  }

}
