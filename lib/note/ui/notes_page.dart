import 'package:darrt/app/extensions/extensions.dart';
import 'package:darrt/app/services/toast_service.dart';
import 'package:darrt/helpers/globals.dart' as g;
import 'package:darrt/helpers/mini_router.dart';
import 'package:darrt/note/search/note_search_page.dart';
import 'package:darrt/note/ui/add_note_page.dart';
import 'package:darrt/note/ui/folders_page.dart';
import 'package:darrt/note/ui/note_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum NoteFilter { createdAt, updatedAt }

class NoteFilterNotifier extends Notifier<NoteFilter> {
  @override
  NoteFilter build() => NoteFilter.createdAt;

  void changeFilter(NoteFilter filter) {
    state = filter;
  }
}

final noteFilterProvider = NotifierProvider<NoteFilterNotifier, NoteFilter>(
  NoteFilterNotifier.new,
);

class NotesPage extends ConsumerStatefulWidget {
  const NotesPage({super.key});

  @override
  ConsumerState<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends ConsumerState<NotesPage> {
  final scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final noteFilter = ref.watch(noteFilterProvider);

    return Scaffold(
      appBar: _NotesPageAppbar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: ListenableBuilder(
          listenable: g.noteVm,
          builder: (context, child) {
            final textTheme = TextTheme.of(context);
            final scheme = ColorScheme.of(context);
            final notes = g.noteVm.notes;

            if (notes.isEmpty) return _EmptyNotesIndicator();

            final noteGroups = notes.groupByDate(noteFilter);

            return CustomScrollView(
              controller: scrollController,
              slivers: [
                for (var group in noteGroups.entries) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        group.key,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: scheme.primary,
                        ),
                      ),
                    ),
                  ),
                  SliverGrid.builder(
                    key: ValueKey(group.key),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      mainAxisExtent: MediaQuery.sizeOf(context).height * 0.16
                    ),
                    itemCount: group.value.length,
                    itemBuilder: (context, index) {
                      final note = group.value[index];
                      return NoteItem(note: note);
                    },
                  ),
                ],
                SliverToBoxAdapter(child: const SizedBox(height: 100)),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => MiniRouter.to(context, const AddNotePage(edit: false)),
        tooltip: 'Add note',
        elevation: 0,
        label: Text('Write Note'),
        shape: StadiumBorder(),
        icon: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class _NotesPageAppbar extends ConsumerWidget implements PreferredSizeWidget {
  const _NotesPageAppbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListenableBuilder(
      listenable: g.noteVm,
      builder: (context, child) {
        final ids = g.noteVm.selectedItemIds;
        return AppBar(
          leading: BackButton(),
          titleSpacing: 0,
          title: Text('Notes'),
          actions: [
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
                            if (context.mounted) {
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
              onPressed: () => MiniRouter.to(context, const NoteSearchPage()),
              tooltip: 'Search Notes',
              icon: Icon(Icons.search),
            ),
            IconButton(
              onPressed: () => _showNoteFilterBottomSheet(context),
              tooltip: 'Filter',
              icon: Icon(Icons.filter_list),
            ),
            IconButton(
              onPressed: () => MiniRouter.to(context, const FoldersPage()),
              tooltip: 'Folders',
              icon: Icon(Icons.folder_open_outlined),
            ),
          ],
        );
      },
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  void _showNoteFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (context) {
        return _NoteFilterBottomSheet();
      },
    );
  }
}

class _NoteFilterBottomSheet extends ConsumerWidget {
  const _NoteFilterBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = context.colorScheme;

    final textTheme = context.textTheme;

    final noteFilter = ref.watch(noteFilterProvider);

    return Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: scheme.onSurface.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Group Notes By',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16),
          ListTile(
            leading: Icon(
              Icons.add_circle_outline,
              color: noteFilter == NoteFilter.createdAt ? scheme.primary : null,
            ),
            title: Text('Created Date'),
            subtitle: Text('Group by when notes were created'),
            trailing: noteFilter == NoteFilter.createdAt
                ? Icon(
                    Icons.check,
                    color: Theme.of(context).colorScheme.primary,
                  )
                : null,
            onTap: () {
              ref
                  .read(noteFilterProvider.notifier)
                  .changeFilter(NoteFilter.createdAt);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(
              Icons.update,
              color: noteFilter == NoteFilter.updatedAt ? scheme.primary : null,
            ),
            title: Text('Updated Date'),
            subtitle: Text('Group by when notes were last modified'),
            trailing: noteFilter == NoteFilter.updatedAt
                ? Icon(
                    Icons.check,
                    color: Theme.of(context).colorScheme.primary,
                  )
                : null,
            onTap: () {
              ref
                  .read(noteFilterProvider.notifier)
                  .changeFilter(NoteFilter.updatedAt);
              Navigator.pop(context);
            },
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _EmptyNotesIndicator extends StatelessWidget {
  const _EmptyNotesIndicator();

  @override
  Widget build(BuildContext context) {
    return Center(
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
    );
  }
}
