import 'package:flutter/material.dart';
import 'package:minimaltodo/services/list_service.dart';
import 'package:minimaltodo/theme/app_theme.dart';
import 'package:minimaltodo/view_models/general_view_model.dart';
import 'package:minimaltodo/view_models/list_view_model.dart';
import 'package:provider/provider.dart';

class IconPickerDialog extends StatelessWidget {
  const IconPickerDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary],
                ),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Text(
                    'Choose an Icon',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize:
                          Theme.of(context).textTheme.titleLarge!.fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.5,
              padding: const EdgeInsets.all(16),
              child: Consumer2<ListViewModel,GeneralViewModel>(
                builder: (context, listVM,generalVM ,_) {
                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                    ),
                    itemCount: ListService.icons.length,
                    itemBuilder: (context, index) {
                      final iconCode = ListService.icons.keys.elementAt(index);
                      final icon = ListService.icons.values.elementAt(index);
                      final isSelected = listVM.selectedIcon == iconCode;

                      return InkWell(
                        onTap: () {
                          listVM.updateSelectedIcon(iconCode);
                          Navigator.pop(context);
                          generalVM.textFieldNode.unfocus();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary.withAlpha(50)
                                : Colors.transparent,
                            border: Border.all(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey.shade300,
                              width: isSelected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            icon,
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey.shade700,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
