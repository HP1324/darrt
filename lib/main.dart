import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get_storage/get_storage.dart';
import 'package:minimaltodo/app/calendar_view_model.dart';
import 'package:minimaltodo/app/navigation_view_model.dart';
import 'package:minimaltodo/app/theme_view_model.dart';
import 'package:minimaltodo/category/logic/category_state_controller.dart';
import 'package:minimaltodo/category/logic/category_view_model.dart';
import 'package:minimaltodo/helpers/mini_logger.dart';
import 'package:minimaltodo/helpers/mini_box.dart';
import 'package:minimaltodo/helpers/object_box.dart';
import 'package:minimaltodo/helpers/utils.dart';
import 'package:minimaltodo/task/logic/task_state_controller.dart';
import 'package:minimaltodo/task/logic/task_view_model.dart';
import 'package:minimaltodo/views/home.dart';
import 'package:provider/provider.dart';
import 'package:minimaltodo/app/services/notification_action_controller.dart';
import 'package:minimaltodo/app/services/notification_service.dart';
Future<void> initApp() async {
  try {
    final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
    await GetStorage.init();
    await MiniBox.initStorage();
    await ObjectBox.init();
    getIt.registerSingleton<TaskViewModel>(TaskViewModel());
    await NotificationService.initNotifications();
    FlutterNativeSplash.remove();
  } catch (e) {
    MiniLogger.e('Failed to initialize app: ${e.toString()}, Error type: ${e.runtimeType}');
  }
}

void main() async {
  await initApp();
  runApp(MinimalTodo());
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
      onActionReceivedMethod: onActionReceivedMethod,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskViewModel()),
        ChangeNotifierProvider(create: (_) => CategoryViewModel()),
        ChangeNotifierProvider(create: (_) => NavigationViewModel()),
        ChangeNotifierProvider(create: (_) => ThemeViewModel()),
        ChangeNotifierProvider(create: (_) => CalendarViewModel()),
        ChangeNotifierProvider(create: (_) => CalendarViewModel()),
        ChangeNotifierProvider(create: (_) => TaskStateController()),
        ChangeNotifierProvider(create: (_) => CategoryStateController()),
      ],
      child: Consumer<ThemeViewModel>(builder: (context, themeVM, _) {
        return MaterialApp(
          navigatorKey: MinimalTodo.navigatorKey,
          theme: FlexColorScheme.light(colors: themeVM.selectedScheme).toTheme,
          darkTheme: FlexColorScheme.dark(
            colors: themeVM.selectedScheme.toDark(),
            surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
            appBarStyle: FlexAppBarStyle.background,
            darkIsTrueBlack: false,
          ).toTheme,
          themeMode: themeVM.themeMode,
          debugShowCheckedModeBanner: false,
          title: 'MiniTodo',
          home: const Home(),
        );
      }),
    );
  }
}
