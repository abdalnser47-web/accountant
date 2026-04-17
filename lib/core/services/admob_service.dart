import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// خدمة إدارة الإعلانات (AdMob)
class AdMobService {
  static final AdMobService _instance = AdMobService._internal();
  factory AdMobService() => _instance;
  AdMobService._internal();
  
  // معرفات وحدات الإعلان (استبدلها بمعرفاتك الحقيقية من AdMob)
  static const String _bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111'; // Test ID
  static const String _interstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712'; // Test ID
  static const String _rewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917'; // Test ID
  
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  bool _isInterstitialReady = false;
  bool _isRewardedReady = false;
  
  /// تهيئة AdMob
  Future<void> initialize() async {
    await MobileAds.instance.initialize();
    _loadInterstitialAd();
    _loadRewardedAd();
  }
  
  /// إنشاء Banner Ad
  BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) => debugPrint('Banner Ad loaded'),
        onAdFailedToLoad: (ad, error) {
          debugPrint('Banner Ad failed to load: $error');
          ad.dispose();
        },
      ),
    );
  }
  
  /// تحميل Interstitial Ad
  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialReady = true;
          debugPrint('Interstitial Ad loaded');
          
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _loadInterstitialAd(); // إعادة التحميل بعد العرض
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              debugPrint('Interstitial Ad failed to show: $error');
              ad.dispose();
              _loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          debugPrint('Interstitial Ad failed to load: $error');
          _isInterstitialReady = false;
        },
      ),
    );
  }
  
  /// عرض Interstitial Ad
  void showInterstitialAd() {
    if (_isInterstitialReady && _interstitialAd != null) {
      _interstitialAd!.show();
      _interstitialAd = null;
      _isInterstitialReady = false;
    } else {
      debugPrint('Interstitial Ad not ready yet');
    }
  }
  
  /// تحميل Rewarded Ad
  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedReady = true;
          debugPrint('Rewarded Ad loaded');
        },
        onAdFailedToLoad: (error) {
          debugPrint('Rewarded Ad failed to load: $error');
          _isRewardedReady = false;
        },
      ),
    );
  }
  
  /// عرض Rewarded Ad مع مكافأة
  Future<bool> showRewardedAd({
    required VoidCallback onRewardEarned,
  }) async {
    if (!_isRewardedReady || _rewardedAd == null) {
      debugPrint('Rewarded Ad not ready yet');
      return false;
    }
    
    final completer = Completer<bool>();
    
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _loadRewardedAd();
        if (!completer.isCompleted) {
          completer.complete(false);
        }
      },
    );
    
    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        debugPrint('User earned reward: ${reward.amount} ${reward.type}');
        onRewardEarned();
        if (!completer.isCompleted) {
          completer.complete(true);
        }
      },
    );
    
    return completer.future;
  }
  
  /// التحقق مما إذا كان المستخدم Premium (لا يرى إعلانات)
  bool isPremiumUser = false;
  
  /// تعيين حالة Premium
  void setPremiumStatus(bool isPremium) {
    isPremiumUser = isPremium;
  }
}
