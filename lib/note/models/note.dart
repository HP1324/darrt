import 'dart:convert';

import 'package:flutter/material.dart' show TextSelection;
import 'package:flutter_quill/flutter_quill.dart' show Document, QuillController;
import 'package:flutter_quill/quill_delta.dart' show Delta;
import 'package:darrt/helpers/globals.dart' as g;
import 'package:darrt/helpers/mini_logger.dart';
import 'package:darrt/app/services/object_box.dart';
import 'package:darrt/note/models/folder.dart';
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

  Map<String, dynamic> toJson() => {
    'id': id,
    'content': content,
    'createdAt': createdAt?.millisecondsSinceEpoch,
    'updatedAt': updatedAt?.millisecondsSinceEpoch,
    'folderIds': folders.where((f) => f.id > 0).map((f) => f.id).toList(),
    'uuid': uuid,
    'folderUuids':folders.where((f) => f.id > 0).map((f) => f.uuid).toList(),
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

      final folderIds = (json['folderIds'] as List?)?.cast<int>() ?? [];
      final fetched = ObjectBox().folderBox.getMany(folderIds);

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

  /// Compares this [Note] with another to determine deep equality.
  ///
  /// This method checks whether two [Note] instances are equal by comparing:
  /// - Their [content] fields,
  /// - Their [createdAt] and [updatedAt] timestamps (in milliseconds),
  /// - And their associated [folders] (a [ToMany] relation), comparing
  ///   folder lists by name using each folder's own `.equals()` method.
  ///
  /// The [checkIdEquality] parameter controls whether the [id] field is included:
  ///
  /// - If `true`, the [id] values must match for the notes to be considered equal.
  /// - If `false` (default), [id] is ignored and only the content and relations
  ///   are compared.
  ///
  /// Folders are sorted by name before comparison to ensure order-independent equality.
  ///
  /// Returns `true` if all compared fields and folders match; otherwise, `false`.

  bool equals(Note other, {bool? checkIdEquality = false}) {
    if (checkIdEquality! && id != other.id) {
      return false;
    }

    return contentHash() == other.contentHash();
  }

  String contentHash() {
    final created = createdAt?.millisecondsSinceEpoch ?? 'null';
    final updated = updatedAt?.millisecondsSinceEpoch ?? 'null';

    final folderNames = folders.map((f) => f.name).toList()..sort();
    final foldersStr = folderNames.join(',');

    return '$content|$created|$updated|$foldersStr';
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

}
