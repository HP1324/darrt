import 'dart:async';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:darrt/app/notification/notification_action_controller.dart';
import 'package:darrt/app/notification/notification_service.dart';
import 'package:darrt/app/services/auto_backup_service.dart';
import 'package:darrt/app/services/google_sign_in_service.dart';
import 'package:darrt/helpers/globals.dart' as g;
import 'package:darrt/helpers/mini_logger.dart';
import 'package:darrt/app/services/mini_box.dart';
import 'package:darrt/app/services/object_box.dart';
import 'package:darrt/home.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter/services.dart';

void setupDependencies(){
  final ProviderContainer container = ProviderContainer();

  GetIt.I.registerSingleton<ProviderContainer>(container);
}

/// Initializes app services and state
Future<void> initApp() async {
  try {
    final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

    // Initialize google mobile ads sdk
    unawaited(MobileAds.instance.initialize());

    // Initialize local storage & database
    await ObjectBox().init();
    MiniBox().initStorage();

    await GoogleSignInService().restoreGoogleAccount();
    // Initialize notifications
    await NotificationService.init();

    Workmanager().initialize(callBackDispatcher, isInDebugMode: kDebugMode);

    setupDependencies();

    FlutterNativeSplash.remove();
  } catch (e, t) {
    MiniLogger.e('Failed to initialize app: ${e.toString()}, Error type: ${e.runtimeType}');
    MiniLogger.t(t.toString());
  }
}

void main() async {
  await initApp();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(DevicePreview(
    enabled: !kReleaseMode,
    builder: (context) => UncontrolledProviderScope(container: GetIt.I<ProviderContainer>(),child: const Darrt(),),
  ));
}

class Darrt extends StatefulWidget {
  const Darrt({super.key});
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  State<Darrt> createState() => _DarrtState();
}

class _DarrtState extends State<Darrt> {
  @override
  void initState() {
    super.initState();
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: g.themeMan,
      builder: (context, widget) {
        final lightTheme = g.themeMan.lightTheme;
        final darkTheme = g.themeMan.darkTheme;
        final themeMode = g.themeMan.themeMode;

        return MaterialApp(
          builder: DevicePreview.appBuilder,
          locale: DevicePreview.locale(context),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            FlutterQuillLocalizations.delegate,
          ],
          navigatorKey: Darrt.navigatorKey,
          theme: lightTheme.copyWith(
            textTheme: GoogleFonts.gabaritoTextTheme(lightTheme.textTheme),
          ),
          darkTheme: darkTheme.copyWith(
            textTheme: GoogleFonts.gabaritoTextTheme(darkTheme.textTheme),
          ),
          themeMode: themeMode,
          debugShowCheckedModeBanner: false,
          title: 'Darrt',
          home: Home(),
        );
      },
    );
  }
}
