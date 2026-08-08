import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

const _testInterstitialUnitId = 'ca-app-pub-3940256099942544/1033173712';
class InterstitialAdManager {
  InterstitialAd? _ad;
  bool _isLoading = false;

  String get _unitId => kDebugMode
      ? _testInterstitialUnitId
      : (dotenv.env['ADMOB_INTERSTITIAL_UNIT_ID'] ?? _testInterstitialUnitId);

  void preload() {
    if (_isLoading || _ad != null) return;
    _isLoading = true;
    InterstitialAd.load(
      adUnitId: _unitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          if (kDebugMode) debugPrint('InterstitialAdManager loaded: ${ad.adUnitId}');
          _ad = ad;
          _isLoading = false;
        },
        onAdFailedToLoad: (error) {
          if (kDebugMode) debugPrint('InterstitialAdManager failed to load: $error');
          _isLoading = false;
        },
      ),
    );
  }

  void showIfReady() {
    final ad = _ad;
    if (ad == null) {
      preload();
      return;
    }
    _ad = null;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        preload();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        preload();
      },
    );
    ad.show();
  }

  void dispose() {
    _ad?.dispose();
    _ad = null;
  }
}
