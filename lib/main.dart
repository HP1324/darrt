import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:iconsax/iconsax.dart';
import 'package:page_transition/page_transition.dart';
import 'package:minimaltodo/services/notification_service.dart';
import 'package:minimaltodo/theme/app_theme.dart';
import 'package:minimaltodo/view_models/list_view_model.dart';
import 'package:minimaltodo/view_models/duedate_view_model.dart';
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
  GetStorage.init();
  WidgetsFlutterBinding.ensureInitialized();
  NotificationService.initNotifications();
  runApp(const SimpleTodo());
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskViewModel()),
        ChangeNotifierProvider(create: (_) => ListViewModel()),
        ChangeNotifierProvider(create: (_) => PriorityViewModel()),
        ChangeNotifierProvider(create: (_) => NavigationViewModel()),
      ],
      child: ToastificationWrapper(
        child: MaterialApp(
          navigatorKey: SimpleTodo.navigatorKey,
          theme: AppTheme.lightMode,
          debugShowCheckedModeBanner: false,
          title: 'MinimalTodo',
          home: const Home(),
        ),
      ),
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
          appBar: AppBar(
            backgroundColor: AppTheme.primary,
            elevation: 0,
            title:const Text(
              'MinimalTodo',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.background50,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.search, color: AppTheme.background50),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SearchPage()),
                  );
                },
              ),
            ],
          ),
          drawer: const AppDrawer(),
          body: [
            const CalendarPage(),
            const PendingTasksPage(),
            const FinishedTasksPage(),
            const ListsPage()
          ][navVM.selectedDestination],
          floatingActionButton: _FloatingActionButtonWidget(context: context),
          bottomNavigationBar: _BottomNavBarWidget(navVM: navVM,),
        );
      }),
    );
  }
}

class _BottomNavBarWidget extends StatelessWidget {
  const _BottomNavBarWidget({
    required this.navVM,
  });
  final NavigationViewModel navVM;
  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: navVM.selectedDestination,
      onDestinationSelected: navVM.onDestinationSelected,
      height: MediaQuery.sizeOf(context).height * 0.095,
      destinations: const [
        _BottomNavBarItem(icon: Iconsax.calendar_tick, label: 'Calendar'),
        _BottomNavBarItem(icon: Icons.pending_actions, label: 'Pending'),
        _BottomNavBarItem(icon: Iconsax.verify, label: 'Finished'),
        _BottomNavBarItem(icon: Iconsax.element_3, label: 'Lists'),
      ],
    );
  }
}

class _FloatingActionButtonWidget extends StatelessWidget {
  const _FloatingActionButtonWidget({
    required this.context,
  });

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            PageTransition(
              type: PageTransitionType.fade,
              child: TaskEditorPage(
                editMode: false,
              ),
            ),
          );
        },
        tooltip: 'Add Task',
        elevation: 6,
        child: const Icon(
          Icons.add,
          color: Color(0xffffffff),
        ),
      ),
    );
  }
}



class _BottomNavBarItem extends StatelessWidget {
  const _BottomNavBarItem({ required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    if (label == 'Pending') {
      return Consumer<TaskViewModel>(
        builder: (context, taskVM, child) {
          final pendingCount = taskVM.tasks.where((task) => !task.isDone!).length;
          return NavigationDestination(
            icon: Badge(
              isLabelVisible: pendingCount > 0,
              backgroundColor: AppTheme.background50,
              offset: const Offset(8, -4),
              largeSize: 20,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              label: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child,animation) {
                  return ScaleTransition(
                    scale: animation,
                    child: child,
                  );
                },
                child: Text(
                  pendingCount.toString(),
                  key: ValueKey<int>(pendingCount),
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              child: Icon(icon),
            ),
            label: label,
          );
        },
      );
    }
    
    return NavigationDestination(
      icon: Icon(icon),
      label: label,
    );
  }
}
