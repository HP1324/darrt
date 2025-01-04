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
                          isAutoFocus: false,
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
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 0.85,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final list = filteredLists[index];
                          return ListItem(
                            list: list,
                            // onEdit: () {
                            //   final textController = TextEditingController(text: list.name);
                            //   showModalBottomSheet(
                            //     context: context,
                            //     isScrollControlled: true,
                            //     backgroundColor: Colors.transparent,
                            //     builder: (context) => Container(
                            //       padding: EdgeInsets.only(
                            //         bottom: MediaQuery.of(context).viewInsets.bottom,
                            //       ),
                            //       decoration: const BoxDecoration(
                            //         color: Colors.white,
                            //         borderRadius: BorderRadius.vertical(
                            //           top: Radius.circular(20),
                            //         ),
                            //       ),
                            //       child: Padding(
                            //         padding: const EdgeInsets.all(20),
                            //         child: Column(
                            //           mainAxisSize: MainAxisSize.min,
                            //           crossAxisAlignment: CrossAxisAlignment.start,
                            //           children: [
                            //             const Text(
                            //               'Edit List Name',
                            //               style: TextStyle(
                            //                 fontSize: 20,
                            //                 fontWeight: FontWeight.bold,
                            //                 color: AppTheme.primary,
                            //               ),
                            //             ),
                            //             const SizedBox(height: 20),
                            //             TextField(
                            //               controller: textController,
                            //               autofocus: true,
                            //               decoration: InputDecoration(
                            //                 hintText: 'Enter list name',
                            //                 filled: true,
                            //                 fillColor: AppTheme.background50,
                            //                 border: OutlineInputBorder(
                            //                   borderRadius: BorderRadius.circular(10),
                            //                   borderSide: BorderSide.none,
                            //                 ),
                            //               ),
                            //             ),
                            //             const SizedBox(height: 20),
                            //             Row(
                            //               mainAxisAlignment: MainAxisAlignment.end,
                            //               children: [
                            //                 TextButton(
                            //                   onPressed: () => Navigator.pop(context),
                            //                   child: const Text('Cancel'),
                            //                 ),
                            //                 const SizedBox(width: 10),
                            //                 ElevatedButton(
                            //                   onPressed: () {
                            //                     if (textController.text.trim().isEmpty) {
                            //                       showToast(
                            //                         title: 'List name cannot be empty',
                            //                         type: ToastificationType.error,
                            //                       );
                            //                       return;
                            //                     }
                            //                     listVM
                            //                         .editList(list, textController.text)
                            //                         .then((success) {
                            //                       if (success) {
                            //                         showToast(title: 'List name updated');
                            //                         Navigator.pop(context);
                            //                       } else {
                            //                         showToast(
                            //                           title: 'Failed to update list name',
                            //                           type: ToastificationType.error,
                            //                         );
                            //                       }
                            //                     });
                            //                   },
                            //                   style: ElevatedButton.styleFrom(
                            //                     backgroundColor: AppTheme.primary,
                            //                     foregroundColor: Colors.white,
                            //                   ),
                            //                   child: const Text('Save'),
                            //                 ),
                            //               ],
                            //             ),
                            //           ],
                            //         ),
                            //       ),
                            //     ),
                            //   );
                            // },
                            // onDelete: () {
                            //   showDialog(
                            //     context: context,
                            //     builder: (context) => AlertDialog(
                            //       title: Text('Delete List'),
                            //       content: Text(
                            //         'Are you sure you want to delete "${list.name}"? All tasks in this list will be moved to General list.',
                            //       ),
                            //       actions: [
                            //         TextButton(
                            //           onPressed: () => Navigator.pop(context),
                            //           child: Text('Cancel'),
                            //         ),
                            //         TextButton(
                            //           onPressed: () {
                            //             final taskVM =
                            //                 Provider.of<TaskViewModel>(context, listen: false);
                            //             listVM.deleteList(list, taskVM).then((deleted) {
                            //               if (deleted) {
                            //                 showToast(
                            //                     title: 'List deleted',
                            //                     description:
                            //                         'All tasks have been moved to General list');
                            //               } else {
                            //                 showToast(
                            //                     title: 'Failed to delete list',
                            //                     description: 'Please try again');
                            //               }
                            //             });
                            //             Navigator.pop(context);
                            //           },
                            //           child: Text(
                            //             'Delete',
                            //             style: TextStyle(
                            //               color: AppTheme.error,
                            //             ),
                            //           ),
                            //         ),
                            //       ],
                            //     ),
                            //   );
                            // },
                          );
                        },
                        childCount: filteredLists.length,
                      ),
                    ),
            ),
            const SliverPadding(padding: EdgeInsets.only(bottom: 16)),
          ],
        );
      },
    );
  }
}
