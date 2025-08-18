import 'dart:async';

import 'package:darrt/app/ads/subscription_service.dart';
import 'package:darrt/app/notification/notification_service.dart';
import 'package:darrt/app/services/auto_backup_service.dart';
import 'package:darrt/app/services/google_sign_in_service.dart';
import 'package:darrt/app/services/mini_box.dart';
import 'package:darrt/app/services/object_box.dart';
import 'package:darrt/helpers/mini_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:workmanager/workmanager.dart';

class AppInitializationService {
  Future<void> initApp() async {
    final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

    await _configureRevenueCatSdk();
    
    _initMobileAdsSdk();
    
    await _initObjectbox();
    
    await _restoreGoogleAccount();
    
    await _initNotificationService();
    
    await _initWorkmanager();

    FlutterNativeSplash.remove();
  }

  Future<void> _configureRevenueCatSdk() async {
    try {
      await subService.configureRevenueCatSdk();
    } catch (e, t) {
      Sentry.captureException(e, stackTrace: t);
      MiniLogger.e('${e.toString()}, type: ${e.runtimeType}');
    }
  }

  void _initMobileAdsSdk() {
    try {
      if (subService.showAds) MobileAds.instance.initialize();
    } catch (e, t) {
      Sentry.captureException(e, stackTrace: t);
      MiniLogger.e('${e.toString()}, type: ${e.runtimeType}');
    }
  }
  
  Future<void> _initObjectbox()async{
    try{
      await ObjectBox().init();
      MiniBox().initStorage();
    }catch (e, t) {
      Sentry.captureException(e, stackTrace: t);
      MiniLogger.e('${e.toString()}, type: ${e.runtimeType}');
    }
  }
  
  Future<void> _restoreGoogleAccount()async{
    try{
      await GoogleSignInService().restoreGoogleAccount();
    }catch (e, t) {
      Sentry.captureException(e, stackTrace: t);
      MiniLogger.e('${e.toString()}, type: ${e.runtimeType}');
    }
  }
  
  Future<void> _initNotificationService()async{
    try{
      await NotificationService.init();
    }catch (e, t) {
      Sentry.captureException(e, stackTrace: t);
      MiniLogger.e('${e.toString()}, type: ${e.runtimeType}');
    }
  }
  
  Future<void> _initWorkmanager()async{
    try{
      await Workmanager().initialize(callBackDispatcher);
    }catch (e, t) {
      Sentry.captureException(e, stackTrace: t);
      MiniLogger.e('${e.toString()}, type: ${e.runtimeType}');
    }

  }
}

final appInitServiceProvider = Provider<AppInitializationService>((ref) {
  return AppInitializationService();
});
