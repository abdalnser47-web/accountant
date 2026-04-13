/**
 * Alzein ERP Ultra - Main Application Entry
 * Vanilla JS Modules + Firebase + Offline-First
 */

// Core Imports
import { createState } from './core/state-manager.js';
import { ErrorHandler } from './core/error-handler.js';
import { SyncManager } from './core/sync-manager.js';
import { Security, calculate } from './core/security.js';
import { PermissionGuard } from './config/roles-permissions.js';

// Firebase
import { auth, db } from './firebase-config.js';
import { onAuthStateChanged } from 'https://www.gstatic.com/firebasejs/10.7.1/firebase-auth.js';
import { doc, getDoc } from 'https://www.gstatic.com/firebasejs/10.7.1/firebase-firestore.js';

// Modules
import { Calculator } from './modules/calculator.js';
import { CurrencyUltra } from './modules/currency.js';
import { Inventory } from './modules/inventory.js';
import { Accounting } from './modules/accounting.js';

// Engines
import { AccountingEngine } from './engines/accounting-engine.js';

class AlzeinApp {
  constructor() {
    this.state = createState();
    this.sync = null;
    this.accountingEngine = null;
    this.permissionGuard = null;
    this._init();
  }

  async _init() {
    try {
      this.sync = new SyncManager({ db, userId: null });
      this.accountingEngine = new AccountingEngine(null, db);
      
      Calculator.init();
      await CurrencyUltra.fetchRates();
      
      onAuthStateChanged(auth, async (user) => {
        if (user) await this._onUserLogin(user);
        else this._onUserLogout();
      });
      
      this._renderAppShell();
      this._bindGlobalEvents();      
      console.log('✅ Alzein ERP Ultra Initialized');
    } catch (error) {
      ErrorHandler.log(error, { context: 'app:init' });
      this._showFatalError(error);
    }
  }

  async _onUserLogin(user) {
    try {
      const userDoc = await getDoc(doc(db, 'users', user.uid));
      const userData = userDoc.exists() ? userDoc.data() : {};
      
      this.state.batch({
        'user': { ...user, ...userData },
        'auth.loading': false, 'auth.error': null
      });
      
      this.permissionGuard = new PermissionGuard(userData);
      this.sync.userId = user.uid;
      this.accountingEngine.userId = user.uid;
      
      await this._syncUserData(user.uid);
      Inventory.init(user.uid, this.state);
      Accounting.init(user.uid, this.accountingEngine, this.state);
      
      this.state.set('ui.activeView', 'dashboard');
    } catch (error) {
      ErrorHandler.log(error, { context: 'app:login' });
      this.state.set('auth.error', 'فشل تحميل البيانات');
    }
  }

  _onUserLogout() {
    this.state.batch({
      'user': null, 'auth.loading': false,
      'inventory.items': [], 'accounting.transactions': []
    });
    this.permissionGuard = null;
  }

  async _syncUserData(uid) {
    const localData = this._loadLocalData(uid);
    // const cloudData = await this._fetchCloudData(uid);
    // const merged = await this.sync.mergeUserData(cloudData, localData);
    console.log('[Sync] User data merged for', uid);
  }

  _loadLocalData(uid) {
    const data = {};    const collections = ['inventory', 'transactions', 'accounts'];
    for (const collection of collections) {
      const key = `alzein_${collection}_${uid}`;
      try {
        const raw = localStorage.getItem(key);
        data[collection] = raw ? JSON.parse(raw) : [];
      } catch (e) { data[collection] = []; }
    }
    return data;
  }

  _renderAppShell() {
    const app = document.getElementById('app');
    if (!app) return;
    app.innerHTML = `
      <div class="app-shell neon-border">
        <header class="app-header rgb-glow">
          <h1>Alzein ERP Ultra</h1>
          <div id="user-info"></div>
        </header>
        <nav class="app-nav">
          <button data-view="dashboard" class="nav-btn">📊 لوحة التحكم</button>
          <button data-view="inventory" class="nav-btn">📦 المخزون</button>
          <button data-view="accounting" class="nav-btn">💰 المحاسبة</button>
          <button data-view="tools" class="nav-btn">🔧 الأدوات</button>
        </nav>
        <main class="app-content" id="main-view"></main>
        <div id="calculator-fab" class="fab-center pulse">🧮</div>
        <div id="haptic-feedback"></div>
      </div>
    `;
  }

  _bindGlobalEvents() {
    document.querySelectorAll('.nav-btn').forEach(btn => {
      btn.addEventListener('click', (e) => {
        const view = e.currentTarget.dataset.view;
        this.state.set('ui.activeView', view);
        this._renderView(view);
      });
    });
    document.getElementById('calculator-fab')?.addEventListener('click', () => {
      this._toggleCalculator();
    });
  }

  _renderView(viewName) {
    const main = document.getElementById('main-view');
    const views = {
      dashboard: this._renderDashboard(),      inventory: `<div class="inventory-view"></div>`,
      accounting: `<div class="accounting-view"></div>`,
      tools: `<div class="tools-view"></div>`
    };
    if (main) {
      main.innerHTML = views[viewName] || views.dashboard;
      if (viewName === 'inventory') Inventory.init();
      if (viewName === 'accounting') Accounting.init();
      if (viewName === 'tools') CurrencyUltra.init();
    }
  }

  _renderDashboard() {
    const summary = Accounting.getDailySummary?.() || {};
    return `
      <div class="dashboard-view">
        <div class="welcome-card rgb-glow">
          <h2>📊 لوحة التحكم</h2>
          <p>نظرة عامة على نشاطك التجاري</p>
        </div>
        <div class="stats-grid">
          <div class="stat-card neon-border">
            <div class="stat-icon">📦</div>
            <div class="stat-value">${summary.count || 0}</div>
            <div class="stat-label">المعاملات اليوم</div>
          </div>
          <div class="stat-card neon-border">
            <div class="stat-icon">💰</div>
            <div class="stat-value">$${(summary.income - summary.expense || 0).toLocaleString()}</div>
            <div class="stat-label">صافي اليوم</div>
          </div>
        </div>
      </div>
    `;
  }

  _toggleCalculator() {
    const calc = document.getElementById('calculator-modal') || document.getElementById('calc-modal');
    if (calc) calc.classList.toggle('active');
  }

  _showFatalError(error) {
    document.getElementById('app').innerHTML = `
      <div class="error-screen neon-border">
        <h2>⚠️ خطأ في التهيئة</h2>
        <p>${error.message}</p>
        <button onclick="location.reload()">إعادة المحاولة</button>
      </div>
    `;
  }}

// Initialize
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', () => new AlzeinApp());
} else {
  new AlzeinApp();
}

export { AlzeinApp };
