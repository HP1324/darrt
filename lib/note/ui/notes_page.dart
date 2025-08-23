import 'package:darrt/app/ads/my_banner_ad_widget.dart';
import 'package:darrt/app/ads/timed_banner_ad_widget.dart';
import 'package:darrt/app/extensions/extensions.dart';
import 'package:darrt/app/services/toast_service.dart';
import 'package:darrt/helpers/globals.dart' as g;
import 'package:darrt/helpers/mini_router.dart';
import 'package:darrt/helpers/utils.dart';
import 'package:darrt/note/search/note_search_page.dart';
import 'package:darrt/note/ui/add_note_page.dart';
import 'package:darrt/note/ui/folders_page.dart';
import 'package:darrt/note/ui/note_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

enum DateFilterType { createdAt, updatedAt }

class _NotesPageState extends State<NotesPage> {
  DateFilterType _dateFilterType = DateFilterType.createdAt;

  @override
  void dispose() {
    super.dispose();
    g.noteVm.selectedItemIds.clear();
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
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.3),
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
                  ? Icon(
                      Icons.check,
                      color: Theme.of(context).colorScheme.primary,
                    )
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
                  ? Icon(
                      Icons.check,
                      color: Theme.of(context).colorScheme.primary,
                    )
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

  Widget _buildAppBarTitle() {
    return Text(
      'Notes',
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  List<Widget> _buildAppBarActions() {
    final ids = g.noteVm.selectedItemIds;

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
              builder: (innerContext) => AlertDialog(
                title: const Text('Delete Notes'),
                content: Text(
                  'Delete ${ids.length > 1 ? '${ids.length} notes' : '1 note'}?',
                ),
                actions: [
                  FilledButton(
                    onPressed: () {
                      message = g.noteVm.deleteMultipleItems();
                      Navigator.pop(context);
                      if (mounted) {
                        showSuccessToast(context, message);
                      }
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(
                        ColorScheme.of(context).error,
                      ),
                    ),
                    child: const Text('Delete'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            );
          },
          icon: Icon(Icons.delete),
          tooltip: 'Delete selected notes',
        ),
      ],
      IconButton(
        onPressed: () => MiniRouter.to(context, NoteSearchPage()),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: getSurfaceColor(context),
      body: ListenableBuilder(
        listenable: g.noteVm,
        builder: (context, child) {
          final notes = g.noteVm.notes;

          final scheme = ColorScheme.of(context);
          final textTheme = TextTheme.of(context);
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: getSurfaceColor(context),
                leading: BackButton(),
                titleSpacing: 0,
                title: _buildAppBarTitle(),
                pinned: true,
                actions: _buildAppBarActions(),
              ),

              if (notes.isEmpty) ...[
                _EmptyNotesIndicator(),
              ] else ...[
                ...(notes.groupByDate(_dateFilterType).entries.expand((
                  entry,
                ) {
                  final dateLabel = entry.key;
                  final notesForDate = entry.value;

                  return [
                    SliverList(
                      delegate: SliverChildListDelegate.fixed(
                        [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                            child: Text(
                              dateLabel,
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: scheme.primary,
                              ),
                            ),
                          ),
                        ],
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
                  ];
                }).toList()),
              ],
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
            Text('Write note'),
          ],
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: ListenableBuilder(
        listenable: g.adsController,
        builder: (context, child) {
          return TimedBannerAdWidget(
            showFor: Duration(seconds: 50),
            hideFor: Duration(seconds: 15),
            adInitializer: () => g.adsController.initializeNotesPageBannerAd(),
            childBuilder: () {
              if (g.adsController.isNotesPageBannerAdLoaded) {
                return MyBannerAdWidget(
                  bannerAd: g.adsController.notesPageBannerAd,
                );
              }
              return const SizedBox.shrink();
            },
          );
        },
      ),
    );
  }
}

class _EmptyNotesIndicator extends StatelessWidget {
  const _EmptyNotesIndicator();

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primaryContainer.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.note_add_outlined,
                size: 60,
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.7),
              ),
            ),
            SizedBox(height: 24),
            Text(
              'No Notes Yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Start capturing your thoughts and ideas',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
