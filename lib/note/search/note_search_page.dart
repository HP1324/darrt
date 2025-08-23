import 'dart:async';

import 'package:darrt/app/extensions/extensions.dart';
import 'package:darrt/app/services/object_box.dart';
import 'package:darrt/note/models/note.dart';
import 'package:darrt/note/ui/note_item.dart';
import 'package:darrt/objectbox.g.dart';
import 'package:flutter/material.dart';

class NoteSearchPage extends StatefulWidget {
  const NoteSearchPage({super.key});

  @override
  State<NoteSearchPage> createState() => _NoteSearchPageState();
}

class _NoteSearchPageState extends State<NoteSearchPage> {
  late final TextEditingController searchController;

  late final StreamController<String> searchStreamController;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    searchStreamController = StreamController<String>();
  }

  @override
  void dispose() {
    searchController.dispose();
    searchStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(10),
      child: Material(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              leading: BackButton(),
              titleSpacing: 0,
              title: TextField(
                controller: searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search notes...',
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  searchStreamController.sink.add(value);
                },
              ),
            ),
            StreamBuilder(
              stream: searchStreamController.stream,
              builder: (context, snapshot) {
                final searchQuery = snapshot.data ?? '';

                final box = ObjectBox().noteBox;

                final List<Note> foundNotes = box
                    .query(Note_.content.contains(searchQuery, caseSensitive: false))
                    .build()
                    .find();

                if (foundNotes.isNotEmpty) {
                  return SliverGrid.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        mainAxisExtent: MediaQuery.sizeOf(context).height * 0.16
                    ),
                    itemCount: foundNotes.length,
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