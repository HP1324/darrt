import 'package:darrt/helpers/utils.dart';
import 'package:darrt/helpers/utils.dart';
import 'package:flutter/material.dart';
import 'package:darrt/helpers/globals.dart' as g;
import 'package:darrt/helpers/mini_router.dart';
import 'package:darrt/note/ui/add_folder_page.dart';
import 'package:darrt/note/ui/folder_item.dart';

class FoldersPage extends StatefulWidget {
  const FoldersPage({super.key});
  @override
  State<FoldersPage> createState() => _FoldersPageState();
}

class _FoldersPageState extends State<FoldersPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: getScaffoldBackgroundColor(context),
      appBar: AppBar(backgroundColor: getScaffoldBackgroundColor(context),
          title: Text('Folders')),
      body: ListenableBuilder(
        listenable: g.folderVm,
        builder: (context, child) {
          final folders = g.folderVm.folders;
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
