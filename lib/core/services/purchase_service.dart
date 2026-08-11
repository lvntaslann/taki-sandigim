import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PurchaseService {
  PurchaseService._();

  static final PurchaseService instance = PurchaseService._();

  static const String premiumEntitlementId = 'Takı Sandığım Pro';

  final ValueNotifier<bool> isPremium = ValueNotifier(false);

  /// RevenueCat's id for the current user (anonymous unless a login system
  /// is added later). This is the identifier our Cloud Functions backend
  /// uses (via the RevenueCat webhook → Firestore `users/{appUserId}`) to
  /// look up premium status server-side — pass this along whenever a future
  /// backend call (e.g. an AI proxy) needs to know if the caller is premium.
  String? get appUserId => _appUserId;
  String? _appUserId;

  Future<void> init() async {
    final apiKey = dotenv.env['PREMIUM_SDK_KEY'];
    if (apiKey == null || apiKey.isEmpty) return;

    await Purchases.configure(PurchasesConfiguration(apiKey));
    Purchases.addCustomerInfoUpdateListener(_onCustomerInfoUpdate);
    _onCustomerInfoUpdate(await Purchases.getCustomerInfo());

    // Silently re-link any purchase tied to the device's store account (e.g.
    // after a reinstall, which resets RevenueCat's local anonymous user id)
    // — no in-app login needed, this relies on the Play/App Store account
    // already signed in on the device. Best-effort: local CustomerInfo above
    // already applied, so a failure here (offline, etc.) just means the user
    // falls back to the manual "Geri Yükle" button.
    unawaited(_silentRestore());
  }

  Future<void> _silentRestore() async {
    try {
      _onCustomerInfoUpdate(await Purchases.restorePurchases());
    } catch (_) {
      // Ignored — see comment in init().
    }
  }

  void _onCustomerInfoUpdate(CustomerInfo info) {
    _appUserId = info.originalAppUserId;
    isPremium.value = info.entitlements.active.containsKey(premiumEntitlementId);
  }

  Future<Offerings> getOfferings() => Purchases.getOfferings();

  Future<CustomerInfo> purchasePackage(Package package) async {
    final result = await Purchases.purchase(PurchaseParams.package(package));
    return result.customerInfo;
  }

  Future<CustomerInfo> restorePurchases() => Purchases.restorePurchases();
}
