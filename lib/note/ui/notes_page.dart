import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:minimaltodo/helpers/mini_router.dart';
import 'package:minimaltodo/note/state/note_view_model.dart';
import 'package:minimaltodo/note/ui/add_note_page.dart';
import 'package:minimaltodo/note/ui/note_item.dart';
import 'package:minimaltodo/task/models/task.dart';
import 'package:minimaltodo/task/ui/task_item.dart';
import 'package:provider/provider.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            leading: BackButton(),
            title: Text('Notes'),
            floating: true,
          ),
          Consumer<NoteViewModel>(
            builder: (context, noteVM,_) {
              final notes = noteVM.notes;
              return SliverPadding(
                padding: const EdgeInsets.all(12),
                sliver: SliverMasonryGrid.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    return NoteItem(note: note);
                  },
                ),
              );
            }
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          MiniRouter.to(context, AddNotePage(edit: false));
        },
        shape: StadiumBorder(),
        label: Row(
          children: [
            Icon(Icons.add),
            const SizedBox(width: 8),
            Text('Add Note'),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
