import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minimaltodo/app/notification/notification_action_controller.dart';
import 'package:minimaltodo/app/notification/notification_service.dart';
import 'package:minimaltodo/app/services/auto_backup_service.dart';
import 'package:minimaltodo/app/services/google_sign_in_service.dart';
import 'package:minimaltodo/helpers/globals.dart' as g;
import 'package:minimaltodo/helpers/mini_logger.dart';
import 'package:minimaltodo/app/services/mini_box.dart';
import 'package:minimaltodo/app/services/object_box.dart';
import 'package:minimaltodo/home.dart';
import 'package:workmanager/workmanager.dart';


/// Initializes app services and state
Future<void> initApp() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize local storage & database
    await MiniBox().initStorage();
    await ObjectBox().init();

    await GoogleSignInService().restoreGoogleAccount();
    // Initialize notifications
    await NotificationService.init();

    Workmanager().initialize(callBackDispatcher,isInDebugMode: kDebugMode);
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
        listenable: g.themeMan,
        builder: (context, widget) {
          final lightTheme = g.themeMan.lightTheme;
          final darkTheme = g.themeMan.darkTheme;
          final themeMode = g.themeMan.themeMode;

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
            title: 'Darrt',
            home: const Home(),
          );
        }
    );
  }
}
