/**
 * Alzein ERP Ultra - Main Application Entry
 * Vanilla JS Modules Architecture
 * State Management + Event Delegation
 */

// Import utilities
import { StorageUtils } from './utils/storage.js';
import { CryptoUtils } from './utils/crypto.js';
import { showToast } from './utils/toast.js';

// Import modules (to be implemented)
// import { Auth } from './modules/auth.js';
// import { Accounting } from './modules/accounting.js';
// import { CurrencyUltra } from './modules/currency.js';
// import { Calculator } from './modules/calculator.js';

// Application State
const AppState = {
    user: null,
    pin: null,
    privacyMode: false,
    defaultCurrency: 'USD',
    exchangeRates: {},
    data: {
        people: [],
        transactions: [],
        accounts: [],
        settings: {}
    },
    ui: {
        currentScreen: 'dashboard',
        modals: {}
    }
};

// DOM Cache
const DOM = {
    app: null,
    screens: {},
    loading: null,
    toastContainer: null,
    fab: null,
    privacyToggle: null
};

/**
 * Main Application Class
 */
class AlzeinApp {
    constructor() {
        this.state = AppState;
        this.dom = DOM;
        this.initialized = false;
    }

    /**
     * Initialize Application
     */
    async init() {
        console.log('🚀 Alzein ERP Ultra - Initializing...');
        
        // Cache DOM elements
        this.cacheDOM();
        
        // Load persisted state
        await this.loadState();
        
        // Apply privacy mode if saved
        this.applyPrivacyMode(this.state.privacyMode);
        
        // Setup event listeners
        this.bindEvents();
        
        // Hide loading screen
        this.hideLoading();
        
        // Show appropriate screen
        this.showScreen(this.state.user ? 'dashboard' : 'pin');
        
        this.initialized = true;
        console.log('✅ Alzein ERP Ultra - Ready');
        
        // Dispatch ready event for modules
        document.dispatchEvent(new CustomEvent('alzein:ready', { detail: this.state }));
    }

    /**
     * Cache DOM Elements
     */
    cacheDOM() {
        this.dom.app = document.getElementById('app');
        this.dom.loading = document.getElementById('loading-screen');
        this.dom.toastContainer = document.getElementById('toast-container');
        this.dom.fab = document.getElementById('fab-add');
        this.dom.privacyToggle = document.getElementById('privacy-toggle');
        
        // Cache screens
        document.querySelectorAll('.screen').forEach(screen => {
            this.dom.screens[screen.id.replace('-screen', '')] = screen;
        });
    }

    /**
     * Load State from Storage
     */
    async loadState() {
        // Load PIN (encrypted)
        const encryptedPin = StorageUtils.get('pin', { decrypt: true });
        if (encryptedPin) {
            this.state.pin = encryptedPin;
        }
        
        // Load user data
        const userData = StorageUtils.get('user_data');
        if (userData) {
            this.state.data = { ...this.state.data, ...userData };
            this.state.user = { id: 'local_user' }; // Mock authenticated
        }
        
        // Load settings
        const settings = StorageUtils.get('settings');
        if (settings) {
            this.state.defaultCurrency = settings.defaultCurrency || 'USD';
            this.state.privacyMode = settings.privacyMode || false;
            this.state.exchangeRates = settings.exchangeRates || {};
        }
        
        // Load exchange rates cache
        const ratesCache = StorageUtils.get('currency_rates');
        if (ratesCache?.rates) {
            this.state.exchangeRates = ratesCache.rates;
        }
    }

    /**
     * Bind Global Event Listeners
     */
    bindEvents() {
        // Privacy Toggle
        this.dom.privacyToggle?.addEventListener('click', () => {
            this.state.privacyMode = !this.state.privacyMode;
            this.applyPrivacyMode(this.state.privacyMode);
            this.saveSettings();
            showToast(
                this.state.privacyMode ? '🔒 وضع الخصوصية: مفعل' : '👁️ وضع الخصوصية: معطل',
                'info'
            );
        });

        // FAB Button
        this.dom.fab?.addEventListener('click', () => {
            this.openModal('transaction-form');
        });

        // Bottom Navigation
        document.querySelectorAll('.nav-item').forEach(btn => {
            btn.addEventListener('click', (e) => {
                const screen = e.currentTarget.dataset.screen;
                this.navigate(screen);
            });
        });

        // Modal Close Buttons
        document.addEventListener('click', (e) => {
            if (e.target.classList.contains('modal-close') || 
                e.target.classList.contains('modal')) {
                this.closeModal();
            }
        });

        // Keyboard support for PIN
        document.addEventListener('keydown', (e) => {
            if (this.dom.screens.pin?.classList.contains('hidden')) return;
            
            if (e.key >= '0' && e.key <= '9') {
                this.handlePinInput(e.key);
            } else if (e.key === 'Backspace') {
                this.handlePinBackspace();
            } else if (e.key === 'Enter') {
                this.verifyPIN();
            }
        });

        // Online/Offline Detection
        window.addEventListener('online', () => {
            console.log('🌐 Online');
            showToast('🔄 متصل بالإنترنت', 'success');
            // Trigger sync if needed
        });
        
        window.addEventListener('offline', () => {
            console.log('📴 Offline');
            showToast('⚠️ وضع غير متصل', 'warning');
        });
    }

    /**
     * Navigation
     */
    navigate(screenName) {
        if (!this.dom.screens[screenName]) {
            console.warn(`Screen "${screenName}" not found`);
            return;
        }
        
        // Update nav active state
        document.querySelectorAll('.nav-item').forEach(btn => {
            btn.classList.toggle('active', btn.dataset.screen === screenName);
        });
        
        this.showScreen(screenName);
        this.state.ui.currentScreen = screenName;
    }

    showScreen(screenName) {
        // Hide all screens
        Object.values(this.dom.screens).forEach(screen => {
            screen.classList.add('hidden');
        });
        
        // Show target screen
        const target = this.dom.screens[screenName];
        if (target) {
            target.classList.remove('hidden');
            // Refresh screen content if needed
            if (screenName === 'dashboard') {
                this.refreshDashboard();
            }
        }
    }

    /**
     * PIN System
     */
    handlePinInput(digit) {
        const inputs = document.querySelectorAll('.pin-digit');
        const emptyIndex = Array.from(inputs).findIndex(inp => !inp.value);
        
        if (emptyIndex >= 0 && emptyIndex < 4) {
            inputs[emptyIndex].value = digit;
            inputs[emptyIndex].focus();
            
            // Auto-submit if complete
            if (emptyIndex === 3) {
                this.verifyPIN();
            }
        }
    }

    handlePinBackspace() {
        const inputs = document.querySelectorAll('.pin-digit');
        const filledInputs = Array.from(inputs).filter(inp => inp.value);
        
        if (filledInputs.length > 0) {
            filledInputs[filledInputs.length - 1].value = '';
            filledInputs[filledInputs.length - 1].focus();
        }
    }

    async verifyPIN() {
        const inputs = document.querySelectorAll('.pin-digit');
        const enteredPIN = Array.from(inputs).map(inp => inp.value).join('');
        
        if (enteredPIN.length < 4) {
            showToast('⚠️ يرجى إدخال 4 أرقام', 'warning');
            return;
        }
        
        // Hash entered PIN
        const hashed = await CryptoUtils.hashPIN(enteredPIN);
        
        // Compare with stored
        if (this.state.pin === hashed || !this.state.pin) {
            // First time: save new PIN
            if (!this.state.pin) {
                this.state.pin = hashed;
                StorageUtils.set('pin', hashed, { encrypt: true });
                showToast('✅ تم تعيين رمز الدخول بنجاح', 'success');
            } else {
                showToast('✅ مرحباً بك في Alzein', 'success');
            }
            
            // Clear inputs
            inputs.forEach(inp => inp.value = '');
            
            // Navigate to dashboard
            this.state.user = { id: 'local_user' };
            this.showScreen('dashboard');
        } else {
            showToast('❌ رمز الدخول غير صحيح', 'error');
            inputs.forEach(inp => {
                inp.value = '';
                inp.style.borderColor = 'var(--neon-red)';
                setTimeout(() => inp.style.borderColor = '', 300);
            });
        }
    }

    /**
     * Privacy Mode
     */
    applyPrivacyMode(enabled) {
        document.body.classList.toggle('privacy-active', enabled);
        // Save preference
        this.saveSettings();
    }

    /**
     * Modal System
     */
    openModal(modalName) {
        // Dynamic modal loading (to be expanded)
        console.log(`Opening modal: ${modalName}`);
        // In production: load modal component dynamically
        showToast(`🔧 ميزة "${modalName}" قيد التطوير`, 'info');
    }

    closeModal() {
        document.querySelectorAll('.modal').forEach(modal => {
            modal.classList.add('hidden');
        });
    }

    /**
     * Dashboard Refresh
     */
    refreshDashboard() {
        // Update stats from state
        const stats = this.calculateStats();
        
        document.querySelector('[data-key="netBalance"]').textContent = 
            this.formatAmount(stats.netBalance);
        document.querySelector('[data-key="totalReceivable"]').textContent = 
            this.formatAmount(stats.receivable);
        document.querySelector('[data-key="totalPayable"]').textContent = 
            this.formatAmount(stats.payable);
        document.querySelector('[data-key="peopleCount"]').textContent = 
            this.state.data.people.length;
        document.querySelector('[data-key="transactionsCount"]').textContent = 
            this.state.data.transactions.length;
        document.querySelector('[data-key="accountsCount"]').textContent = 
            this.state.data.accounts.length;
        
        // Update recent transactions
        this.renderRecentTransactions();
        
        // Update client ID display
        const clientId = StorageUtils.get('client_id') || 'ALZ-' + Math.random().toString(36).substr(2, 8).toUpperCase();
        document.getElementById('client-id').textContent = clientId;
    }

    calculateStats() {
        let receivable = 0, payable = 0;
        
        this.state.data.transactions.forEach(tx => {
            if (tx.type === 'receive') receivable += parseFloat(tx.amount) || 0;
            if (tx.type === 'give') payable += parseFloat(tx.amount) || 0;
        });
        
        return {
            netBalance: receivable - payable,
            receivable,
            payable
        };
    }

    renderRecentTransactions() {
        const container = document.getElementById('recent-transactions');
        if (!container) return;
        
        const recent = this.state.data.transactions
            .slice(-5)
            .reverse();
        
        if (recent.length === 0) {
            container.innerHTML = '<p class="text-muted text-center">لا توجد معاملات بعد</p>';
            return;
        }
        
        container.innerHTML = recent.map(tx => `
            <div class="transaction-item ${tx.type}">
                <div class="tx-info">
                    <div class="tx-name">${tx.personName || 'غير محدد'}</div>
                    <div class="tx-meta">${tx.date || new Date().toLocaleDateString('ar')}</div>
                </div>
                <div class="tx-amount ${tx.type === 'receive' ? 'positive' : 'negative'}">
                    ${tx.type === 'give' ? '-' : '+'}${this.formatAmount(tx.amount)} ${tx.currency}
                </div>
            </div>
        `).join('');
    }

    formatAmount(amount, currency = null) {
        const num = parseFloat(amount) || 0;
        const curr = currency || this.state.defaultCurrency;
        
        try {
            return new Intl.NumberFormat('ar', {
                style: 'currency',
                currency: curr,
                minimumFractionDigits: 2,
                maximumFractionDigits: 2
            }).format(num).replace(curr, '').trim();
        } catch {
            return num.toFixed(2);
        }
    }

    /**
     * Persistence
     */
    saveSettings() {
        StorageUtils.set('settings', {
            defaultCurrency: this.state.defaultCurrency,
            privacyMode: this.state.privacyMode,
            exchangeRates: this.state.exchangeRates
        });
    }

    saveData() {
        StorageUtils.set('user_data', this.state.data);
    }

    /**
     * UI Helpers
     */
    hideLoading() {
        setTimeout(() => {
            this.dom.loading?.classList.add('hidden');
        }, 800); // Minimum loading time for UX
    }
}

// Initialize App
const app = new AlzeinApp();
document.addEventListener('DOMContentLoaded', () => {
    app.init().catch(err => {
        console.error('🔥 App initialization failed:', err);
        showToast('❌ فشل تحميل التطبيق', 'error');
    });
});

// Export for module access
export { app, AppState, StorageUtils, CryptoUtils, showToast };
