import 'package:flutter/material.dart';
import 'package:minimaltodo/data_models/task.dart';
import 'package:minimaltodo/view_models/task_view_model.dart';
import 'package:minimaltodo/views/widgets/task_item.dart';
import 'package:provider/provider.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategory;
  String? _selectedPriority;
  bool _showFilters = false;

  final List<String> _priorities = ['Low', 'Medium', 'High', 'Urgent'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // List<Task> _filterTasks(List<Task> tasks) {
  //   if (_searchQuery.isEmpty) {
  //     return []; // Return empty list if no search query
  //   }
  //
  //   return tasks.where((task) {
  //     // Title, Priority and List search
  //     bool matchesTitle = task.title?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false;
  //     bool matchesPriority = task.priority?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false;
  //     // bool matchesList = task.category?.name?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false;
  //
  //     if (!matchesTitle && !matchesPriority && !matchesList) {
  //       return false;
  //     }
  //
  //     // list filter
  //     if (_selectedCategory != null) {
  //       if (_selectedCategory == 'General') {
  //         if (task.category?.name != 'General' && task.category != null) {
  //           return false;
  //         }
  //       } else {
  //         if (task.category?.name?.toLowerCase() != _selectedCategory?.toLowerCase()) {
  //           return false;
  //         }
  //       }
  //     }
  //
  //     // Priority filter
  //     if (_selectedPriority != null) {
  //       if (task.priority == null) {
  //         return _selectedPriority?.toLowerCase() == 'low';
  //       }
  //       return task.priority?.toLowerCase() == _selectedPriority?.toLowerCase();
  //     }
  //
  //     return true;
  //   }).toList();
  // }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search tasks...',
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: Icon(Icons.filter_list),
              onPressed: () {
                setState(() {
                  _showFilters = !_showFilters;
                });
              },
            ),
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        ),
      ),
      // body: Selector<TaskViewModel, List<Task>>(
      //   selector: (context, taskVM) => taskVM.tasks,
      //   builder: (context, tasks, _) {
      //     final textTheme = Theme.of(context).textTheme;
      //     final filteredTasks = _filterTasks(tasks);
      //     final allCategories = _searchQuery.isNotEmpty
      //         ? [
      //             'General',
      //             ...tasks
      //                 .map((task) => task.category?.name)
      //                 .where((name) => name != null && name != 'General')
      //                 .toSet()
      //           ]
      //         : ['General']; // Only include General when no search
      //
      //     return Column(
      //       children: [
      //         if (_showFilters) ...[
      //           Container(
      //             padding: const EdgeInsets.all(16),
      //             child: Column(
      //               crossAxisAlignment: CrossAxisAlignment.start,
      //               children: [
      //                 Text(
      //                   'Filter by:',
      //                   style: textTheme.labelLarge!.copyWith(fontWeight: FontWeight.bold),
      //                 ),
      //                 SizedBox(
      //                   height: MediaQuery.sizeOf(context).height * 0.1,
      //                   child: ListView(
      //                     scrollDirection: Axis.horizontal,
      //                     children: [
      //                       FilterChip(
      //                         showCheckmark: false,
      //                         label: Text(
      //                           'All Categories',
      //                           style: TextStyle(fontSize: textTheme.labelMedium!.fontSize),
      //                         ),
      //                         selected: _selectedCategory == null,
      //                         onSelected: (selected) {
      //                           setState(() {
      //                             _selectedCategory = null;
      //                           });
      //                         },
      //                       ),
      //                       ...allCategories.map(
      //                         (category) => Padding(
      //                           padding: const EdgeInsets.only(left: 6.0),
      //                           child: FilterChip(
      //                             showCheckmark: false,
      //                             label: Text(category!,
      //                                 style: TextStyle(fontSize: textTheme.labelMedium!.fontSize)),
      //                             selected: _selectedCategory == category,
      //                             onSelected: (selected) {
      //                               setState(
      //                                 () {
      //                                   _selectedCategory = selected ? category : null;
      //                                 },
      //                               );
      //                             },
      //                           ),
      //                         ),
      //                       ),
      //                     ],
      //                   ),
      //                 ),
      //                 Wrap(
      //                   spacing: 7,
      //                   children: [
      //                     FilterChip(
      //                       showCheckmark: false,
      //                       label: Text('All Priorities',style: TextStyle(fontSize: textTheme.labelMedium!.fontSize),),
      //                       selected: _selectedPriority == null,
      //                       onSelected: (selected) {
      //                         setState(() {
      //                           _selectedPriority = null;
      //                         });
      //                       },
      //                     ),
      //                     ..._priorities.map((priority) => FilterChip(
      //                       showCheckmark: false,
      //                           label: Text(priority,style: TextStyle(fontSize: textTheme.labelMedium!.fontSize),),
      //                           selected: _selectedPriority == priority,
      //                           onSelected: (selected) {
      //                             setState(() {
      //                               _selectedPriority = selected ? priority : null;
      //                             });
      //                           },
      //                         )),
      //                   ],
      //                 ),
      //               ],
      //             ),
      //           ),
      //         ],
      //         Expanded(
      //           child: _searchQuery.isEmpty
      //               ? Center(
      //                   child: Column(
      //                     mainAxisAlignment: MainAxisAlignment.center,
      //                     children: [
      //                       Icon(Icons.search, size: 64, color: Colors.grey),
      //                       SizedBox(height: 16),
      //                       Text(
      //                         'Start typing to search tasks',
      //                         style: TextStyle(
      //                           fontSize: 18,
      //                           color: Colors.grey,
      //                         ),
      //                       ),
      //                     ],
      //                   ),
      //                 )
      //               : filteredTasks.isEmpty
      //                   ? Center(
      //                       child: Column(
      //                         mainAxisAlignment: MainAxisAlignment.center,
      //                         children: [
      //                           Icon(Icons.search_off, size: 64),
      //                           SizedBox(height: 16),
      //                           Text(
      //                             'No tasks found',
      //                             style: TextStyle(fontSize: 18),
      //                           ),
      //                         ],
      //                       ),
      //                     )
      //                   : ListView.builder(
      //                       itemCount: filteredTasks.length,
      //                       itemBuilder: (context, index) {
      //                         final task = filteredTasks[index];
      //                         return TaskItem(task: task);
      //                       },
      //                     ),
      //         ),
      //       ],
      //     );
      //   },
      // ),
    );
  }
}
