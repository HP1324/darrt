import 'package:flutter/material.dart';
import 'package:minimaltodo/data_models/wishlist.dart';
import 'package:minimaltodo/view_models/wishlist_view_model.dart';
import 'package:provider/provider.dart';

class WishListPage extends StatelessWidget {
  const WishListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WishListViewModel>(
      builder: (context, wishListVM, child) {
        return Column(
          children: [
            if (wishListVM.isSelectionMode)
              _buildSelectionBar(context, wishListVM),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: wishListVM.wishLists.isEmpty
                    ? _buildEmptyState(context, wishListVM)
                    : _buildWishList(context, wishListVM),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, WishListViewModel viewModel) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.star_outline,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              '"Dreams are not what you see in sleep, they are the things that don\'t let you sleep."',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '- APJ Abdul Kalam',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => _showAddWishDialog(context, viewModel),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.add,
                    size: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Add a wish',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWishList(BuildContext context, WishListViewModel viewModel) {
    return ListView.builder(
      itemCount: viewModel.wishLists.length + 1, // +1 for "Add a wish" button
      itemBuilder: (context, index) {
        // Show new item form at the beginning if empty, at the end if not
        if (viewModel.isAddingNew) {
          if ((viewModel.wishLists.isEmpty && index == 0) ||
              (viewModel.wishLists.isNotEmpty &&
                  index == viewModel.wishLists.length - 1)) {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return SizeTransition(
                  sizeFactor: animation,
                  child: FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                );
              },
              child: _buildNewWishItem(context, viewModel),
            );
          }
        }

        // Show "Add a wish" button at the end
        if (index == viewModel.wishLists.length) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: TextButton(
                onPressed: () => _showAddWishDialog(context, viewModel),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add,
                      size: 18,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Add a wish',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Show existing wish items
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _buildWishListItem(
            context,
            viewModel,
            viewModel.wishLists[index],
          ),
        );
      },
    );
  }

  Widget _buildNewWishItem(BuildContext context, WishListViewModel viewModel) {
    return Card(
      key: const ValueKey('new_wish_item'),
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListTile(
        leading: Checkbox(
          value: false,
          onChanged: null,
        ),
        title: TextField(
          controller: viewModel.titleController,
          autofocus: true,
          style: Theme.of(context).textTheme.bodyLarge,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'Enter your wish',
            hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              viewModel.addWishList(value);
            }
          },
        ),
        trailing: TextButton(
          onPressed: () {
            if (viewModel.titleController.text.trim().isNotEmpty) {
              viewModel.addWishList(viewModel.titleController.text);
            }
          },
          child: Text(
            'Done',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionBar(BuildContext context, WishListViewModel viewModel) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withAlpha(20),
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: viewModel.clearSelection,
              ),
              const SizedBox(width: 8),
              Text(
                '${viewModel.selectedIds.length} selected',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => viewModel.deleteSelected(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWishListItem(
    BuildContext context,
    WishListViewModel viewModel,
    WishList wishList,
  ) {
    final isSelected = viewModel.selectedIds.contains(wishList.id);
    final isEditing = viewModel.editingWishList?.id == wishList.id;
    final colorScheme = Theme.of(context).colorScheme;

    if (isEditing) {
      return _buildEditingItem(context, viewModel, wishList);
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      elevation: 0,
      color: isSelected
          ? colorScheme.inverseSurface.withAlpha(10)
          : colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        leading: Checkbox(
          value: wishList.isFulfilled,
          onChanged: (value) => viewModel.toggleFulfilled(wishList),
        ),
        title: Text(
          wishList.title,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                decoration:
                    wishList.isFulfilled ? TextDecoration.lineThrough : null,
                color: wishList.isFulfilled
                    ? colorScheme.outline
                    : colorScheme.onSurface,
              ),
        ),
        selected: isSelected,
        onTap: () {
          if (viewModel.isSelectionMode) {
            viewModel.toggleSelection(wishList.id!);
          } else {
            viewModel.startEditing(wishList);
          }
        },
        onLongPress: () {
          if (!viewModel.isSelectionMode) {
            viewModel.toggleSelection(wishList.id!);
          }
        },
      ),
    );
  }

  Widget _buildEditingItem(
    BuildContext context,
    WishListViewModel viewModel,
    WishList wishList,
  ) {
    return ListTile(
      title: TextField(
        controller: viewModel.titleController,
        autofocus: true,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onSubmitted: (value) {
          viewModel.updateWishList(wishList, value);
          viewModel.titleController.clear();
        },
      ),
      trailing: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () => viewModel.cancelEditing(),
      ),
    );
  }

  void _showAddWishDialog(BuildContext context, WishListViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.star_outline,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              'Make a Wish',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
        content: TextField(
          controller: viewModel.titleController,
          autofocus: true,
          style: Theme.of(context).textTheme.bodyLarge,
          maxLines: null,
          decoration: InputDecoration(
            hintText: 'What do you wish for?',
            hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              viewModel.addWishList(value);
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              viewModel.titleController.clear();
            },
            child: Text(
              'Cancel',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          FilledButton(
            onPressed: () {
              if (viewModel.titleController.text.trim().isNotEmpty) {
                viewModel.addWishList(viewModel.titleController.text);
                Navigator.pop(context);
              }
            },
            child: Text(
              'Add Wish',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      ),
    ).then((_) => viewModel.titleController.clear());
  }
}
