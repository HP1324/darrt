import 'package:collection/collection.dart';
import 'package:darrt/category/models/task_category.dart';
import 'package:darrt/helpers/globals.dart' as g;
import 'package:darrt/helpers/icon_color_storage.dart';
import 'package:flutter/material.dart';
class CategoryChip extends StatelessWidget {
  const CategoryChip({super.key, required this.category});
  final TaskCategory category;
  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final textTheme = Theme.of(context).textTheme;
    return ListenableBuilder(
      listenable: g.catVm,
      builder: (context,child) {
        final thisCategory = g.catVm.categories.firstWhereOrNull((c) => c.id == category.id);
        if(thisCategory == null) return const SizedBox.shrink();
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 0.8, vertical: 1),
          decoration: BoxDecoration(
            color: IconColorStorage.colors[thisCategory.color]?.withAlpha(20) ?? primary.withAlpha(20),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(IconColorStorage.flattenedIcons[thisCategory.icon],size:12,color: IconColorStorage.colors[thisCategory.color]),
              const SizedBox(width: 4),
              Text(thisCategory.name, style: textTheme.labelMedium),
            ],
          ),
        );
      }
    );
  }
}
