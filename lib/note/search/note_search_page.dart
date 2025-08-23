import 'dart:async';

import 'package:darrt/app/extensions/extensions.dart';
import 'package:darrt/app/services/object_box.dart';
import 'package:darrt/note/models/note.dart';
import 'package:darrt/note/ui/note_item.dart';
import 'package:darrt/objectbox.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class NoteSearchPage extends StatefulWidget {
  const NoteSearchPage({super.key});

  @override
  State<NoteSearchPage> createState() => _NoteSearchPageState();
}

class _NoteSearchPageState extends State<NoteSearchPage> {
  late final TextEditingController _searchController;

  late final StreamController<String> _streamController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _streamController = StreamController<String>();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _streamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            leading: BackButton(),
            titleSpacing: 0,
            title: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search notes...',
                border: InputBorder.none,
              ),
              onChanged: (value) {
                _streamController.sink.add(value);
              },
            ),
          ),
          StreamBuilder(
            stream: _streamController.stream,
            builder: (context, snapshot) {
              final searchQuery = snapshot.data ?? '';
              
              final box = ObjectBox().noteBox;

              final List<Note> foundNotes = box
                  .query(Note_.content.contains(searchQuery, caseSensitive: false))
                  .build()
                  .find();
      
              if (foundNotes.isNotEmpty) {
                return SliverMasonryGrid.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childCount: foundNotes.length,
                  itemBuilder: (context, index) {
                    final note = foundNotes[index];
                    return NoteItem(note: note);
                  },
                );
              }
              return _NotesEmptyIndicator();
            },
          ),
        ],
      ),
    );
  }
}


class _NotesEmptyIndicator extends StatelessWidget {
  const _NotesEmptyIndicator();

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final textTheme = context.textTheme;
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: scheme.primaryContainer.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.note_add_outlined,
                size: 60,
                color: scheme.primary.withValues(alpha: 0.7),
              ),
            ),
            SizedBox(height: 24),
            Text(
              'No Notes Found',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: scheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}