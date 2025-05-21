import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:minimaltodo/app/state/managers/calendar_manager.dart';
import 'package:minimaltodo/app/state/managers/navigation_manager.dart';
import 'package:minimaltodo/app/state/managers/theme_manager.dart';
import 'package:minimaltodo/app/notification/notification_action_controller.dart';
import 'package:minimaltodo/app/notification/notification_service.dart';

import 'package:minimaltodo/category/state/category_state_controller.dart';
import 'package:minimaltodo/category/state/category_view_model.dart';
import 'package:minimaltodo/helpers/globals.dart' as g;

import 'package:minimaltodo/note/state/folder_state_controller.dart';
import 'package:minimaltodo/note/state/folder_view_model.dart';
import 'package:minimaltodo/note/state/note_state_controller.dart';
import 'package:minimaltodo/note/state/note_view_model.dart';

import 'package:minimaltodo/task/state/task_state_controller.dart';
import 'package:minimaltodo/task/state/task_view_model.dart';

import 'package:minimaltodo/helpers/mini_logger.dart';
import 'package:minimaltodo/helpers/mini_box.dart';
import 'package:minimaltodo/helpers/object_box.dart';
import 'package:minimaltodo/helpers/utils.dart';

import 'package:minimaltodo/home.dart';


/// Registers all ChangeNotifiers and singletons
void registerSingletons() {
  // ViewModels
  getIt.registerSingleton<TaskViewModel>(TaskViewModel());
  getIt.registerSingleton<CategoryViewModel>(CategoryViewModel());
  getIt.registerSingleton<NoteViewModel>(NoteViewModel());
  getIt.registerSingleton<FolderViewModel>(FolderViewModel());

  // State Controllers
  getIt.registerSingleton<TaskStateController>(TaskStateController());
  getIt.registerSingleton<CategoryStateController>(CategoryStateController());
  getIt.registerSingleton<NoteStateController>(NoteStateController());
  getIt.registerSingleton<FolderStateController>(FolderStateController());

  // Managers
  getIt.registerLazySingleton<CalendarManager>(() => CalendarManager());
  getIt.registerSingleton<ThemeManager>(ThemeManager());
  getIt.registerSingleton<NavigationManager>(NavigationManager());
}

/// Initializes app services and state
Future<void> initApp() async {
  try {
    final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

    // Initialize local storage & database
    await MiniBox.initStorage();
    await ObjectBox.init();

    // Register singleton instances
    registerSingletons();

    // Initialize notifications
    await NotificationService.init();

  } catch (e) {
    MiniLogger.e('Failed to initialize app: ${e.toString()}, Error type: ${e.runtimeType}');
  }
}

void main() async {
  await initApp();
  runApp(MiniTodo());
}

class MiniTodo extends StatefulWidget {
  const MiniTodo({super.key});
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  State<MiniTodo> createState() => _MiniTodoState();
}

class _MiniTodoState extends State<MiniTodo> {
  @override
  void initState() {
    super.initState();
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
    );
  }

  @override
  Widget build(BuildContext context) {
    return  ListenableBuilder(
        listenable: g.themeM,
        builder: (context, widget) {
          final lightTheme = g.themeM.lightTheme;
          final darkTheme = g.themeM.darkTheme;
          final themeMode = g.themeM.themeMode;
          return MaterialApp(
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              FlutterQuillLocalizations.delegate,
            ],
            navigatorKey: MiniTodo.navigatorKey,
            theme: lightTheme.copyWith(
              textTheme: GoogleFonts.gabaritoTextTheme(lightTheme.textTheme),
            ),
            darkTheme: darkTheme.copyWith(
              textTheme: GoogleFonts.gabaritoTextTheme(darkTheme.textTheme),
            ),
            themeMode: themeMode,
            debugShowCheckedModeBanner: false,
            title: 'MiniTodo',
            home: const Home(),
          );
        }
    );
  }
}
