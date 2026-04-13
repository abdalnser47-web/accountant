@echo off
echo 📦 جاري إنشاء هيكل المشروع...
mkdir css js\config js\core js\engines js\modules js\utils assets docs .github\workflows
type nul > index.html
type nul > css\style.css
type nul > js\app.js
type nul > js\firebase-config.js
type nul > js\.env.example
type nul > README.md
type nul > .gitignore
type nul > manifest.json
type nul > sw.js
echo ✅ تم إنشاء الهيكل بنجاح! يمكنك إغلاق هذه النافذة.
pause