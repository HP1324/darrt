import 'package:darrt/helpers/mini_logger.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
// Global instance
final subService = SubscriptionService();

class SubscriptionService {
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal();

  bool showAds = true;

  late final CustomerInfo _customerInfo;

  Future<void> configureRevenueCatSdk() async {
    await Purchases.setLogLevel(LogLevel.debug);

    PurchasesConfiguration configuration = PurchasesConfiguration(
      "goog_VoehHrOnclbtuqCwAJyRvUSpIHy",
    );

    await Purchases.configure(configuration);

    _customerInfo = await Purchases.getCustomerInfo();

    await isUserSubscribed();
  }

  Future<void> isUserSubscribed() async {
    if (_customerInfo.entitlements.all['no-ads']?.isActive ?? false) {
      showAds = false;
    }
  }

  Future<void> restorePurchases() async {
    await Purchases.restorePurchases();
  }

  Future<PaywallResult> presentPaywall() async{
      final paywallResult = await RevenueCatUI.presentPaywall();
      MiniLogger.dp('Paywall result: $paywallResult');
      return paywallResult;
  }
}
