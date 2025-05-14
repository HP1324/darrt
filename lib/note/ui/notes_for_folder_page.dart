import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:minimaltodo/note/models/folder.dart';
import 'package:minimaltodo/note/state/note_view_model.dart';
import 'package:minimaltodo/note/ui/note_item.dart';
import 'package:provider/provider.dart';

class NotesForFolderPage extends StatefulWidget {
  const NotesForFolderPage({super.key, required this.folder});
  final Folder folder;
  @override
  State<NotesForFolderPage> createState() => _NotesForFolderPageState();
}

class _NotesForFolderPageState extends State<NotesForFolderPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            leading: BackButton(),
            title: Text(widget.folder.name),
            pinned: true,
          ),
          Consumer<NoteViewModel>(builder: (context, noteVM, _) {
            final notes = noteVM.notes.where((n) => n.folders.contains(widget.folder)).toList();
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
          }),
        ],
      )
    );
  }
}
