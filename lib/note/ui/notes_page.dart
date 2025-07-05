import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:minimaltodo/helpers/globals.dart' as g;
import 'package:minimaltodo/helpers/mini_router.dart';
import 'package:minimaltodo/helpers/utils.dart';
import 'package:minimaltodo/note/ui/add_note_page.dart';
import 'package:minimaltodo/note/ui/folders_page.dart';
import 'package:minimaltodo/note/ui/note_item.dart';
import 'package:toastification/toastification.dart' show ToastificationType;
import 'dart:convert';

import '../models/note.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

enum DateFilterType { createdAt, updatedAt }

class _NotesPageState extends State<NotesPage> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  List<Note> _filteredNotes = [];
  String _searchQuery = '';
  DateFilterType _dateFilterType = DateFilterType.createdAt;

  @override
  void initState() {
    super.initState();
    _filteredNotes = g.noteVm.notes;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
    g.noteVm.selectedItemIds.clear();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredNotes = g.noteVm.notes;
      } else {
        _filteredNotes = g.noteVm.notes.where((note) {
          return _extractTextFromQuillContent(note.content).toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  String _extractTextFromQuillContent(String? content) {
    if (content == null || content.isEmpty) return '';

    try {
      // Parse the JSON content from Quill
      final Map<String, dynamic> delta = jsonDecode(content);
      final List<dynamic> ops = delta['ops'] ?? [];

      StringBuffer textBuffer = StringBuffer();
      for (var op in ops) {
        if (op is Map<String, dynamic> && op.containsKey('insert')) {
          final insert = op['insert'];
          if (insert is String) {
            textBuffer.write(insert);
          }
        }
      }

      return textBuffer.toString();
    } catch (e) {
      // If parsing fails, return the raw content
      return content;
    }
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _searchQuery = '';
      _searchController.clear();
      _filteredNotes = g.noteVm.notes;
    });
  }

  void _showDateFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Group Notes By',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 16),
            ListTile(
              leading: Icon(
                Icons.add_circle_outline,
                color: _dateFilterType == DateFilterType.createdAt
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
              title: Text('Created Date'),
              subtitle: Text('Group by when notes were created'),
              trailing: _dateFilterType == DateFilterType.createdAt
                  ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                  : null,
              onTap: () {
                setState(() {
                  _dateFilterType = DateFilterType.createdAt;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.update,
                color: _dateFilterType == DateFilterType.updatedAt
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
              title: Text('Updated Date'),
              subtitle: Text('Group by when notes were last modified'),
              trailing: _dateFilterType == DateFilterType.updatedAt
                  ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                  : null,
              onTap: () {
                setState(() {
                  _dateFilterType = DateFilterType.updatedAt;
                });
                Navigator.pop(context);
              },
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Map<String, List<Note>> _groupNotesByDate(List<Note> notes) {
    Map<String, List<Note>> groupedNotes = {};

    for (var note in notes) {
      final dateTime = _dateFilterType == DateFilterType.createdAt
          ? note.createdAt
          : note.updatedAt;

      if (dateTime == null) continue;

      final dateKey = formatDateNoJm(dateTime, 'EEE, dd MMM, yyyy');
      if (groupedNotes[dateKey] == null) {
        groupedNotes[dateKey] = [];
      }
      groupedNotes[dateKey]!.add(note);
    }

    // Sort the map by actual date (most recent first)
    var sortedEntries = groupedNotes.entries.toList()
      ..sort((a, b) {
        // Get the first note from each group to compare their actual dates
        final noteA = groupedNotes[a.key]!.first;
        final noteB = groupedNotes[b.key]!.first;

        final dateA = _dateFilterType == DateFilterType.createdAt
            ? noteA.createdAt
            : noteA.updatedAt;
        final dateB = _dateFilterType == DateFilterType.createdAt
            ? noteB.createdAt
            : noteB.updatedAt;

        // Compare actual DateTime objects (most recent first)
        return dateB?.compareTo(dateA!) as int;
      });

    return Map.fromEntries(sortedEntries);
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      autofocus: true,
      decoration: InputDecoration(
        hintText: 'Search notes...',
        border: InputBorder.none,
        hintStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 16,
      ),
    );
  }

  Widget _buildAppBarTitle() {
    if (_isSearching) {
      return _buildSearchBar();
    }
    return Text('Notes');
  }

  List<Widget> _buildAppBarActions() {
    final ids = g.noteVm.selectedItemIds;

    if (_isSearching) {
      return [
        IconButton(
          onPressed: _stopSearch,
          icon: Icon(Icons.close),
          tooltip: 'Close search',
        ),
      ];
    }

    return [
      if (ids.isNotEmpty) ...[
        IconButton(
          onPressed: () => g.noteVm.clearSelection(),
          icon: Icon(Icons.cancel),
          tooltip: 'Clear selection',
        ),
        IconButton(
          onPressed: () async {
            var message = '';
            await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Delete Notes'),
                content: Text(
                  'Delete ${ids.length > 1 ? '${ids.length} notes' : '1 note'}?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      message = g.noteVm.deleteMultipleItems();
                      Navigator.pop(context);
                    },
                    child: const Text('Delete'),
                  ),
                ],
              ),
            );
            if (context.mounted) {
              showToast(
                context,
                type: ToastificationType.success,
                description: message,
              );
            }
          },
          icon: Icon(Icons.delete),
          tooltip: 'Delete selected notes',
        ),
      ],
      IconButton(
        onPressed: _startSearch,
        icon: Icon(Icons.search),
        tooltip: 'Search notes',
      ),
      IconButton(
        onPressed: _showDateFilterBottomSheet,
        icon: Icon(Icons.filter_list),
        tooltip: 'Filter by date',
      ),
      IconButton(
        onPressed: () {
          g.noteVm.clearSelection();
          MiniRouter.to(context, FoldersPage());
        },
        icon: Icon(Icons.folder_open),
        tooltip: 'Open folders',
      ),
    ];
  }

  Widget _buildSearchResults() {
    if (_searchQuery.isEmpty) {
      return SliverToBoxAdapter(child: SizedBox.shrink());
    }

    if (_filteredNotes.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 64,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
              ),
              SizedBox(height: 16),
              Text(
                'No notes found',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Try searching with different keywords',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(12),
      sliver: SliverMasonryGrid.count(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childCount: _filteredNotes.length,
        itemBuilder: (context, index) {
          final note = _filteredNotes[index];
          return NoteItem(note: note);
        },
      ),
    );
  }

  Widget _buildGroupedNotes() {
    if (_isSearching) {
      return _buildSearchResults();
    }

    final groupedNotes = _groupNotesByDate(_filteredNotes);

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final entries = groupedNotes.entries.toList();
          final entry = entries[index];
          final dateLabel = entry.key;
          final notesForDate = entry.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  dateLabel,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              // Notes grid for this date
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: StaggeredGrid.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  children: notesForDate.map((note) {
                    return NoteItem(note: note);
                  }).toList(),
                ),
              ),
            ],
          );
        },
        childCount: groupedNotes.length,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListenableBuilder(
        listenable: g.noteVm,
        builder: (context, child) {
          // Update filtered notes when noteVm changes
          if (!_isSearching || _searchQuery.isEmpty) {
            _filteredNotes = g.noteVm.notes;
          }

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                leading: BackButton(),
                title: _buildAppBarTitle(),
                pinned: true,
                actions: _buildAppBarActions(),
              ),

              if (_isSearching) ...[
                _buildSearchResults(),
              ] else ...[
                // Build grouped sections
                ...(_groupNotesByDate(_filteredNotes).entries.map((entry) {
                  final dateLabel = entry.key;
                  final notesForDate = entry.value;

                  return SliverMainAxisGroup(
                    slivers: [
                      // Date header
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Text(
                            dateLabel,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                      // Notes grid for this date
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        sliver: SliverMasonryGrid.count(
                          crossAxisCount: 2,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          childCount: notesForDate.length,
                          itemBuilder: (context, index) {
                            final note = notesForDate[index];
                            return NoteItem(note: note);
                          },
                        ),
                      ),
                    ],
                  );
                }).toList()),
              ],

              // Add some bottom padding
              SliverToBoxAdapter(
                child: SizedBox(height: 100), // Space for FAB
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          MiniRouter.to(context, AddNotePage(edit: false));
        },
        shape: StadiumBorder(),
        label: Row(
          children: [
            Icon(Icons.add),
            const SizedBox(width: 8),
            Text('Add Note'),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
