import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:minimaltodo/helpers/mini_consts.dart';
import 'package:minimaltodo/helpers/mini_logger.dart';
import 'package:minimaltodo/services/notification_action_controller.dart';
import 'package:minimaltodo/view_models/general_view_model.dart';
import 'package:minimaltodo/view_models/theme_view_model.dart';
import 'package:minimaltodo/views/home.dart';
import 'package:minimaltodo/services/notification_service.dart';
import 'package:minimaltodo/view_models/category_view_model.dart';
import 'package:minimaltodo/view_models/navigation_view_model.dart';
import 'package:minimaltodo/view_models/priority_view_model.dart';
import 'package:minimaltodo/view_models/task_view_model.dart';
import 'package:provider/provider.dart';

void main() async {
  await GetStorage.init();
  MiniLogger.debug('Notification first time: ${GetStorage().read(mFirstTimeNotifPermission)}');
  try {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(const MinimalTodo());
    await NotificationService.initNotifications();
  } catch (e) {
    MiniLogger.error('Failed to initialize app: ${e.toString()}');
  }
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
      onActionReceivedMethod: NotificationActionController.onActionReceivedMethod,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskViewModel()),
        ChangeNotifierProvider(create: (_) => CategoryViewModel()),
        ChangeNotifierProvider(create: (_) => PriorityViewModel()),
        ChangeNotifierProvider(create: (_) => NavigationViewModel()),
        ChangeNotifierProvider(create: (_) => GeneralViewModel()),
        ChangeNotifierProvider(create: (_) => ThemeViewModel()),
      ],
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
