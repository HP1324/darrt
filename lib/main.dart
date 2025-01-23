import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:iconsax/iconsax.dart';
import 'package:minimaltodo/app_router.dart';
import 'package:minimaltodo/services/notification_controller.dart';
import 'package:minimaltodo/view_models/general_view_model.dart';
import 'package:minimaltodo/view_models/theme_view_model.dart';
import 'package:minimaltodo/views/widgets/mini_bottom_nav_bar.dart';
import 'package:minimaltodo/services/notification_service.dart';
import 'package:minimaltodo/view_models/category_view_model.dart';
import 'package:minimaltodo/view_models/navigation_view_model.dart';
import 'package:minimaltodo/view_models/priority_view_model.dart';
import 'package:minimaltodo/view_models/task_view_model.dart';
import 'package:minimaltodo/views/pages/navigation/calendar_page.dart';
import 'package:minimaltodo/views/pages/navigation/finished_tasks_page.dart';
import 'package:minimaltodo/views/pages/navigation/categories_page.dart';
import 'package:minimaltodo/views/pages/navigation/pending_tasks_page.dart';
import 'package:minimaltodo/views/pages/search_page.dart';
import 'package:minimaltodo/views/pages/task_editor_page.dart';
import 'package:minimaltodo/views/widgets/app_drawer.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';

void main() async {
  await GetStorage.init();
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initNotifications();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => TaskViewModel()),
      ChangeNotifierProvider(create: (_) => CategoryViewModel()),
      ChangeNotifierProvider(create: (_) => PriorityViewModel()),
      ChangeNotifierProvider(create: (_) => NavigationViewModel()),
      ChangeNotifierProvider(create: (_) => GeneralViewModel()),
      ChangeNotifierProvider(create: (_) => ThemeViewModel()),
    ],
    child: const MinimalTodo(),
  ));
}

class MinimalTodo extends StatefulWidget {
  const MinimalTodo({super.key});
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  @override
  State<MinimalTodo> createState() => _MinimalTodoState();
}

class _MinimalTodoState extends State<MinimalTodo> {
  @override
  void initState() {
    super.initState();
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: NotificationController.onActionReceivedMethod,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      child: Consumer<ThemeViewModel>(builder: (context, themeVM, _) {
        return MaterialApp(
          navigatorKey: MinimalTodo.navigatorKey,
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

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
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
            const CategoriesPage(),
          ][navVM.currentDestination],
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
          onPressed: () => AppRouter.to(context, child: SearchPage()),
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
      return MiniBottomNavBar(
        children: [
          MiniBottomNavBarItem(icon: Icons.calendar_month, label: 'Calendar', i: 0),
          MiniBottomNavBarItem(icon: Icons.assignment_outlined, label: 'Pending', i: 1),
          MiniBottomNavBarItem(icon: Icons.check_circle_outline, label: 'Finished', i: 2),
          MiniBottomNavBarItem(icon: Iconsax.category, label: 'Categories', i: 3),
          MiniBottomNavBarItem(icon: Iconsax.note, label: 'Notes', i: -1),
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
      padding: const EdgeInsets.only(bottom: 16.0),
      child: FloatingActionButton(
        onPressed: () {
          AppRouter.to(context, child: TaskEditorPage(editMode: false));
        },
        tooltip: 'Add Task',
        elevation: 6,
        child: const Icon(Icons.add),
      ),
    );
  }
}


