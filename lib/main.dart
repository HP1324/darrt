import 'dart:async';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:darrt/app/ads/subscription_service.dart';
import 'package:darrt/app/notification/notification_action_controller.dart';
import 'package:darrt/app/notification/notification_service.dart';
import 'package:darrt/app/services/auto_backup_service.dart';
import 'package:darrt/app/services/google_sign_in_service.dart';
import 'package:darrt/app/services/mini_box.dart';
import 'package:darrt/app/services/object_box.dart';
import 'package:darrt/helpers/globals.dart' as g;
import 'package:darrt/helpers/mini_logger.dart';
import 'package:darrt/home.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:workmanager/workmanager.dart';

/// Initializes app services and state
Future<void> initApp() async {
  try {
    final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

    await subService.configureRevenueCatSdk();

    // Initialize google mobile ads sdk only if user is not subscribed to no ads
    if (subService.showAds) {
      MobileAds.instance.initialize();
    }

    // Initialize local storage & database
    await ObjectBox().init();
    MiniBox().initStorage();

    await GoogleSignInService().restoreGoogleAccount();
    // Initialize notifications
    await NotificationService.init();

    await Workmanager().initialize(callBackDispatcher);

    FlutterNativeSplash.remove();
  } catch (e, t) {
    MiniLogger.e(
      'Failed to initialize app: ${e.toString()}, Error type: ${e.runtimeType}',
    );
    MiniLogger.t(t.toString());
  }
}

void main() async {
  await initApp();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  await SentryFlutter.init(
    (options) {
      options.dsn =
          'https://99a7380b964ec1d875f7cd7ec087eff7@o4509807915237376.ingest.de.sentry.io/4509807918252112';
      // Set tracesSampleRate to 1.0 to capture 100% of transactions for tracing.
      // We recommend adjusting this value in production.
      options.tracesSampleRate = 1.0;
      // The sampling rate for profiling is relative to tracesSampleRate
      // Setting to 1.0 will profile 100% of sampled transactions:
      options.profilesSampleRate = 1.0;
      options.attachScreenshot = true;
    },
    appRunner: () => runApp(
      SentryWidget(
        child: DevicePreview(
          enabled: !kReleaseMode,
          builder: (context) => ProviderScope(child: const Darrt()),
        ),
      ),
    ),
  );
}

class Darrt extends StatefulWidget {
  const Darrt({super.key});

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

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
  void dispose() {
    MiniLogger.dp('Main dispose called');
    super.dispose();
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
