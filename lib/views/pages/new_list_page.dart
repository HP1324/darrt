import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:minimaltodo/theme/app_theme.dart';
import 'package:minimaltodo/global_utils.dart';
import 'package:minimaltodo/data_models/list_model.dart';
import 'package:minimaltodo/view_models/general_view_model.dart';
import 'package:minimaltodo/view_models/list_view_model.dart';
import 'package:minimaltodo/view_models/task_view_model.dart';
import 'package:minimaltodo/views/widgets/custom_text_field.dart';
import 'package:minimaltodo/views/widgets/color_picker_dialog.dart';
import 'package:provider/provider.dart';
import 'package:minimaltodo/services/list_service.dart';
import 'package:minimaltodo/views/widgets/icon_picker_dialog.dart';

//ignore: must_be_immutable
class NewListPage extends StatelessWidget {
  NewListPage({super.key, this.editMode, this.listToEdit});
  final textController = TextEditingController();
  bool? editMode;
  ListModel? listToEdit;
  @override
  Widget build(BuildContext context) {
    final lvm = Provider.of<ListViewModel>(context, listen: false);
    final tvm = Provider.of<TaskViewModel>(context, listen: false);
    if (editMode!) {
      lvm.currentList = listToEdit!;
    }
    return PopScope(
      onPopInvokedWithResult: (_, __) async {
        //Not matter user presses FAB or the back button, the list will be edited regardless
        logger.i('Pop called');
        if (editMode!) {
          final edited = await lvm.editList();
          tvm.updateTaskListAfterEdit(listToEdit!);
          if (edited) {
            showToast(title: 'List Edited');
          }
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            Column(
              children: [
                AppBar(
                  title: Text(
                    'Create New List',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  centerTitle: true,
                  elevation: 0,
                ),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(30),
                      ),
                    ),
                    child: Container(
                      child: SafeArea(
                        child: SingleChildScrollView(
                          physics: const ClampingScrollPhysics(),
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                            top: 20,
                            left: 20,
                            right: 20,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 20),
                              Text(
                                'List Name',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Create a new list to organize your tasks better',
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Hero(
                                tag: 'list_field',
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withAlpha(50),
                                        spreadRadius: 1,
                                        blurRadius: 10,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: CustomTextField(
                                    controller: textController,
                                    isMaxLinesNull: true,
                                    autoFocus: true,
                                    hintText: 'e.g., Work, Shopping, Personal',
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 15,
                                    ),
                                    onChanged: (value) {
                                      lvm.name = textController.text;
                                    },
                                  ),
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(top: 20),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Consumer2<ListViewModel, GeneralViewModel>(
                                  builder: (context, listVM, generalVM, _) {
                                    return ListTile(
                                      onTap: () async {
                                        generalVM.textFieldNode.unfocus();
                                        await Future.delayed(const Duration(milliseconds: 100));
                                        if (context.mounted) {
                                          showDialog(
                                            context: context,
                                            builder: (_) => const IconPickerDialog(),
                                          );
                                        }
                                      },
                                      leading: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).colorScheme.primary.withAlpha(50),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          ListService.getIcon(listVM.selectedIcon),
                                        ),
                                      ),
                                      title:  Text(
                                        'Choose Icon',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      trailing:  Icon(
                                        Icons.chevron_right,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                margin: const EdgeInsets.only(top: 20),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Consumer2<ListViewModel, GeneralViewModel>(
                                  builder: (context, listVM, generalVM, _) {
                                    return ListTile(
                                      onTap: () async {
                                        generalVM.textFieldNode.unfocus();
                                        await Future.delayed(const Duration(milliseconds: 100));
                                        if (context.mounted) {
                                          showDialog(
                                            context: context,
                                            builder: (_) => const ColorPickerDialog(),
                                          );
                                        }
                                      },
                                      leading: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: listVM.selectedColor != null
                                              ? ListService.listColors[listVM.selectedColor]!
                                                  .withAlpha(50)
                                              : Theme.of(context).colorScheme.primary.withAlpha(50),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          Icons.color_lens,
                                          color: listVM.selectedColor != null
                                              ? ListService.listColors[listVM.selectedColor]
                                              : null,
                                        ),
                                      ),
                                      title:  Text(
                                        'Choose Color',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      trailing:  Icon(
                                        Icons.chevron_right,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 40),

                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        floatingActionButton:  FloatingActionButton(
          onPressed: () async {
            final nav = Navigator.of(context);
            if (!editMode!) {
              final success = await lvm.addNewList();
              final scrollController = lvm.listScrollController;
              if (success) {
                scrollController.animateTo(
                    scrollController.position.maxScrollExtent,
                    duration: Duration(milliseconds: 500),
                    curve: Curves.easeOut);
                nav.pop();
              }
            } else {
              final edited = await lvm.editList();
              if (edited) {
                tvm.updateTaskListAfterEdit(listToEdit!);
                nav.pop();
              }
            }
          },
          child: Icon(Icons.done)
        ),
      ),

    );
  }
}
