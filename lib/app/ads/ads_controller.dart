import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdsController extends ChangeNotifier {
  final String _homePageBannerUnitId = "ca-app-pub-4229818111096005/5755031111";
  final String _fullPageAfterTaskPutUnitId = "ca-app-pub-4229818111096005/2381642757";
  final String _notesPageBannerUnitId = "ca-app-pub-4229818111096005/8650138833";
  final String _fullPageAfterCategoryPutUnitId = "ca-app-pub-4229818111096005/7337057167";
  final String _fullPageAfterFolderPutUnitId = "ca-app-pub-4229818111096005/4710893828";

  late BannerAd _homePageBannerAd;
  BannerAd get homePageBannerAd => _homePageBannerAd;
  bool isHomePageBannerAdLoaded = false;

  late BannerAd _notesPageBannerAd;
  BannerAd get notesPageBannerAd => _notesPageBannerAd;
  bool isNotesPageBannerAdLoaded = false;

  late InterstitialAd _fullPageAfterTaskPutAd;
  InterstitialAd get fullPageAfterTaskPutAd => _fullPageAfterTaskPutAd;
  bool isFullPageAfterTaskPutAdLoaded = false;

  void initializeHomePageBannerAd() {
    _homePageBannerAd = BannerAd(
      adUnitId: _homePageBannerUnitId,
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          isHomePageBannerAdLoaded = true;
        },
        onAdFailedToLoad: (ad, error) {
          isHomePageBannerAdLoaded = false;
          ad.dispose();
        },
      ),
    );
    _homePageBannerAd.load();
  }

  void initializeNotesPageBannerAd() {
    _notesPageBannerAd = BannerAd(
      adUnitId: _notesPageBannerUnitId,
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          isNotesPageBannerAdLoaded = true;
        },
        onAdFailedToLoad: (ad, error) {
          isNotesPageBannerAdLoaded = false;
          ad.dispose();
        },
      ),
    );
    _notesPageBannerAd.load();
  }

  Future<void> initializeFullPageAfterTaskPutAd() async {
    await InterstitialAd.load(
      adUnitId: _fullPageAfterTaskPutUnitId,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _fullPageAfterTaskPutAd = ad;
          isFullPageAfterTaskPutAdLoaded = true;
        },
        onAdFailedToLoad: (adError) {},
      ),
    );
  }
}
