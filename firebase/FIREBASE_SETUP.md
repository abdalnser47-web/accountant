# 🔥 Firebase Setup Guide - Finance Manager App

## إعداد مشروع Firebase

### الخطوة 1: إنشاء مشروع Firebase
1. اذهب إلى [Firebase Console](https://console.firebase.google.com/)
2. اضغط على **Add Project**
3. أدخل اسم المشروع: `Finance Manager` أو `expense-manager-xxxxx`
4. فعّل Google Analytics (اختياري لكن موصى به)
5. اضغط **Create Project**

---

### الخطوة 2: إضافة تطبيق Android

1. في Firebase Console، اضغط على أيقونة **Android**
2. أدخل حزمة التطبيق: `com.yourcompany.expense_manager`
3. حمّل ملف `google-services.json`
4. انقل الملف إلى المسار:
   ```
   android/app/google-services.json
   ```

5. أضف dependencies في `android/build.gradle`:
```gradle
buildscript {
  dependencies {
    // ...
    classpath 'com.google.gms:google-services:4.4.0'
  }
}
```

6. في `android/app/build.gradle`:
```gradle
apply plugin: 'com.google.gms.google-services'
```

---

### الخطوة 3: إضافة تطبيق iOS

1. في Firebase Console، اضغط على أيقونة **iOS**
2. أدخل Bundle ID: `com.yourcompany.expenseManager`
3. حمّل ملف `GoogleService-Info.plist`
4. انقل الملف إلى:
   ```
   ios/Runner/GoogleService-Info.plist
   ```

5. في `ios/Runner/AppDelegate.swift`:
```swift
import FirebaseCore

@main
class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

6. في `ios/Podfile`:
```ruby
platform :ios, '12.0'
pod 'Firebase/Analytics'
pod 'Firebase/Auth'
pod 'Firebase/Firestore'
```

ثم نفذ:
```bash
cd ios && pod install
```

---

### الخطوة 4: تفعيل خدمات Firebase

#### A. Firebase Authentication
1. اذهب إلى **Authentication** في Firebase Console
2. اضغط **Get Started**
3. فعّل طرق التسجيل:
   - ✅ Email/Password
   - ✅ Google (اختياري)
   - ✅ Apple (لـ iOS فقط)

#### B. Cloud Firestore Database
1. اذهب إلى **Firestore Database**
2. اضغط **Create Database**
3. اختر وضع الاختبار أولاً (**Start in Test Mode**)
4. اختر المنطقة: `us-central` أو الأقرب لك

#### C. Firebase Storage (للنسخ الاحتياطي)
1. اذهب إلى **Storage**
2. اضغط **Get Started**
3. ابدأ بوضع الاختبار

#### D. Firebase Analytics
1. اذهب إلى **Analytics**
2. سيتم تفعيله تلقائياً عند تشغيل التطبيق

#### E. Cloud Messaging (للإشعارات)
1. اذهب إلى **Cloud Messaging**
2. احتفظ بـ **Server Key** للإشعارات اللاحقة

---

### الخطوة 5: قواعد الأمان (Security Rules)

#### Firestore Rules (`firestore.rules`):
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Users can only access their own data
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Public categories (read-only for all authenticated users)
    match /categories/{categoryId} {
      allow read: if request.auth != null;
      allow write: if false; // Only admins can modify
    }
  }
}
```

#### Storage Rules (`storage.rules`):
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /backups/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

---

### الخطوة 6: تحميل القواعد إلى Firebase

نفذ الأوامر التالية بعد تثبيت Firebase CLI:

```bash
# تثبيت Firebase CLI
npm install -g firebase-tools

# تسجيل الدخول
firebase login

# تهيئة المشروع (من مجلد project root)
firebase init

# اختر:
# - Firestore
# - Storage
# - Functions (اختياري)

# نشر القواعد
firebase deploy --only firestore:rules
firebase deploy --only storage:rules
```

---

### الخطوة 7: اختبار الاتصال

بعد إعداد كل شيء، شغّل التطبيق وتحقق من:

1. ✅ لا توجد أخطاء في Console
2. ✅ يمكن تسجيل الدخول
3. ✅ البيانات تُحفظ في Firestore
4. ✅ يعمل Offline First

---

## 📁 هيكل ملفات Firebase

```
firebase/
├── firestore.rules          # قواعد Firestore
├── storage.rules            # قواعد Storage
├── firestore.indexes.json   # الفهارس المخصصة
└── firebase.json            # إعدادات Firebase
```

---

## 🔐 ملاحظات أمنية مهمة

1. **لا ترفع مفاتيح API إلى GitHub**
   - أضف `google-services.json` و `GoogleService-Info.plist` إلى `.gitignore`
   
2. **استخدم Firebase App Check** لحماية تطبيقك من الوصول غير المصرح به

3. **فعّل Multi-Factor Authentication** للحسابات المهمة

---

## 🚀 الخطوات التالية

بعد إعداد Firebase:
1. ربط المصادقة في التطبيق
2. تنفيذ المزامنة بين Local (Drift) و Remote (Firestore)
3. إضافة النسخ الاحتياطي التلقائي
4. تفعيل الإشعارات

---

## 📞 الدعم

إذا واجهت أي مشكلة:
- راجع [Firebase Documentation](https://firebase.google.com/docs)
- تحقق من Firebase Console > Diagnostics
- تأكد من تحديث dependencies في `pubspec.yaml`
