import 'package:flutter/material.dart';
import 'package:minimaltodo/category/category_model.dart';
import 'package:minimaltodo/helpers/object_box.dart';
import 'package:minimaltodo/task/task.dart';
import 'package:minimaltodo/task/ui/task_item.dart';
import 'package:provider/provider.dart';

// Controller class to handle all state and business logic
class SearchController extends ChangeNotifier {
  String _searchQuery = '';
  CategoryModel? _selectedCategory;
  String? _selectedPriority;
  bool _showFilters = false;
  List<Task> _allTasks = [];
  List<CategoryModel> _categories = [];
  final List<String> priorities = ['Low', 'Medium', 'High', 'Urgent'];

  SearchController() {
    _loadData();
  }

  // Getters
  String get searchQuery => _searchQuery;
  CategoryModel? get selectedCategory => _selectedCategory;
  String? get selectedPriority => _selectedPriority;
  bool get showFilters => _showFilters;
  List<CategoryModel> get categories => _categories;

  // Computed property for filtered tasks
  List<Task> get filteredTasks {
    if (_searchQuery.isEmpty) return [];

    // Get tasks based on category selection
    List<Task> baseTasks =_selectedCategory != null ? _selectedCategory!.tasks.toList() : _allTasks;

    // Apply search and priority filters
    return baseTasks.where((task) {
      // Search query filter
      bool matchesTitle = task.title.toLowerCase().contains(_searchQuery.toLowerCase());
      bool matchesPriority =task.priority.toLowerCase().contains(_searchQuery.toLowerCase());

      if (!matchesTitle && !matchesPriority) return false;

      // Priority filter
      if (_selectedPriority != null) {
        return task.priority.toLowerCase() == _selectedPriority?.toLowerCase();
      }

      return true;
    }).toList();
  }

  // Load all data
  void _loadData() {
    _allTasks = ObjectBox.store.box<Task>().getAll();
    _categories = ObjectBox.store.box<CategoryModel>().getAll();
    notifyListeners();
  }

  // Update search query
  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Toggle filters visibility
  void toggleFilters() {
    _showFilters = !_showFilters;
    notifyListeners();
  }

  // Update category filter
  void setCategory(CategoryModel? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // Update priority filter
  void setPriority(String? priority) {
    _selectedPriority = priority;
    notifyListeners();
  }
}

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SearchController(),
      child: const _SearchPageContent(),
    );
  }
}

class _SearchPageContent extends StatefulWidget {
  const _SearchPageContent();

  @override
  State<_SearchPageContent> createState() => _SearchPageContentState();
}

class _SearchPageContentState extends State<_SearchPageContent> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Consumer<SearchController>(
          builder: (context, controller, _) => TextField(
            controller: _searchController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Search tasks...',
              border: InputBorder.none,
              suffixIcon: IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: controller.toggleFilters,
              ),
            ),
            onChanged: controller.updateSearchQuery,
          ),
        ),
      ),
      body: Column(
        children: [
          // Filters Section
          Selector<SearchController, bool>(
            selector: (_, controller) => controller.showFilters,
            builder: (context, showFilters, _) {
              if (!showFilters) return const SizedBox.shrink();
              return const _FiltersSection();
            },
          ),
          // Tasks List
          Expanded(
            child: Consumer<SearchController>(
              builder: (context, controller, _) {
                final tasks = controller.filteredTasks;
                final searchQuery = controller.searchQuery;

                if (searchQuery.isEmpty) {
                  return const _EmptySearchState();
                }

                if (tasks.isEmpty) {
                  return const _NoResultsState();
                }

                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) => TaskItem(task: tasks[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Filter section widget
class _FiltersSection extends StatelessWidget {
  const _FiltersSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter by:',
            style: Theme.of(context).textTheme.labelLarge!.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.1,
            child: _CategoryFilters(),
          ),
          _PriorityFilters(),
        ],
      ),
    );
  }
}

// Category filters widget
class _CategoryFilters extends StatelessWidget {
  const _CategoryFilters();

  @override
  Widget build(BuildContext context) {
    return Selector<SearchController, List<CategoryModel>>(
      selector: (_, controller) => controller.categories,
      builder: (context, categories, _) {
        return ListView(
          scrollDirection: Axis.horizontal,
          children: [
            _buildCategoryChip(context, null, 'All Categories'),
            ...categories.map(
                  (category) => Padding(
                padding: const EdgeInsets.only(left: 6.0),
                child: _buildCategoryChip(context, category, category.name),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategoryChip(BuildContext context, CategoryModel? category, String label) {
    return Selector<SearchController, CategoryModel?>(
      selector: (_, controller) => controller.selectedCategory,
      builder: (context, selectedCategory, _) {
        final controller = context.read<SearchController>();
        final isSelected =
        category == null ? selectedCategory == null : selectedCategory?.id == category.id;

        return FilterChip(
          showCheckmark: false,
          label: Text(
            label,
            style: TextStyle(fontSize: Theme.of(context).textTheme.labelMedium!.fontSize),
          ),
          selected: isSelected,
          onSelected: (_) => controller.setCategory(isSelected ? null : category),
        );
      },
    );
  }
}

// Priority filters widget
class _PriorityFilters extends StatelessWidget {
  const _PriorityFilters();

  @override
  Widget build(BuildContext context) {
    final controller = context.read<SearchController>();

    return Selector<SearchController, String?>(
      selector: (_, controller) => controller.selectedPriority,
      builder: (context, selectedPriority, _) {
        return Wrap(
          spacing: 7,
          children: [
            FilterChip(
              showCheckmark: false,
              label: Text(
                'All Priorities',
                style: TextStyle(fontSize: Theme.of(context).textTheme.labelMedium!.fontSize),
              ),
              selected: selectedPriority == null,
              onSelected: (_) => controller.setPriority(null),
            ),
            ...controller.priorities.map((priority) => FilterChip(
              showCheckmark: false,
              label: Text(
                priority,
                style: TextStyle(fontSize: Theme.of(context).textTheme.labelMedium!.fontSize),
              ),
              selected: selectedPriority == priority,
              onSelected: (selected) => controller.setPriority(selected ? priority : null),
            )),
          ],
        );
      },
    );
  }
}

// Empty search state widget
class _EmptySearchState extends StatelessWidget {
  const _EmptySearchState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'Start typing to search tasks',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

// No results state widget
class _NoResultsState extends StatelessWidget {
  const _NoResultsState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 64),
          const SizedBox(height: 16),
          Text('No tasks found', style: TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}
