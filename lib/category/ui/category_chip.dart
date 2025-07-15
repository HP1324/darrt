import 'package:flutter/material.dart';
import 'package:darrt/category/models/task_category.dart';
import 'package:darrt/helpers/icon_color_storage.dart';
import 'package:darrt/helpers/globals.dart' as g;
class CategoryChip extends StatelessWidget {
  const CategoryChip({super.key, required this.category});
  final TaskCategory category;
  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final textTheme = Theme.of(context).textTheme;
    return ListenableBuilder(
      listenable: g.catVm,
      builder: (_,child) {
        final thisCategory = g.catVm.categories.firstWhere((c) => c.id == category.id);
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 0.5, vertical: 2),
          decoration: BoxDecoration(
            color: IconColorStorage.colors[thisCategory.color]?.withAlpha(10) ?? primary.withAlpha(10),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(IconColorStorage.flattenedIcons[thisCategory.icon],size:12,color: IconColorStorage.colors[thisCategory.color]),
              const SizedBox(width: 4),
              Text(category.name, style: textTheme.labelMedium),
            ],
          ),
        );
      }
    );
  }
}
