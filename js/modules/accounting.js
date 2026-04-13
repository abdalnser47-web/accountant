/**
 * Alzein ERP Ultra - Accounting & Ledger Module
 * إدارة القيود المالية (إيرادات/مصروفات) مع ملخص يومي
 */

export const Accounting = {
  // البيانات المبدئية
  state: {
    transactions: [
      { id: 1, type: 'income', amount: 5000, description: 'دفعة مقدمة - مشروع تصميم', date: '2026-04-12', account: 'cash' },
      { id: 2, type: 'expense', amount: 850, description: 'شراء استضافة وسيرفرات', date: '2026-04-13', account: 'bank' },
      { id: 3, type: 'income', amount: 1200, description: 'بيع أجهزة طرفية', date: '2026-04-14', account: 'wallet' }
    ],
    filter: 'all' // all, income, expense
  },

  // التهيئة
  init() {
    this.render();
    this.bindEvents();
    console.log('💰 Accounting Module Initialized');
  },

  // عرض الواجهة
  render() {
    const accountingView = document.querySelector('.accounting-view');
    if (!accountingView) return;

    // حساب الملخص
    const income = this.state.transactions
      .filter(t => t.type === 'income')
      .reduce((sum, t) => sum + t.amount, 0);
      
    const expense = this.state.transactions
      .filter(t => t.type === 'expense')
      .reduce((sum, t) => sum + t.amount, 0);
      
    const balance = income - expense;

    // تصفية القيود
    const filtered = this.state.filter === 'all' 
      ? this.state.transactions 
      : this.state.transactions.filter(t => t.type === this.state.filter);

    // بناء HTML
    accountingView.innerHTML = `
      <div class="accounting-container">
        <!-- بطاقات الملخص -->
        <div class="summary-grid">
          <div class="summary-card neon-border income-card">
            <div class="card-icon">📈</div>
            <div class="card-info">
              <span class="label">إجمالي الإيرادات</span>
              <span class="value">$${income.toLocaleString()}</span>
            </div>
          </div>
          
          <div class="summary-card neon-border expense-card">
            <div class="card-icon">📉</div>
            <div class="card-info">
              <span class="label">إجمالي المصروفات</span>
              <span class="value">$${expense.toLocaleString()}</span>
            </div>
          </div>
          
          <div class="summary-card neon-border balance-card ${balance >= 0 ? 'positive' : 'negative'}">
            <div class="card-icon">💎</div>
            <div class="card-info">
              <span class="label">صافي الرصيد</span>
              <span class="value">$${balance.toLocaleString()}</span>
            </div>
          </div>
        </div>

        <!-- نموذج إضافة قيد -->
        <div class="transaction-form neon-border">
          <h3>➕ قيد مالي جديد</h3>
          <div class="form-row">
            <select id="txn-type" class="form-select">
              <option value="income">🟢 إيراد (قبض)</option>
              <option value="expense">🔴 مصروف (صرف)</option>
            </select>
            <input type="number" id="txn-amount" placeholder="المبلغ" class="form-input" min="0" step="0.01">
          </div>
          <div class="form-row">
            <input type="text" id="txn-desc" placeholder="وصف العملية (اختياري)" class="form-input">
            <select id="txn-account" class="form-select">
              <option value="cash">نقد (Cash)</option>
              <option value="bank">بنك (Bank)</option>
              <option value="wallet">محفظة (Wallet)</option>
            </select>
          </div>
          <button id="add-txn-btn" class="action-btn pulse">حفظ القيد</button>
        </div>

        <!-- سجل الحركات -->
        <div class="ledger-section">
          <div class="ledger-header">
            <h3>📒 سجل الحركات (${filtered.length})</h3>
            <div class="filter-tabs">
              <button class="tab-btn ${this.state.filter === 'all' ? 'active' : ''}" data-filter="all">الكل</button>
              <button class="tab-btn ${this.state.filter === 'income' ? 'active' : ''}" data-filter="income">إيرادات</button>
              <button class="tab-btn ${this.state.filter === 'expense' ? 'active' : ''}" data-filter="expense">مصروفات</button>
            </div>
          </div>

          <div class="ledger-list">
            ${filtered.length > 0 ? filtered.map(t => this.createLedgerRow(t)).join('') : `
              <div class="empty-state">
                <div class="empty-icon">📭</div>
                <p>لا توجد حركات مسجلة بعد</p>
              </div>
            `}
          </div>
        </div>
      </div>
    `;
  },

  // إنشاء صف في السجل
  createLedgerRow(txn) {
    const isIncome = txn.type === 'income';
    const sign = isIncome ? '+' : '-';
    const color = isIncome ? 'var(--neon-green)' : '#ff0055';
    const icon = isIncome ? '📥' : '📤';

    return `
      <div class="ledger-row neon-border" data-id="${txn.id}">
        <div class="row-icon" style="background: ${isIncome ? 'rgba(0,255,136,0.1)' : 'rgba(255,0,85,0.1)'}">
          ${icon}
        </div>
        <div class="row-details">
          <div class="row-title">${txn.description || 'بدون وصف'}</div>
          <div class="row-meta">
            <span>📅 ${txn.date}</span>
            <span>🏦 ${txn.account === 'cash' ? 'نقد' : txn.account === 'bank' ? 'بنك' : 'محفظة'}</span>
          </div>
        </div>
        <div class="row-amount" style="color: ${color}">
          ${sign}$${txn.amount.toLocaleString()}
        </div>
        <button class="delete-txn" title="حذف">🗑️</button>
      </div>
    `;
  },

  // ربط الأحداث
  bindEvents() {
    const container = document.querySelector('.accounting-view');
    if (!container) return;

    // إضافة قيد
    container.addEventListener('click', (e) => {
      if (e.target.id === 'add-txn-btn') {
        this.handleAddTransaction();
      }
      
      if (e.target.classList.contains('delete-txn')) {
        const row = e.target.closest('.ledger-row');
        this.deleteTransaction(parseInt(row.dataset.id));
      }
    });

    // تغيير الفلتر
    container.addEventListener('click', (e) => {
      if (e.target.classList.contains('tab-btn')) {
        this.state.filter = e.target.dataset.filter;
        this.render();
      }
    });
  },

  // معالجة إضافة قيد
  handleAddTransaction() {
    const type = document.getElementById('txn-type').value;
    const amount = parseFloat(document.getElementById('txn-amount').value);
    const desc = document.getElementById('txn-desc').value.trim();
    const account = document.getElementById('txn-account').value;

    if (!amount || amount <= 0) {
      if (typeof showToast === 'function') showToast('يرجى إدخال مبلغ صحيح ⚠️', 'warning');
      return;
    }

    const newTxn = {
      id: Date.now(),
      type,
      amount,
      description: desc || (type === 'income' ? 'إيراد جديد' : 'مصروف جديد'),
      date: new Date().toISOString().split('T')[0],
      account
    };

    this.state.transactions.unshift(newTxn);
    this.render();
    
    if (typeof showToast === 'function') {
      showToast(type === 'income' ? 'تم تسجيل الإيراد بنجاح ✅' : 'تم تسجيل المصروف بنجاح ✅', 'success');
    }
  },

  // حذف قيد
  deleteTransaction(id) {
    if (confirm('هل أنت متأكد من حذف هذا القيد؟')) {
      this.state.transactions = this.state.transactions.filter(t => t.id !== id);
      this.render();
      if (typeof showToast === 'function') showToast('تم حذف القيد 🗑️', 'warning');
    }
  },

  // دالة مساعدة للوحة التحكم
  getDailySummary() {
    const today = new Date().toISOString().split('T')[0];
    const todayTxns = this.state.transactions.filter(t => t.date === today);
    
    return {
      count: todayTxns.length,
      income: todayTxns.filter(t => t.type === 'income').reduce((s, t) => s + t.amount, 0),
      expense: todayTxns.filter(t => t.type === 'expense').reduce((s, t) => s + t.amount, 0)
    };
  }
};
💰 إضافة وحدة المحاسبة وسجل القيود (Accounting)
