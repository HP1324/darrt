import 'package:flutter/material.dart';
import 'package:minimaltodo/helpers/mini_router.dart';
import 'package:minimaltodo/note/models/folder.dart';
import 'package:minimaltodo/note/ui/add_folder_page.dart';
import 'package:minimaltodo/note/ui/notes_for_folder_page.dart';

class FolderItem extends StatefulWidget {
  const FolderItem({super.key, required this.folder});
  final Folder folder;
  @override
  State<FolderItem> createState() => _FolderItemState();
}

class _FolderItemState extends State<FolderItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withAlpha(60)),
        color: Theme.of(context).colorScheme.surface.withAlpha(100),
      ),
      child: ListTile(
        onTap: (){
          MiniRouter.to(context, NotesForFolderPage(folder: widget.folder));
        },
        leading: Icon(Icons.folder, color: Theme.of(context).colorScheme.primary),
        title: Text(widget.folder.name),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(onTap: () {
              MiniRouter.to(context, AddFolderPage(edit: true, folder: widget.folder));
            }, child: Text('Edit')),
            PopupMenuItem(onTap: () {}, child: Text('Delete')),
          ],
        ),
      ),
    );
  }
}
