#!/bin/bash
# 🚀 Alzein ERP Ultra - Auto Project Setup Script
# يعمل على macOS/Linux. لـ Windows استخدم Git Bash أو WSL.

set -e

PROJECT_NAME="alzein-erp-ultra"
echo "📦 إنشاء هيكل المشروع: $PROJECT_NAME..."

# إنشاء المجلدات
mkdir -p "$PROJECT_NAME"/{css,js/{config,core,engines,modules,utils},assets,docs,.github/workflows}

# إنشاء الملفات الأساسية
cd "$PROJECT_NAME"

touch index.html
touch css/style.css
touch js/app.js
touch js/firebase-config.js
touch js/.env.example

touch js/config/{firestore-schema.js,roles-permissions.js}
touch js/core/{state-manager.js,error-handler.js,security.js,sync-manager.js}
touch js/engines/accounting-engine.js
touch js/modules/{inventory.js,accounting.js,calculator.js,currency.js}
touch js/utils/{crypto-helper.js,validators.js}

touch assets/{icon-192.png,icon-512.png,logo.svg}
touch docs/{API.md,DEPLOYMENT.md,firestore.rules}
touch .github/workflows/auto-format.yml

# إنشاء .gitignore
cat > .gitignore << 'EOF'
js/.env
.env
.env.local
.env.production
.DS_Store
Thumbs.db
.idea/
.vscode/
*.swp
*.swo
*.log
logs/
node_modules/
dist/
build/
alzein_*.json
*.json.bak
user_data/
EOF

# إنشاء README.md
cat > README.md << 'EOF'
# 💎 Alzein ERP Ultra
> نظام إدارة أعمال سحابي بواجهة Neon Cyber | Vanilla JS + Firebase + Offline-First

## 🚀 التشغيل
```bash
python -m http.server 8000
# أو استخدم VS Code Live Server
