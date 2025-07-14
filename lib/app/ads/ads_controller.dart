import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdsController extends ChangeNotifier {
  final String _homePageBannerUnitId = "ca-app-pub-4229818111096005/5755031111";
  final String _fullPageOnAddTaskPagePopUnitId = "ca-app-pub-4229818111096005/2381642757";
  final String _notesPageBannerUnitId = "ca-app-pub-4229818111096005/8650138833";
  final String _addNotePageBannerUnitId = "ca-app-pub-4229818111096005/1130773287";
  final String _fullPageOnAddCategoryPagePopAdUnitId = "ca-app-pub-4229818111096005/5638114063";
  final String _fullPageOnAddFolderPagePopAdUnitId = "ca-app-pub-4229818111096005/4710893828";
  final String _fullPageOnAddNotePagePopUnitId = "ca-app-pub-4229818111096005/7943593642";
  final String _fullPageOnCustomSoundPickUnitId = "ca-app-pub-4229818111096005/5233669822";
  final String _themePageBannerUnitId = "ca-app-pub-4229818111096005/6880394618";

  late BannerAd _homePageBannerAd;
  BannerAd get homePageBannerAd => _homePageBannerAd;
  bool isHomePageBannerAdLoaded = false;

  late BannerAd _notesPageBannerAd;
  BannerAd get notesPageBannerAd => _notesPageBannerAd;
  bool isNotesPageBannerAdLoaded = false;

  late BannerAd _addNotePageBannerAd;
  BannerAd get addNotePageBannerAd => _addNotePageBannerAd;
  bool isAddNotePageBannerAdLoaded = false;

  late BannerAd _themePageBannerAd;
  BannerAd get themePageBannerAd => _themePageBannerAd;
  bool isThemePageBannerAdLoaded = false;

  late InterstitialAd _fullPageAdOnAddTaskPagePop;
  InterstitialAd get fullPageAdOnAddTaskPagePop => _fullPageAdOnAddTaskPagePop;
  bool isFullPageAfterTaskPutAdLoaded = false;

  late InterstitialAd _fullPageAdOnAddCategoryPagePop;
  InterstitialAd get fullPageAdOnAddCategoryPagePop => _fullPageAdOnAddCategoryPagePop;
  bool isFullPageAdOnAddCategoryPopLoaded = false;

  late InterstitialAd _fullPageAdOnAddFolderPagePop;
  InterstitialAd get fullPageAdOnAddFolderPagePop => _fullPageAdOnAddFolderPagePop;
  bool isFullPageOnAddFolderPagePopAdLoaded = false;

  late InterstitialAd _fullPageAdOnAddNotePagePop;
  InterstitialAd get fullPageAdOnAddNotePagePop => _fullPageAdOnAddNotePagePop;
  bool isFullPageOnAddNotePagePopAdLoaded = false;

  late InterstitialAd _fullPageOnCustomSoundPickAd;
  InterstitialAd get fullPageOnCustomSoundPickAd => _fullPageOnCustomSoundPickAd;
  bool isFullPageOnCustomSoundPickAdLoaded = false;

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

  void initializeAddNotePageBannerAd() {
    _addNotePageBannerAd = BannerAd(
      adUnitId: _addNotePageBannerUnitId,
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          isAddNotePageBannerAdLoaded = true;
        },
        onAdFailedToLoad: (ad, error) {
          isAddNotePageBannerAdLoaded = false;
          ad.dispose();
        },
      ),
    );
    _addNotePageBannerAd.load();
  }

  void initializeFullPageAdOnAddTaskPagePop() async {
    await InterstitialAd.load(
      adUnitId: _fullPageOnAddTaskPagePopUnitId,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _fullPageAdOnAddTaskPagePop = ad;
          isFullPageAfterTaskPutAdLoaded = true;
        },
        onAdFailedToLoad: (adError) {
          isFullPageAfterTaskPutAdLoaded = false;
        },
      ),
    );
  }

  void initializeFullPageAdOnAddCategoryPagePop() async {
    await InterstitialAd.load(
      adUnitId: _fullPageOnAddCategoryPagePopAdUnitId,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _fullPageAdOnAddCategoryPagePop = ad;
          isFullPageAdOnAddCategoryPopLoaded = true;
        },
        onAdFailedToLoad: (adError) {
          debugPrint('${adError.message}');
          isFullPageAdOnAddCategoryPopLoaded = false;
        },
      ),
    );
  }
  void initializeFullPageAdOnAddNotePagePop() async {
    await InterstitialAd.load(
      adUnitId: _fullPageOnAddNotePagePopUnitId,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _fullPageAdOnAddNotePagePop = ad;
          isFullPageOnAddNotePagePopAdLoaded = true;
        },
        onAdFailedToLoad: (adError) {
          isFullPageOnAddNotePagePopAdLoaded = false;
        },
      ),
    );
  }
  void initializeFullPageOnAddFolderPagePopAd() async {
    await InterstitialAd.load(
      adUnitId: _fullPageOnAddFolderPagePopAdUnitId,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _fullPageAdOnAddFolderPagePop = ad;
          isFullPageOnAddFolderPagePopAdLoaded = true;
        },
        onAdFailedToLoad: (adError) {
          isFullPageOnAddFolderPagePopAdLoaded = false;
        },
      ),
    );
  }



  void initializeFullPageAdOnCustomSoundPick() async {
    await InterstitialAd.load(
      adUnitId: _fullPageOnCustomSoundPickUnitId,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _fullPageOnCustomSoundPickAd = ad;
          isFullPageOnCustomSoundPickAdLoaded = true;
        },
        onAdFailedToLoad: (adError) {
          isFullPageOnCustomSoundPickAdLoaded = false;
        },
      ),
    );
  }

  void initializeThemePageBannerAd() {
    _themePageBannerAd = BannerAd(
      adUnitId: _themePageBannerUnitId,
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          isThemePageBannerAdLoaded = true;
        },
        onAdFailedToLoad: (ad, error) {
          isThemePageBannerAdLoaded = false;
          ad.dispose();
        },
      ),
    );
    _themePageBannerAd.load();
  }
}
