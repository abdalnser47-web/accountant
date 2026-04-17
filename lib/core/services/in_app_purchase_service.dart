import 'package:in_app_purchase/in_app_purchase.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';

/// خدمة الاشتراكات والشراء داخل التطبيق
class InAppPurchaseService {
  static final InAppPurchaseService _instance = InAppPurchaseService._internal();
  factory InAppPurchaseService() => _instance;
  InAppPurchaseService._internal();
  
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  
  // معرفات المنتجات (استبدلها بمعرفاتك الحقيقية من Google Play Console / App Store Connect)
  static const String _premiumMonthlyId = 'com.expensemanager.premium.monthly';
  static const String _premiumYearlyId = 'com.expensemanager.premium.yearly';
  static const String _removeAdsId = 'com.expensemanager.remove_ads';
  
  bool _isAvailable = false;
  bool _isLoading = false;
  List<ProductDetails> _products = [];
  bool _isPremium = false;
  
  /// تهيئة خدمة الشراء
  Future<void> initialize() async {
    _isLoading = true;
    
    try {
      // التحقق من توفر الشراء داخل التطبيق
      final isAvailable = await _inAppPurchase.isAvailable();
      _isAvailable = isAvailable;
      
      if (!isAvailable) {
        debugPrint('In-app purchases are not available');
        return;
      }
      
      // تحميل قائمة المنتجات
      await loadProducts();
      
      // الاستماع لتحديثات الشراء
      _listenToPurchaseUpdates();
      
      // استعادة المشتريات السابقة
      await restorePurchases();
      
    } catch (e) {
      debugPrint('Error initializing in-app purchases: $e');
    } finally {
      _isLoading = false;
    }
  }
  
  /// تحميل المنتجات
  Future<void> loadProducts() async {
    try {
      final response = await _inAppPurchase.queryProductDetails({
        _premiumMonthlyId,
        _premiumYearlyId,
        _removeAdsId,
      });
      
      if (response.error != null) {
        debugPrint('Error loading products: ${response.error}');
        return;
      }
      
      _products = response.productDetails.toList();
      debugPrint('Loaded ${_products.length} products');
      
    } catch (e) {
      debugPrint('Error loading products: $e');
    }
  }
  
  /// الاستماع لتحديثات الشراء
  void _listenToPurchaseUpdates() {
    _subscription = _inAppPurchase.purchaseStream.listen(
      (purchaseDetailsList) {
        for (var purchaseDetails in purchaseDetailsList) {
          _handlePurchase(purchaseDetails);
        }
      },
      onDone: () {
        _subscription?.cancel();
      },
      onError: (error) {
        debugPrint('Error in purchase stream: $error');
      },
    );
  }
  
  /// معالجة عملية الشراء
  void _handlePurchase(PurchaseDetails purchaseDetails) {
    if (purchaseDetails.status == PurchaseStatus.purchased ||
        purchaseDetails.status == PurchaseStatus.restored) {
      
      // تفعيل الميزة المشتراة
      _activatePremium(purchaseDetails.productID);
      
      // إتمام العملية
      if (purchaseDetails.pendingCompletePurchase) {
        _inAppPurchase.completePurchase(purchaseDetails);
      }
      
    } else if (purchaseDetails.status == PurchaseStatus.error) {
      debugPrint('Purchase error: ${purchaseDetails.error}');
    } else if (purchaseDetails.status == PurchaseStatus.canceled) {
      debugPrint('Purchase canceled');
    }
  }
  
  /// تفعيل حالة Premium
  void _activatePremium(String productId) {
    if (productId == _premiumMonthlyId || 
        productId == _premiumYearlyId || 
        productId == _removeAdsId) {
      _isPremium = true;
      debugPrint('Premium activated: $productId');
      
      // حفظ الحالة في SharedPreferences أو قاعدة البيانات
      _savePremiumStatus(true);
    }
  }
  
  /// شراء منتج
  Future<bool> purchaseProduct(String productId) async {
    if (!_isAvailable) {
      debugPrint('In-app purchases not available');
      return false;
    }
    
    try {
      final productDetails = _products.firstWhere(
        (product) => product.id == productId,
        orElse: () => throw Exception('Product not found'),
      );
      
      final purchaseParam = PurchaseParam(productDetails: productDetails);
      
      if (productId.contains('monthly') || productId.contains('yearly')) {
        // اشتراك
        await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      } else {
        // شراء لمرة واحدة
        await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      }
      
      return true;
      
    } catch (e) {
      debugPrint('Error purchasing product: $e');
      return false;
    }
  }
  
  /// شراء الاشتراك الشهري
  Future<bool> buyPremiumMonthly() {
    return purchaseProduct(_premiumMonthlyId);
  }
  
  /// شراء الاشتراك السنوي
  Future<bool> buyPremiumYearly() {
    return purchaseProduct(_premiumYearlyId);
  }
  
  /// شراء إزالة الإعلانات
  Future<bool> buyRemoveAds() {
    return purchaseProduct(_removeAdsId);
  }
  
  /// استعادة المشتريات السابقة
  Future<void> restorePurchases() async {
    if (!_isAvailable) return;
    
    try {
      await _inAppPurchase.restorePurchases();
      debugPrint('Restore purchases requested');
    } catch (e) {
      debugPrint('Error restoring purchases: $e');
    }
  }
  
  /// حفظ حالة Premium
  Future<void> _savePremiumStatus(bool isPremium) async {
    // استخدام SharedPreferences لحفظ الحالة
    // سيتم تنفيذ هذا في implementation كامل
    debugPrint('Saving premium status: $isPremium');
  }
  
  /// التحقق من حالة Premium
  Future<bool> checkPremiumStatus() async {
    // قراءة الحالة من SharedPreferences
    return _isPremium;
  }
  
  /// الحصول على قائمة المنتجات
  List<ProductDetails> get products => _products;
  
  /// هل الخدمة متاحة؟
  bool get isAvailable => _isAvailable;
  
  /// هل يتم التحميل؟
  bool get isLoading => _isLoading;
  
  /// هل المستخدم Premium؟
  bool get isPremium => _isPremium;
  
  /// تنظيف الموارد
  void dispose() {
    _subscription?.cancel();
  }
}
