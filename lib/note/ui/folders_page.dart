import 'package:flutter/material.dart';
import 'package:minimaltodo/helpers/mini_router.dart';
import 'package:minimaltodo/note/state/folder_view_model.dart';
import 'package:minimaltodo/note/ui/add_folder_page.dart';
import 'package:minimaltodo/note/ui/folder_item.dart';
import 'package:provider/provider.dart';

class FoldersPage extends StatefulWidget {
  const FoldersPage({super.key});

  @override
  State<FoldersPage> createState() => _FoldersPageState();
}

class _FoldersPageState extends State<FoldersPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Folders')),
      body: Consumer<FolderViewModel>(
        builder: (context, folderVM, _) {
          final folders = folderVM.folders;
          return ListView.builder(
            itemCount: folders.length,
            itemBuilder: (context, index) {
              return FolderItem(folder: folders[index]);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          MiniRouter.to(context, AddFolderPage(edit: false));
        },
        shape: StadiumBorder(),
        child: Icon(Icons.create_new_folder_outlined),
      ),
    );
  }
}
