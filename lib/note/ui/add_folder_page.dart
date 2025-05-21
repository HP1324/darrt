import 'package:flutter/material.dart';
import 'package:minimaltodo/helpers/messages.dart';
import 'package:minimaltodo/helpers/utils.dart';
import 'package:minimaltodo/note/models/folder.dart';
import 'package:toastification/toastification.dart';
import 'package:minimaltodo/helpers/globals.dart' as g;
class AddFolderPage extends StatefulWidget {
  const AddFolderPage({super.key, required this.edit, this.folder}):assert(!edit || folder != null);
  final bool edit;
  final Folder? folder;
  @override
  State<AddFolderPage> createState() => _AddFolderPageState();
}

class _AddFolderPageState extends State<AddFolderPage> {
  @override
  void initState() {
    super.initState();
    g.folderSc.initState(widget.edit, widget.edit ? widget.folder : null);
  }
  @override
  void dispose() {
    super.dispose();
    g.folderSc.clearState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.edit ? widget.folder!.name : 'Add Folder')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: TextField(
          controller: g.folderSc.textController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Enter Folder Name Here',
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final folder = g.folderSc.buildModel(edit: widget.edit, model: widget.folder);
          final message = g.folderVm.putItem(folder, edit: widget.edit);
          if(message != Messages.mFolderEmpty) {
            showToast(context, type: ToastificationType.success, description: message);
            Navigator.pop(context);
          }else{
            showToast(context, type: ToastificationType.error, description: message);
          }
        },
        child: const Icon(Icons.done),
      ),
    );
  }
}
