import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:darrt/app/notification/notification_action_controller.dart';
import 'package:darrt/app/theme/theme_controller.dart';
import 'package:darrt/helpers/globals.dart' as g;
import 'package:darrt/home.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'app/app_initialization_service.dart';

void main() async {
  final providerContainer = ProviderContainer();

  await SentryFlutter.init(
    (SentryFlutterOptions options) {
      options.dsn =
          'https://99a7380b964ec1d875f7cd7ec087eff7@o4509807915237376.ingest.de.sentry.io/4509807918252112';
      // Set tracesSampleRate to 1.0 to capture 100% of transactions for tracing.
      // We recommend adjusting this value in production.
      options.tracesSampleRate = 1.0;
      // The sampling rate for profiling is relative to tracesSampleRate
      // Setting to 1.0 will profile 100% of sampled transactions:
      options.profilesSampleRate = 1.0;
      options.attachScreenshot = true;
      options.screenshotQuality = SentryScreenshotQuality.full;
    },
    appRunner: () async {
      final appInitService = providerContainer.read(appInitServiceProvider);
      await appInitService.initApp();
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
      runApp(
        SentryWidget(
          child: DevicePreview(
            enabled: !kReleaseMode,
            builder: (context) => UncontrolledProviderScope(
              container: providerContainer,
              child: const Darrt(),
            ),
          ),
        ),
      );
    },
  );
}

class Darrt extends ConsumerStatefulWidget {
  const Darrt({super.key});

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  ConsumerState<Darrt> createState() => _DarrtState();
}

class _DarrtState extends ConsumerState<Darrt> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    AwesomeNotifications().setListeners(
      onActionReceivedMethod:
          NotificationActionController.onActionReceivedMethod,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.detached) {
      await g.audioController.stopAudioService();
      await AwesomeNotifications().cancel(999);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeControllerProvider);

    final lightTheme = themeState.lightTheme;
    final darkTheme = themeState.darkTheme;
    final themeMode = themeState.themeMode;

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
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
      title: 'Darrt',
      home: Home(),
    );
  }
}
