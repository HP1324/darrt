import 'dart:convert';

import 'package:flutter/material.dart' show TextSelection;
import 'package:flutter_quill/flutter_quill.dart' show Document, QuillController;
import 'package:flutter_quill/quill_delta.dart' show Delta;
import 'package:minimaltodo/helpers/globals.dart' as g;
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
    String? uuid,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now(),
        uuid = g.uuid.v4();
  @Id()
  int id;
  String content;
  DateTime? createdAt, updatedAt;
  final String uuid;
  final folders = ToMany<Folder>();

  factory Note.fromQuillController(QuillController controller,{String? uuid}) {
    final deltaJson = jsonEncode(controller.document.toDelta().toJson());
    final now = DateTime.now();
    return Note(content: deltaJson, createdAt: now, updatedAt: now,uuid: uuid ?? g.uuid.v4());
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
    'uuid': uuid,
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

}
