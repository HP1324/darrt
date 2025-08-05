import 'package:darrt/helpers/mini_logger.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
// Global instance
final subService = SubscriptionService();

class SubscriptionService {
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal();

  bool _showAds = true;

  bool get showAds => _showAds;

  late final CustomerInfo _customerInfo;

  void disableAds(){
    _showAds = false;
  }

  Future<void> configureRevenueCatSdk() async {
    await Purchases.setLogLevel(LogLevel.verbose);

    PurchasesConfiguration configuration = PurchasesConfiguration(
      "goog_VoehHrOnclbtuqCwAJyRvUSpIHy",
    );

    await Purchases.configure(configuration);

    _customerInfo = await Purchases.getCustomerInfo();


    await isUserSubscribed();
  }

  Future<void> isUserSubscribed() async {
    MiniLogger.d('Inside isUserSubscribed: showAds: $showAds');
    if (_customerInfo.entitlements.all['no-ads']?.isActive ?? false) {
      MiniLogger.d('User is subscribed to no ads');
      disableAds();
    }
  }

  Future<void> restorePurchases() async {
    await Purchases.restorePurchases();
  }

  Future<PaywallResult> presentPaywall() async{
    try {
      final paywallResult = await RevenueCatUI.presentPaywall();
      MiniLogger.dp('Paywall result: $paywallResult');
      return paywallResult;
    }catch (e,t){
      MiniLogger.e('${e.toString()}, type: ${e.runtimeType}');
      MiniLogger.t('$t');
      return PaywallResult.error;
    }
  }
}
