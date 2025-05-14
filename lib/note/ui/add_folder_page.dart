import 'package:flutter/material.dart';
import 'package:minimaltodo/helpers/messages.dart';
import 'package:minimaltodo/helpers/utils.dart';
import 'package:minimaltodo/note/models/folder.dart';
import 'package:minimaltodo/note/state/folder_state_controller.dart';
import 'package:minimaltodo/note/state/folder_view_model.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';

class AddFolderPage extends StatefulWidget {
  const AddFolderPage({super.key, required this.edit, this.folder}):assert(!edit || folder != null);
  final bool edit;
  final Folder? folder;
  @override
  State<AddFolderPage> createState() => _AddFolderPageState();
}

class _AddFolderPageState extends State<AddFolderPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.edit ? widget.folder!.name : 'Add Folder')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: TextField(
          controller: context.read<FolderStateController>().textController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Enter Folder Name Here',
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final controller = context.read<FolderStateController>();
          final message = context.read<FolderViewModel>().putItem(Folder(name: controller.textController.text), edit: widget.edit);
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
