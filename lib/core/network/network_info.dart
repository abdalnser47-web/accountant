import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../constants/app_constants.dart';

/// خدمة الاتصال وإدارة Firebase والاتصال بالإنترنت
class NetworkInfo {
  final Connectivity _connectivity;
  
  NetworkInfo(this._connectivity);
  
  /// التحقق من وجود اتصال بالإنترنت
  Future<bool> get isConnected async {
    final connectivityResult = await _connectivity.checkConnectivity();
    return !connectivityResult.contains(ConnectivityResult.none);
  }
  
  /// الاستماع لتغيرات الاتصال
  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map((result) {
      return !result.contains(ConnectivityResult.none);
    });
  }
}

/// خدمة Firebase للإعدادات الأولية
class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  // Getter methods
  FirebaseAuth get auth => _auth;
  FirebaseFirestore get firestore => _firestore;
  FirebaseStorage get storage => _storage;
  
  // Current user
  User? get currentUser => _auth.currentUser;
  
  // Check if user is signed in
  bool get isSignedIn => currentUser != null;
  
  // User ID
  String? get userId => currentUser?.uid;
  
  /// تهيئة إعدادات Firestore
  void configureFirestore() {
    // تمكين التخزين المؤقت المحلي
    _firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
    
    // إعدادات الأداء
    _firestore.enablePersistence().catchError((error) {
      print('Error enabling persistence: $error');
    });
  }
  
  /// تسجيل مستخدم جديد
  Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // تحديث اسم العرض
      await credential.user?.updateDisplayName(displayName);
      
      // إنشاء سجل المستخدم في Firestore
      if (credential.user != null) {
        await _firestore.collection('users').doc(credential.user!.uid).set({
          'email': email,
          'displayName': displayName,
          'createdAt': FieldValue.serverTimestamp(),
          'isPremium': false,
          'currency': 'SAR',
          'language': 'ar',
        });
      }
      
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }
  
  /// تسجيل الدخول
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }
  
  /// تسجيل الخروج
  Future<void> signOut() async {
    await _auth.signOut();
  }
  
  /// إعادة تعيين كلمة المرور
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }
  
  /// معالجة استثناءات المصادقة
  Exception _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return Exception('كلمة المرور ضعيفة جداً');
      case 'email-already-in-use':
        return Exception('البريد الإلكتروني مستخدم بالفعل');
      case 'user-not-found':
        return Exception('المستخدم غير موجود');
      case 'wrong-password':
        return Exception('كلمة المرور غير صحيحة');
      case 'invalid-email':
        return Exception('البريد الإلكتروني غير صالح');
      case 'user-disabled':
        return Exception('تم تعطيل هذا الحساب');
      case 'too-many-requests':
        return Exception('محاولات كثيرة، يرجى المحاولة لاحقاً');
      default:
        return Exception(e.message ?? 'حدث خطأ غير متوقع');
    }
  }
  
  /// الحصول على مرجع لمجموعة المستخدم
  CollectionReference getUserCollection(String collectionName) {
    if (userId == null) {
      throw Exception('المستخدم غير مسجل الدخول');
    }
    return _firestore.collection('users').doc(userId).collection(collectionName);
  }
  
  /// رفع ملف إلى Firebase Storage
  Future<String> uploadFile({
    required String path,
    required String filePath,
  }) async {
    try {
      final file = await _storage.ref(path).putFile(filePath as dynamic);
      return await file.ref.getDownloadURL();
    } catch (e) {
      throw Exception('فشل رفع الملف: $e');
    }
  }
}
