import 'package:flutter/material.dart';
import 'package:minimaltodo/global_utils.dart';
import 'package:minimaltodo/services/list_service.dart';
import 'package:minimaltodo/theme/app_theme.dart';
import 'package:minimaltodo/view_models/list_view_model.dart';
import 'package:minimaltodo/view_models/task_view_model.dart';
import 'package:minimaltodo/views/pages/new_list_page.dart';
import 'package:minimaltodo/views/pages/tasks_for_list_page.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import 'package:toastification/toastification.dart';
import 'package:minimaltodo/views/helper_widgets/custom_text_field.dart';
import 'package:minimaltodo/views/widgets/list_item.dart';

class ListsPage extends StatefulWidget {
  const ListsPage({super.key});

  @override
  State<ListsPage> createState() => _ListsPageState();
}

class _ListsPageState extends State<ListsPage> {
  bool _showSearch = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ListViewModel, TaskViewModel>(
      builder: (context, listVM, taskVM, _) {
        final lists = listVM.lists;

        // Filter lists based on search query
        final filteredLists = lists.where((list) {
          if (_searchQuery.isEmpty) return true;
          return list.name?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false;
        }).toList();

        return CustomScrollView(
          controller: listVM.listScrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'All Lists',
                          style: TextStyle(
                            fontSize: Theme.of(context).textTheme.headlineSmall!.fontSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _showSearch = !_showSearch;
                                  if (!_showSearch) {
                                    _searchController.clear();
                                    _searchQuery = '';
                                  }
                                });
                              },
                              icon: Icon(
                                _showSearch ? Icons.close : Iconsax.search_normal,
                                color: _showSearch ? AppTheme.error : AppTheme.primary,
                              ),
                              style: IconButton.styleFrom(
                                backgroundColor: AppTheme.background50,
                                foregroundColor: AppTheme.primary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Add List Button
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  PageTransition(
                                    type: PageTransitionType.fade,
                                    child: NewListPage(editMode: false),
                                  ),
                                );
                              },
                              icon: const Icon(Iconsax.add),
                              style: IconButton.styleFrom(
                                backgroundColor: AppTheme.background50,
                                foregroundColor: AppTheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Search TextField
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: _showSearch ? 60 : 0,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: _showSearch ? 1.0 : 0.0,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: CustomTextField(
                          controller: _searchController,
                          isMaxLinesNull: false,
                          autoFocus: false,
                          hintText: 'Search lists...',
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value ?? '';
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              sliver: filteredLists.isEmpty
                  ? SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Iconsax.search_normal,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No lists found',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 6,
                        crossAxisSpacing: 8,
                        childAspectRatio: 0.95,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final list = filteredLists[index];
                          return ListItem(list: list);
                        },
                        childCount: filteredLists.length,
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}
