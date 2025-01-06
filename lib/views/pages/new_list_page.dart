import 'package:flutter/material.dart';
import 'package:minimaltodo/theme/app_theme.dart';
import 'package:minimaltodo/global_utils.dart';
import 'package:minimaltodo/data_models/list_model.dart';
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
      onPopInvokedWithResult: (_,__)async{
        //Not matter user presses FAB or the back button, the list will be edited regardless
        logger.i('Pop called');
        if(editMode!){
          final edited = await lvm.editList();
          tvm.updateTaskListAfterEdit(listToEdit!);
          if(edited){
            showToast(title: 'Task Edited');
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Container(
              color: AppTheme.primary,
            ),
            Column(
              children: [
                AppBar(
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back_ios_new,
                        color: AppTheme.background50),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  title: Text(
                    'Create New List',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.background50,
                    ),
                  ),
                  centerTitle: true,
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                ),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(30),
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.center,
                          colors: [
                            AppTheme.background50,
                            Colors.white,
                          ],
                          stops: const [0.0, 0.8],
                        ),
                      ),
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
                              const Text(
                                'List Name',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Create a new list to organize your tasks better',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
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
                                child: Consumer<ListViewModel>(
                                  builder: (context, listVM, _) {
                                    return ListTile(
                                      onTap: () async {
                                        FocusScope.of(context).unfocus();
                                        await Future.delayed(
                                            const Duration(milliseconds: 100));
                                        if (context.mounted) {
                                          showDialog(
                                            context: context,
                                            builder: (_) =>
                                                const IconPickerDialog(),
                                          );
                                        }
                                      },
                                      leading: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color:
                                              AppTheme.primary.withAlpha(50),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          ListService.getIcon(
                                              listVM.selectedIcon),
                                          color: AppTheme.primary,
                                        ),
                                      ),
                                      title: const Text(
                                        'Choose Icon',
                                        style: TextStyle(
                                          color: AppTheme.primary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      trailing: const Icon(
                                        Icons.chevron_right,
                                        color: AppTheme.primary,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                margin: const EdgeInsets.only(top: 20),
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
                                child: Consumer<ListViewModel>(
                                  builder: (context, listVM, _) {
                                    return ListTile(
                                      onTap: () async {
                                        FocusScope.of(context).unfocus();
                                        await Future.delayed(
                                            const Duration(milliseconds: 100));
                                        if (context.mounted) {
                                          showDialog(
                                            context: context,
                                            builder: (_) =>
                                                const ColorPickerDialog(),
                                          );
                                        }
                                      },
                                      leading: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: listVM.selectedColor != null
                                              ? ListService.listColors[
                                                      listVM.selectedColor]!
                                                  .withAlpha(50)
                                              : AppTheme.primary.withAlpha(50),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          Icons.color_lens,
                                          color: listVM.selectedColor != null
                                              ? ListService.listColors[
                                                  listVM.selectedColor]
                                              : AppTheme.primary,
                                        ),
                                      ),
                                      title: const Text(
                                        'Choose Color',
                                        style: TextStyle(
                                          color: AppTheme.primary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      trailing: const Icon(
                                        Icons.chevron_right,
                                        color: AppTheme.primary,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 40),
                              Hero(
                                tag: 'save_button',
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () async {
                                      final nav = Navigator.of(context);
                                      if (!editMode!) {
                                        final success = await lvm.addNewList();
                                        final scrollController =
                                            lvm.listScrollController;
                                        if (success) {
                                          showToast(title: 'List added');
                                          scrollController.animateTo(
                                              scrollController
                                                  .position.maxScrollExtent,
                                              duration:
                                                  Duration(milliseconds: 500),
                                              curve: Curves.easeOut);
                                          nav.pop();
                                        }
                                      } else {
                                        final edited = await lvm.editList();
                                        if (edited) {
                                          showToast(title: 'List edited');
                                          tvm.updateTaskListAfterEdit(listToEdit!);
                                          nav.pop();
                                        }
                                      }
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 20),
                                      width: double.infinity,
                                      height: 55,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            AppTheme.primary,
                                            AppTheme.secondary
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Center(
                                        child: Text(
                                          editMode! ? 'Edit List' : 'Create List',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
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
      ),
    );
  }
}
