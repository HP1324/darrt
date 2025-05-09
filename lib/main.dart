import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minimaltodo/app/state/managers/calendar_manager.dart';
import 'package:minimaltodo/app/state/managers/general_state_manager.dart';
import 'package:minimaltodo/app/state/managers/navigation_manager.dart';
import 'package:minimaltodo/app/notification/notification_action_controller.dart';
import 'package:minimaltodo/app/state/managers/theme_manager.dart';
import 'package:minimaltodo/category/state/category_state_controller.dart';
import 'package:minimaltodo/category/state/category_view_model.dart';
import 'package:minimaltodo/helpers/mini_logger.dart';
import 'package:minimaltodo/helpers/mini_box.dart';
import 'package:minimaltodo/helpers/object_box.dart';
import 'package:minimaltodo/helpers/utils.dart';
import 'package:minimaltodo/task/state/task_state_controller.dart';
import 'package:minimaltodo/task/state/task_view_model.dart';
import 'package:minimaltodo/home.dart';
import 'package:provider/provider.dart';
import 'package:minimaltodo/app/notification/notification_service.dart';
void registerSingletons(){
  getIt.registerSingleton<TaskViewModel>(TaskViewModel());
  getIt.registerSingleton<CategoryViewModel>(CategoryViewModel());
  getIt.registerSingleton<TaskStateController>(TaskStateController());
  getIt.registerSingleton<CategoryStateController>(CategoryStateController());
  //Registering CalendarManager as a lazy singleton to force initialization until first use
  //without lazy it will get initialized in place and then the scroll controller's
  //scroll logic does not work properly
  getIt.registerLazySingleton<CalendarManager>(()=>CalendarManager());
  getIt.registerSingleton<ThemeManager>(ThemeManager());
  getIt.registerSingleton<NavigationManager>(NavigationManager());
  getIt.registerSingleton<GeneralStateManager>(GeneralStateManager());
}
Future<void> initApp() async {
  try {
    final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
    await GetStorage.init();
    await MiniBox.initStorage();
    await ObjectBox.init();
    registerSingletons();
    await NotificationService.initNotifications();
    FlutterNativeSplash.remove();
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => getIt<TaskViewModel>()),
        ChangeNotifierProvider(create: (_) => getIt<CategoryViewModel>()),
        ChangeNotifierProvider(create: (_) => getIt<TaskStateController>()),
        ChangeNotifierProvider(create: (_) => getIt<CategoryStateController>()),
        ChangeNotifierProvider(create: (_) => getIt<NavigationManager>()),
        ChangeNotifierProvider(create: (_) => getIt<ThemeManager>()),
        ChangeNotifierProvider(create: (_) => getIt<CalendarManager>()),
        ChangeNotifierProvider(create: (_) => getIt<GeneralStateManager>()),
      ],
      child: Consumer<ThemeManager>(builder: (context, manager, _) {
        return MaterialApp(
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            FlutterQuillLocalizations.delegate,
          ],
          navigatorKey: MiniTodo.navigatorKey,
          theme: manager.lightTheme.copyWith(
            textTheme: GoogleFonts.gabaritoTextTheme(manager.lightTheme.textTheme)
          ),
          darkTheme: manager.darkTheme.copyWith(
              textTheme: GoogleFonts.gabaritoTextTheme(manager.darkTheme.textTheme)
          ),
          themeMode: manager.themeMode,
          debugShowCheckedModeBanner: false,
          title: 'MiniTodo',
          home: const Home(),
        );
      }),
    );
  }
}
