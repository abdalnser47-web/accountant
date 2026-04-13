/**
 * Alzein ERP Ultra - Firebase Configuration
 * يربط التطبيق بخدمات Google (قاعدة البيانات والمصادقة)
 */

import { initializeApp } from "https://www.gstatic.com/firebasejs/10.7.1/firebase-app.js";
import { getAuth } from "https://www.gstatic.com/firebasejs/10.7.1/firebase-auth.js";
import { getFirestore } from "https://www.gstatic.com/firebasejs/10.7.1/firebase-firestore.js";

// ========================================
// 🔧 إعدادات المشروع (Firebase Config)
// ========================================
// ⚠️ هام: لاحقاً ستستبدل هذه القيم ببيانات مشروعك الحقيقي من Firebase Console
const firebaseConfig = {
    apiKey: "AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
    authDomain: "YOUR_PROJECT.firebaseapp.com",
    projectId: "YOUR_PROJECT_ID",
    storageBucket: "YOUR_PROJECT.appspot.com",
    messagingSenderId: "123456789012",
    appId: "1:123456789012:web:abc123def456"
};

// تهيئة التطبيق
const app = initializeApp(firebaseConfig);

// تصدير الخدمات لاستخدامها في باقي الملفات
export const auth = getAuth(app);
export const db = getFirestore(app);

// رسالة تأكيد في الكونسول
console.log('🔥 Firebase Connected Successfully');
🔗 إعداد ربط Firebase (Auth & Firestore)
