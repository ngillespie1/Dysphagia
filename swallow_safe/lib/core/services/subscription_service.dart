import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// RevenueCat API keys - replace with your actual keys
class _RevenueCatConfig {
  /// Apple API key from RevenueCat dashboard
  static const String appleApiKey = 'appl_YOUR_APPLE_API_KEY';
  
  /// Google API key from RevenueCat dashboard
  static const String googleApiKey = 'goog_YOUR_GOOGLE_API_KEY';

  /// Entitlement identifier configured in RevenueCat
  static const String proEntitlementId = 'pro';

  /// Product identifiers
  static const String monthlyProductId = 'swallowsafe_pro_monthly';
  static const String yearlyProductId = 'swallowsafe_pro_yearly';

  /// Whether RevenueCat has been configured with real keys
  static bool get hasRealKeys =>
      appleApiKey != 'appl_YOUR_APPLE_API_KEY' &&
      googleApiKey != 'goog_YOUR_GOOGLE_API_KEY';
}

/// Subscription tier enum
enum SubscriptionTier {
  free,
  pro,
}

/// Service for managing subscription state via RevenueCat
/// Falls back to mock behavior on web or when API keys are not configured.
class SubscriptionService {
  static const String _tierKey = 'subscription_tier';

  SharedPreferences? _prefs;
  SubscriptionTier _currentTier = SubscriptionTier.free;
  bool _initialized = false;
  bool _revenueCatAvailable = false;

  /// Cached offerings from RevenueCat
  Offerings? _offerings;

  /// Stream controller for subscription status changes
  final _statusController = StreamController<SubscriptionTier>.broadcast();

  /// Stream of subscription status changes
  Stream<SubscriptionTier> get statusStream => _statusController.stream;

  /// Initialize the service and configure RevenueCat
  Future<void> initialize() async {
    if (_initialized) return;

    // On web, use mock fallback
    if (kIsWeb) {
      _currentTier = SubscriptionTier.free;
      _initialized = true;
      return;
    }

    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (e) {
      debugPrint('SubscriptionService: SharedPreferences init error: $e');
    }

    // Try to initialize RevenueCat
    if (_RevenueCatConfig.hasRealKeys) {
      await _initializeRevenueCat();
    } else {
      debugPrint('SubscriptionService: No RevenueCat API keys configured, using mock mode.');
      await _loadFromPrefs();
    }

    _initialized = true;
  }

  /// Initialize RevenueCat SDK
  Future<void> _initializeRevenueCat() async {
    try {
      late PurchasesConfiguration configuration;

      if (Platform.isIOS || Platform.isMacOS) {
        configuration = PurchasesConfiguration(_RevenueCatConfig.appleApiKey);
      } else if (Platform.isAndroid) {
        configuration = PurchasesConfiguration(_RevenueCatConfig.googleApiKey);
      } else {
        debugPrint('SubscriptionService: Unsupported platform for RevenueCat');
        await _loadFromPrefs();
        return;
      }

      await Purchases.configure(configuration);

      // Listen for customer info updates
      Purchases.addCustomerInfoUpdateListener(_handleCustomerInfoUpdate);

      // Check current subscription status
      await _refreshFromRevenueCat();
      _revenueCatAvailable = true;

      debugPrint('SubscriptionService: RevenueCat initialized. Tier: $_currentTier');
    } catch (e) {
      debugPrint('SubscriptionService: RevenueCat init failed: $e');
      await _loadFromPrefs();
    }
  }

  /// Handle RevenueCat customer info updates (e.g. renewal, expiration)
  void _handleCustomerInfoUpdate(CustomerInfo customerInfo) {
    final hadPro = isPro;
    _updateTierFromCustomerInfo(customerInfo);
    if (hadPro != isPro) {
      _statusController.add(_currentTier);
    }
  }

  /// Extract subscription tier from RevenueCat CustomerInfo
  void _updateTierFromCustomerInfo(CustomerInfo info) {
    final entitlement = info.entitlements.all[_RevenueCatConfig.proEntitlementId];
    if (entitlement != null && entitlement.isActive) {
      _currentTier = SubscriptionTier.pro;
    } else {
      _currentTier = SubscriptionTier.free;
    }
    _persistTier();
  }

  /// Load subscription tier from local prefs (fallback)
  Future<void> _loadFromPrefs() async {
    try {
      final tierStr = _prefs?.getString(_tierKey) ?? 'free';
      _currentTier = tierStr == 'pro' ? SubscriptionTier.pro : SubscriptionTier.free;
    } catch (e) {
      _currentTier = SubscriptionTier.free;
    }
  }

  /// Persist tier to prefs for offline access
  Future<void> _persistTier() async {
    if (kIsWeb) return;
    try {
      await _prefs?.setString(
        _tierKey,
        _currentTier == SubscriptionTier.pro ? 'pro' : 'free',
      );
    } catch (e) {
      // Ignore storage errors
    }
  }

  /// Refresh subscription status from RevenueCat
  Future<void> _refreshFromRevenueCat() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      _updateTierFromCustomerInfo(customerInfo);
    } catch (e) {
      debugPrint('SubscriptionService: Error refreshing from RevenueCat: $e');
    }
  }

  // ============ Public API ============

  /// Current subscription tier
  SubscriptionTier get currentTier => _currentTier;

  /// Check if user has pro subscription
  bool get isPro => _currentTier == SubscriptionTier.pro;

  /// Check if user is on free tier
  bool get isFree => _currentTier == SubscriptionTier.free;

  /// Whether RevenueCat is available (real SDK vs mock)
  bool get isRevenueCatAvailable => _revenueCatAvailable;

  /// Purchase a subscription product
  /// Returns true if successful
  Future<bool> purchaseProduct(SubscriptionProduct product) async {
    if (!_revenueCatAvailable) {
      return _mockPurchase();
    }

    try {
      // Get the StoreProduct from RevenueCat
      final offerings = await getOfferings();
      if (offerings == null) return false;

      final currentOffering = offerings.current;
      if (currentOffering == null) return false;

      // Find the matching package
      Package? package;
      if (product.id == _RevenueCatConfig.monthlyProductId) {
        package = currentOffering.monthly;
      } else if (product.id == _RevenueCatConfig.yearlyProductId) {
        package = currentOffering.annual;
      }

      // Fallback: find by product identifier
      package ??= currentOffering.availablePackages.firstWhere(
        (p) => p.storeProduct.identifier == product.id,
        orElse: () => currentOffering!.availablePackages.first,
      );

      final customerInfo = await Purchases.purchasePackage(package);
      _updateTierFromCustomerInfo(customerInfo);
      _statusController.add(_currentTier);

      return isPro;
    } on PurchasesErrorCode catch (e) {
      if (e == PurchasesErrorCode.purchaseCancelledError) {
        debugPrint('SubscriptionService: Purchase cancelled by user');
        return false;
      }
      debugPrint('SubscriptionService: Purchase error: $e');
      return false;
    } catch (e) {
      debugPrint('SubscriptionService: Purchase error: $e');
      return false;
    }
  }

  /// Legacy purchase method for backward compatibility
  Future<bool> purchasePro() async {
    final products = await getProducts();
    if (products.isEmpty) return _mockPurchase();
    // Default to monthly
    return purchaseProduct(products.first);
  }

  /// Mock purchase for development/web
  Future<bool> _mockPurchase() async {
    await Future.delayed(const Duration(seconds: 2));
    _currentTier = SubscriptionTier.pro;
    await _persistTier();
    _statusController.add(_currentTier);
    return true;
  }

  /// Restore previous purchases
  Future<bool> restorePurchases() async {
    if (!_revenueCatAvailable) {
      // Mock: just return current state
      await Future.delayed(const Duration(seconds: 1));
      return isPro;
    }

    try {
      final customerInfo = await Purchases.restorePurchases();
      _updateTierFromCustomerInfo(customerInfo);
      _statusController.add(_currentTier);
      return isPro;
    } catch (e) {
      debugPrint('SubscriptionService: Restore error: $e');
      return false;
    }
  }

  /// Get available offerings from RevenueCat
  Future<Offerings?> getOfferings() async {
    if (!_revenueCatAvailable) return null;

    try {
      _offerings = await Purchases.getOfferings();
      return _offerings;
    } catch (e) {
      debugPrint('SubscriptionService: Error fetching offerings: $e');
      return null;
    }
  }

  /// Get available products/pricing
  /// Uses RevenueCat offerings when available, falls back to mock data
  Future<List<SubscriptionProduct>> getProducts() async {
    if (_revenueCatAvailable) {
      try {
        final offerings = await getOfferings();
        final current = offerings?.current;
        if (current != null) {
          return current.availablePackages.map((package) {
            final storeProduct = package.storeProduct;
            return SubscriptionProduct(
              id: storeProduct.identifier,
              name: storeProduct.title,
              description: storeProduct.description,
              price: storeProduct.priceString,
              priceValue: storeProduct.price,
              isBestValue: package.packageType == PackageType.annual,
              storeProduct: storeProduct,
            );
          }).toList();
        }
      } catch (e) {
        debugPrint('SubscriptionService: Error getting products: $e');
      }
    }

    // Fallback mock products
    return [
      SubscriptionProduct(
        id: _RevenueCatConfig.monthlyProductId,
        name: 'Pro Monthly',
        description: 'Full access to AI Assistant & premium features',
        price: '\$9.99/month',
        priceValue: 9.99,
      ),
      SubscriptionProduct(
        id: _RevenueCatConfig.yearlyProductId,
        name: 'Pro Yearly',
        description: 'Save 33% with annual billing',
        price: '\$79.99/year',
        priceValue: 79.99,
        isBestValue: true,
      ),
    ];
  }

  /// Refresh subscription status (check with RevenueCat or prefs)
  Future<void> refreshSubscriptionStatus() async {
    if (_revenueCatAvailable) {
      await _refreshFromRevenueCat();
    } else if (!kIsWeb) {
      await _loadFromPrefs();
    }
    _statusController.add(_currentTier);
  }

  /// Set the RevenueCat user ID (e.g. after login)
  Future<void> setUserId(String userId) async {
    if (!_revenueCatAvailable) return;
    try {
      await Purchases.logIn(userId);
      await _refreshFromRevenueCat();
    } catch (e) {
      debugPrint('SubscriptionService: Error setting user ID: $e');
    }
  }

  /// Reset subscription (for testing/logout)
  Future<void> reset() async {
    _currentTier = SubscriptionTier.free;
    _statusController.add(_currentTier);

    if (_revenueCatAvailable) {
      try {
        await Purchases.logOut();
      } catch (e) {
        debugPrint('SubscriptionService: Error logging out of RevenueCat: $e');
      }
    }

    if (!kIsWeb) {
      try {
        await _prefs?.remove(_tierKey);
      } catch (e) {
        // Ignore storage errors
      }
    }
  }

  /// List of features by tier
  static const Map<String, List<String>> features = {
    'free': [
      'Basic exercise library',
      'Daily check-ins',
      'Progress tracking',
      '3 AI questions per day',
    ],
    'pro': [
      'Full exercise library',
      'Advanced analytics',
      'Unlimited AI Assistant',
      'Personalized recommendations',
      'Priority support',
      'Offline access',
    ],
  };

  List<String> get freeFeatures => features['free']!;
  List<String> get proFeatures => features['pro']!;

  /// Dispose resources
  void dispose() {
    _statusController.close();
  }
}

/// Subscription product model
class SubscriptionProduct {
  final String id;
  final String name;
  final String description;
  final String price;
  final double priceValue;
  final bool isBestValue;
  
  /// RevenueCat store product (available when using real SDK)
  final StoreProduct? storeProduct;

  const SubscriptionProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.priceValue,
    this.isBestValue = false,
    this.storeProduct,
  });
}
