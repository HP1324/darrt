import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_storage/get_storage.dart';
import 'package:iconsax/iconsax.dart';
import 'package:minimaltodo/view_models/general_view_model.dart';
import 'package:minimaltodo/view_models/theme_view_model.dart';
import 'package:page_transition/page_transition.dart';
import 'package:minimaltodo/services/notification_service.dart';
import 'package:minimaltodo/view_models/list_view_model.dart';
import 'package:minimaltodo/view_models/navigation_view_model.dart';
import 'package:minimaltodo/view_models/priority_view_model.dart';
import 'package:minimaltodo/view_models/task_view_model.dart';
import 'package:minimaltodo/views/pages/navigation/calendar_page.dart';
import 'package:minimaltodo/views/pages/navigation/finished_tasks_page.dart';
import 'package:minimaltodo/views/pages/navigation/lists_page.dart';
import 'package:minimaltodo/views/pages/navigation/pending_tasks_page.dart';
import 'package:minimaltodo/views/pages/search_page.dart';
import 'package:minimaltodo/views/pages/task_editor_page.dart';
import 'package:minimaltodo/views/widgets/app_drawer.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';

void main() async {
  await GetStorage.init();
  await NotificationService.initNotifications();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => TaskViewModel()),
      ChangeNotifierProvider(create: (_) => ListViewModel()),
      ChangeNotifierProvider(create: (_) => PriorityViewModel()),
      ChangeNotifierProvider(create: (_) => NavigationViewModel()),
      ChangeNotifierProvider(create: (_) => GeneralViewModel()),
      ChangeNotifierProvider(create: (_) => ThemeViewModel()),
    ],
    child: const SimpleTodo(),
  ));
}

class SimpleTodo extends StatefulWidget {
  const SimpleTodo({super.key});
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  State<SimpleTodo> createState() => _SimpleTodoState();
}

class _SimpleTodoState extends State<SimpleTodo> {
  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      child: Consumer<ThemeViewModel>(builder: (context, themeVM, _) {
        return MaterialApp(
          navigatorKey: SimpleTodo.navigatorKey,
          theme: FlexColorScheme.light(colors: themeVM.selectedScheme).toTheme,
          darkTheme: FlexColorScheme.dark(
                  colors: themeVM.selectedScheme.toDark(),
                  surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
                  blendLevel: 12, // Reduces contrast by blending colors more subtly
                  appBarStyle: FlexAppBarStyle.background,
                  darkIsTrueBlack: false, // Prevents pure black
                  scaffoldBackground: Color(0xff131313))
              .toTheme,
          themeMode: themeVM.themeMode,
          debugShowCheckedModeBanner: false,
          title: 'MinimalTodo',
          home: const Home(),
        );
      }),
    );
  }
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Consumer<NavigationViewModel>(builder: (context, navVM, _) {
        return Scaffold(
          appBar: _AppBar(),
          drawer: const AppDrawer(),
          body: [
            const CalendarPage(),
            const PendingTasksPage(),
            const FinishedTasksPage(),
            const ListsPage(),
          ][navVM.selectedDestination],
          floatingActionButton: _FloatingActionButtonWidget(),
          bottomNavigationBar: _BottomNavBarWidget(),
        );
      }),
    );
  }
}

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  const _AppBar({super.key});
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
  @override
  AppBar build(BuildContext context) {
    return AppBar(
      elevation: 0,
      title: Text('MinimalTodo', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(Icons.search),
          onPressed: () {
            Navigator.push(
              context,
              PageTransition(type: PageTransitionType.fade, child: const SearchPage()),
            );
          },
        ),
        Consumer<ThemeViewModel>(builder: (context, themeVM, _) {
          return Transform.scale(
            scale: 0.6,
            child: Switch(
              thumbIcon: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Icon(Icons.dark_mode);
                }
                return Icon(Icons.light_mode);
              }),
              inactiveThumbColor: Theme.of(context).colorScheme.onSurface.withAlpha(140),
              activeColor: Theme.of(context).colorScheme.primary,
              value: themeVM.isDarkMode,
              onChanged: (newValue) {
                themeVM.toggleDarkMode(newValue);
              },
            ),
          );
        }),
      ],
    );
  }
}

class _BottomNavBarWidget extends StatelessWidget {
  const _BottomNavBarWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationViewModel>(builder: (context, navVM, _) {
      return NavigationBar(
        elevation: 5,
        backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(15),
        selectedIndex: navVM.selectedDestination,
        onDestinationSelected: (selected) {
          if (selected == 4) {
            Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: Scaffold()));
          } else {
            navVM.onDestinationSelected(selected);
          }
        },
        indicatorColor: Theme.of(context).colorScheme.primary.withAlpha(220),
        height: MediaQuery.sizeOf(context).height * 0.115,
        destinations: [
          _BottomNavBarItem(icon: Iconsax.calendar_tick, label: 'Calendar'),
          _BottomNavBarItem(icon: Icons.pending_actions, label: 'Pending'),
          _BottomNavBarItem(icon: Iconsax.verify, label: 'Finished'),
          _BottomNavBarItem(icon: Iconsax.element_3, label: 'Lists'),
          _BottomNavBarItem(icon: FontAwesomeIcons.noteSticky, label: 'Notes'),
        ],
      );
    });
  }
}

class _FloatingActionButtonWidget extends StatelessWidget {
  const _FloatingActionButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            PageTransition(
              type: PageTransitionType.fade,
              child: TaskEditorPage(editMode: false),
            ),
          );
        },
        tooltip: 'Add Task',
        elevation: 6,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _BottomNavBarItem extends StatelessWidget {
  const _BottomNavBarItem({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    if (label == 'Notes') {
      return NavigationDestination(icon: Icon(icon), selectedIcon: Icon(icon), label: label);
    }
    if (label == 'Pending') {
      return Consumer<TaskViewModel>(
        builder: (context, taskVM, child) {
          final pendingCount = taskVM.tasks.where((task) => !task.isDone!).length;
          final colorScheme = Theme.of(context).colorScheme;

          return NavigationDestination(
            icon: Badge(
              isLabelVisible: pendingCount > 0,
              // Use secondary container for better theme adaptation
              backgroundColor: colorScheme.secondaryContainer,
              offset: const Offset(8, -4),
              largeSize: 20,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              label: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(
                    scale: animation,
                    child: child,
                  );
                },
                child: Text(
                  pendingCount.toString(),
                  key: ValueKey<int>(pendingCount),
                  style: TextStyle(
                    color: colorScheme.onSecondaryContainer,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              child: Icon(icon),
            ),
            label: label,
            selectedIcon: Badge(
              isLabelVisible: pendingCount > 0,
              // When selected, use primary container for better distinction
              backgroundColor: colorScheme.primaryContainer,
              offset: const Offset(8, -4),
              largeSize: 20,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              label: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: Text(
                  pendingCount.toString(),
                  key: ValueKey<int>(pendingCount),
                  style: TextStyle(
                    color: colorScheme.onPrimaryContainer,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              child: Icon(icon),
            ),
          );
        },
      );
    }

    return NavigationDestination(icon: Icon(icon), selectedIcon: Icon(icon), label: label);
  }
}
