import 'package:flutter/material.dart';
import 'package:minimaltodo/theme/app_theme.dart';
import 'package:minimaltodo/global_utils.dart';
import 'package:minimaltodo/data_models/list_model.dart';
import 'package:minimaltodo/view_models/list_view_model.dart';
import 'package:minimaltodo/views/helper_widgets/custom_text_field.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';

class NewListPage extends StatelessWidget {
  NewListPage({super.key});
  final textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppTheme.background50),
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.background50,
              Colors.white,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: CustomTextField(
                    controller: textController,
                    isMaxLinesNull: true,
                    isAutoFocus: true,
                    hintText: 'e.g., Work, Shopping, Personal',
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Hero(
                tag: 'save_button',
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      if (textController.text.trim().isEmpty) {
                        showToast(
                          title: 'Please enter a list name',
                          type: ToastificationType.error,
                        );
                        return;
                      }
                      ListModel cm = ListModel(name: textController.text.trim());
                      final cvm = Provider.of<ListViewModel>(context, listen: false);
                      final navigator = Navigator.of(context);
                      cvm.addNewList(cm).then((success) {
                        if (success) {
                          showToast(title: 'New List Added');
                          Future.delayed(const Duration(milliseconds: 500), () {
                            navigator.pop();
                            cvm.chosenList = cm;
                            cvm.listScrollController.animateTo(
                              cvm.listScrollController.position.maxScrollExtent,
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            );
                          });
                        }
                      }).catchError((error) {
                        showToast(
                          title: 'List already exists',
                          bgColor: Colors.red,
                          fgColor: Colors.white,
                        );
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      width: double.infinity,
                      height: 55,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppTheme.primary, AppTheme.secondary],
                        ),
                        borderRadius: BorderRadius.circular(15),

                      ),
                      child: const Center(
                        child: Text(
                          'Create List',
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
    );
  }
}
