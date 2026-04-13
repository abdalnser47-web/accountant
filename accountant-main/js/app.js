/**
 * Alzein ERP Ultra - Main Application Entry Point
 * Vanilla JS + Modular Architecture
 */

// ========================================
// State Management Simple
// ========================================

const AppState = {
  currentUser: null,
  activeView: 'dashboard',
  connectionStatus: 'online',
  
  // دالة التحديث
  update(key, value) {
    this[key] = value;
    this.notify(key, value);
  },
  
  // إشعار التغييرات
  notify(key, value) {
    window.dispatchEvent(new CustomEvent(`state:${key}`, { detail: value }));
  }
};

// ========================================
// UI Controllers
// ========================================

const UI = {
  // تهيئة الواجهة
  init() {
    this.cacheDOM();
    this.bindEvents();
    this.updateConnectionStatus();
    console.log('✅ UI Initialized');
  },
  
  // حفظ العناصر في الذاكرة
  cacheDOM() {
    this.mainView = document.getElementById('main-view');
    this.navButtons = document.querySelectorAll('.nav-btn');
    this.connectionStatus = document.getElementById('connection-status');
    this.calculatorFab = document.getElementById('calculator-fab');
    this.userInfo = document.getElementById('user-info');
  },
  
  // ربط الأحداث
  bindEvents() {
    // التنقل بين الشاشات
    this.navButtons.forEach(btn => {
      btn.addEventListener('click', (e) => this.handleNavigation(e));
    });
    
    // زر الحاسبة العائم
    if (this.calculatorFab) {
      this.calculatorFab.addEventListener('click', () => this.toggleCalculator());
    }
    
    // مراقبة حالة الاتصال
    window.addEventListener('online', () => this.updateConnectionStatus(true));
    window.addEventListener('offline', () => this.updateConnectionStatus(false));
  },
  
  // معالجة التنقل
  handleNavigation(e) {
    const view = e.currentTarget.dataset.view;
    
    // تحديث الأزرار النشطة
    this.navButtons.forEach(btn => btn.classList.remove('active'));
    e.currentTarget.classList.add('active');
    
    // تحديث العرض
    this.renderView(view);
    AppState.update('activeView', view);
  },
  
  // عرض الشاشة المطلوبة
  renderView(viewName) {
    const views = {
      dashboard: this.renderDashboard(),
      inventory: this.renderInventory(),
      accounting: this.renderAccounting(),
      tools: this.renderTools()
    };
    
    if (this.mainView) {
      this.mainView.innerHTML = views[viewName] || views.dashboard;
      this.animateEntry();
    }
  },
  
  // عرض لوحة التحكم
  renderDashboard() {
    return `
      <div class="dashboard-view">
        <div class="welcome-card rgb-glow">
          <h2>📊 لوحة التحكم</h2>
          <p>نظرة عامة على نشاطك التجاري</p>
        </div>
        
        <div class="stats-grid">
          <div class="stat-card neon-border">
            <div class="stat-icon">📦</div>
            <div class="stat-value">0</div>
            <div class="stat-label">إجمالي الأصناف</div>
          </div>
          
          <div class="stat-card neon-border">
            <div class="stat-icon">💰</div>
            <div class="stat-value">$0.00</div>
            <div class="stat-label">الرصيد الحالي</div>
          </div>
          
          <div class="stat-card neon-border">
            <div class="stat-icon">📈</div>
            <div class="stat-value">0</div>
            <div class="stat-label">المعاملات اليوم</div>
          </div>
        </div>
      </div>
    `;
  },
  
  // عرض المخزون
  renderInventory() {
    return `
      <div class="inventory-view">
        <div class="welcome-card rgb-glow">
          <h2>📦 إدارة المخزون</h2>
          <p>متابعة الأصناف والكميات</p>
        </div>
        <div class="info-message">جاري تحميل وحدة المخزون...</div>
      </div>
    `;
  },
  
  // عرض المحاسبة
  renderAccounting() {
    return `
      <div class="accounting-view">
        <div class="welcome-card rgb-glow">
          <h2>💰 المحاسبة المالية</h2>
          <p>إدارة الحسابات والمعاملات</p>
        </div>
        <div class="info-message">جاري تحميل وحدة المحاسبة...</div>
      </div>
    `;
  },
  
  // عرض الأدوات
  renderTools() {
    return `
      <div class="tools-view">
        <div class="welcome-card rgb-glow">
          <h2>🔧 الأدوات الذكية</h2>
          <p>حاسبة، محول عملات، والمزيد</p>
        </div>
        <div class="info-message">جاري تحميل الأدوات...</div>
      </div>
    `;
  },
  
  // تأثير الدخول
  animateEntry() {
    const cards = document.querySelectorAll('.welcome-card, .stat-card');
    cards.forEach((card, index) => {
      card.style.animation = `slideUp 0.5s ease ${index * 0.1}s both`;
    });
  },
  
  // تحديث حالة الاتصال
  updateConnectionStatus(isOnline = navigator.onLine) {
    if (this.connectionStatus) {
      if (isOnline) {
        this.connectionStatus.textContent = '🟢 متصل';
        this.connectionStatus.style.background = 'rgba(0, 255, 136, 0.2)';
        this.connectionStatus.style.color = 'var(--neon-green)';
        this.connectionStatus.style.borderColor = 'var(--neon-green)';
      } else {
        this.connectionStatus.textContent = '🔴 غير متصل';
        this.connectionStatus.style.background = 'rgba(255, 0, 85, 0.2)';
        this.connectionStatus.style.color = '#ff0055';
        this.connectionStatus.style.borderColor = '#ff0055';
      }
    }
    AppState.update('connectionStatus', isOnline ? 'online' : 'offline');
  },
  
  // تبديل الحاسبة
  toggleCalculator() {
    console.log('🧮 Calculator toggled');
    showToast('جاري فتح الحاسبة...', 'info');
  }
};

// ========================================
// Utility Functions
// ========================================

function showToast(message, type = 'info') {
  // إنشاء عنصر Toast
  const toast = document.createElement('div');
  toast.className = `toast toast-${type}`;
  toast.textContent = message;
  toast.style.cssText = `
    position: fixed;
    top: 20px;
    left: 50%;
    transform: translateX(-50%);
    background: var(--card-bg);
    border: 2px solid var(--neon-cyan);
    color: var(--text-primary);
    padding: 1rem 2rem;
    border-radius: 8px;
    z-index: 9999;
    animation: slideUp 0.3s ease;
    box-shadow: var(--shadow-neon);
  `;
  
  document.body.appendChild(toast);
  
  // إخفاء بعد 3 ثواني
  setTimeout(() => {
    toast.style.animation = 'slideUp 0.3s ease reverse';
    setTimeout(() => toast.remove(), 300);
  }, 3000);
}

function formatCurrency(amount, currency = 'USD') {
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: currency
  }).format(amount);
}

function generateId() {
  return Date.now().toString(36) + Math.random().toString(36).substr(2);
}

// ========================================
// Initialization
// ========================================

document.addEventListener('DOMContentLoaded', () => {
  console.log('🚀 Alzein ERP Ultra Starting...');
  
  // تهيئة الواجهة
  UI.init();
  
  // إظهار رسالة ترحيب
  setTimeout(() => {
    showToast('مرحباً بك في Alzein ERP Ultra! ✨', 'success');
  }, 500);
  
  console.log('✅ Application Ready');
});

// ========================================
// Error Handling
// ========================================

window.addEventListener('error', (e) => {
  console.error('Application Error:', e.error);
  showToast('حدث خطأ غير متوقع', 'error');
});

window.addEventListener('unhandledrejection', (e) => {
  console.error('Unhandled Promise:', e.reason);
});
🚀 إضافة الملف الرئيسي للتطبيق (app.js)
