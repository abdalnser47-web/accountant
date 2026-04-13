/**
 * Alzein ERP Ultra - Professional Calculator Module
 * حاسبة احترافية مع تاريخ العمليات وإمكانية الإرسال للنظام المحاسبي
 */

export const Calculator = {
  // الحالة الحالية
  state: {
    display: '0',
    previousValue: null,
    operation: null,
    waitingForNewValue: false,
    history: []
  },

  // تهيئة الحاسبة
  init() {
    this.render();
    this.bindEvents();
    console.log('🧮 Calculator Initialized');
  },

  // عرض الحاسبة
  render() {
    const calculatorHTML = `
      <div id="calculator-modal" class="calculator-modal">
        <div class="calculator-container neon-border">
          <div class="calculator-header">
            <h3>🧮 الحاسبة الاحترافية</h3>
            <button id="close-calculator" class="close-btn">✕</button>
          </div>
          
          <div class="calculator-display">
            <div class="calculator-history" id="calc-history"></div>
            <div class="calculator-value" id="calc-display">0</div>
          </div>
          
          <div class="calculator-keys">
            <button class="calc-btn calc-btn-function" data-action="clear">C</button>
            <button class="calc-btn calc-btn-function" data-action="backspace">⌫</button>
            <button class="calc-btn calc-btn-function" data-action="percent">%</button>
            <button class="calc-btn calc-btn-operator" data-action="divide">÷</button>
            
            <button class="calc-btn" data-number="7">7</button>
            <button class="calc-btn" data-number="8">8</button>
            <button class="calc-btn" data-number="9">9</button>
            <button class="calc-btn calc-btn-operator" data-action="multiply">×</button>
            
            <button class="calc-btn" data-number="4">4</button>
            <button class="calc-btn" data-number="5">5</button>
            <button class="calc-btn" data-number="6">6</button>
            <button class="calc-btn calc-btn-operator" data-action="subtract">−</button>
            
            <button class="calc-btn" data-number="1">1</button>
            <button class="calc-btn" data-number="2">2</button>
            <button class="calc-btn" data-number="3">3</button>
            <button class="calc-btn calc-btn-operator" data-action="add">+</button>
            
            <button class="calc-btn" data-number="0">0</button>
            <button class="calc-btn" data-number=".">.</button>
            <button class="calc-btn calc-btn-equals" data-action="calculate">=</button>
            <button class="calc-btn calc-btn-send" data-action="send-to-amount">إرسال ↗</button>
          </div>
        </div>
      </div>
    `;

    // إضافة الحاسبة للصفحة إذا لم تكن موجودة
    if (!document.getElementById('calculator-modal')) {
      document.body.insertAdjacentHTML('beforeend', calculatorHTML);
    }
  },

  // ربط الأحداث
  bindEvents() {
    // فتح الحاسبة من الزر العائم
    const fab = document.getElementById('calculator-fab');
    const modal = document.getElementById('calculator-modal');
    const closeBtn = document.getElementById('close-calculator');

    if (fab && modal) {
      fab.addEventListener('click', () => {
        modal.classList.add('active');
      });
    }

    if (closeBtn && modal) {
      closeBtn.addEventListener('click', () => {
        modal.classList.remove('active');
      });
    }

    // أحداث الأزرار (تفويض الأحداث)
    document.addEventListener('click', (e) => {
      if (e.target.matches('[data-number]')) {
        this.inputNumber(e.target.dataset.number);
      } else if (e.target.matches('[data-action]')) {
        this.handleAction(e.target.dataset.action);
      }
    });

    // لوحة المفاتيح
    document.addEventListener('keydown', (e) => this.handleKeyboard(e));
  },

  // إدخال الأرقام
  inputNumber(number) {
    const { display, waitingForNewValue } = this.state;

    if (waitingForNewValue) {
      this.state.display = number;
      this.state.waitingForNewValue = false;
    } else {
      this.state.display = display === '0' ? number : display + number;
    }

    this.updateDisplay();
  },

  // معالجة العمليات
  handleAction(action) {
    switch(action) {
      case 'clear':
        this.clear();
        break;
      case 'backspace':
        this.backspace();
        break;
      case 'add':
      case 'subtract':
      case 'multiply':
      case 'divide':
        this.setOperation(action);
        break;
      case 'calculate':
        this.calculate();
        break;
      case 'percent':
        this.percent();
        break;
      case 'send-to-amount':
        this.sendToAmount();
        break;
    }
  },

  // تعيين العملية
  setOperation(operation) {
    const { display, previousValue, waitingForNewValue } = this.state;

    if (previousValue && !waitingForNewValue) {
      this.calculate();
    }

    this.state.previousValue = parseFloat(display);
    this.state.operation = operation;
    this.state.waitingForNewValue = true;

    this.addToHistory(`${this.state.previousValue} ${this.getOperatorSymbol(operation)}`);
  },

  // الحساب
  calculate() {
    const { display, previousValue, operation } = this.state;

    if (!previousValue || !operation) return;

    const currentValue = parseFloat(display);
    let result = 0;

    switch(operation) {
      case 'add':
        result = previousValue + currentValue;
        break;
      case 'subtract':
        result = previousValue - currentValue;
        break;
      case 'multiply':
        result = previousValue * currentValue;
        break;
      case 'divide':
        result = previousValue / currentValue;
        break;
    }

    result = Math.round(result * 100) / 100;

    this.addToHistory(`${previousValue} ${this.getOperatorSymbol(operation)} ${currentValue} = ${result}`);
    
    this.state.display = result.toString();
    this.state.previousValue = null;
    this.state.operation = null;
    this.state.waitingForNewValue = true;

    this.updateDisplay();
  },

  // مسح
  clear() {
    this.state.display = '0';
    this.state.previousValue = null;
    this.state.operation = null;
    this.state.waitingForNewValue = false;
    this.updateDisplay();
  },

  // حذف آخر رقم
  backspace() {
    const { display } = this.state;
    if (display.length > 1) {
      this.state.display = display.slice(0, -1);
    } else {
      this.state.display = '0';
    }
    this.updateDisplay();
  },

  // نسبة مئوية
  percent() {
    const { display } = this.state;
    this.state.display = (parseFloat(display) / 100).toString();
    this.updateDisplay();
  },

  // إرسال المبلغ للنظام المحاسبي
  sendToAmount() {
    const amount = this.state.display;
    
    // محاولة العثور على حقل المبلغ في النظام
    const amountInput = document.querySelector('input[type="number"][name="amount"], #txAmount, .amount-input');
    
    if (amountInput) {
      amountInput.value = amount;
      amountInput.dispatchEvent(new Event('input', { bubbles: true }));
      this.showNotification(`تم نقل المبلغ: ${amount}`, 'success');
    } else {
      this.showNotification('لا يوجد حقل مبلغ نشط حالياً', 'info');
    }

    // إغلاق الحاسبة
    const modal = document.getElementById('calculator-modal');
    if (modal) {
      modal.classList.remove('active');
    }
  },

  // إضافة للسجل
  addToHistory(entry) {
    this.state.history.unshift(entry);
    if (this.state.history.length > 10) {
      this.state.history.pop();
    }
    this.updateHistory();
  },

  // تحديث السجل
  updateHistory() {
    const historyEl = document.getElementById('calc-history');
    if (historyEl) {
      historyEl.innerHTML = this.state.history
        .slice(0, 5)
        .map(entry => `<div class="history-item">${entry}</div>`)
        .join('');
    }
  },

  // تحديث الشاشة
  updateDisplay() {
    const displayEl = document.getElementById('calc-display');
    if (displayEl) {
      displayEl.textContent = this.formatNumber(this.state.display);
    }
  },

  // تنسيق الرقم
  formatNumber(num) {
    return parseFloat(num).toLocaleString('en-US', {
      maximumFractionDigits: 2
    });
  },

  // رمز العملية
  getOperatorSymbol(op) {
    const symbols = {
      add: '+',
      subtract: '−',
      multiply: '×',
      divide: '÷'
    };
    return symbols[op] || op;
  },

  // التعامل مع لوحة المفاتيح
  handleKeyboard(e) {
    if (e.key >= '0' && e.key <= '9') {
      this.inputNumber(e.key);
    } else if (e.key === '.') {
      this.inputNumber('.');
    } else if (e.key === '+') {
      this.setOperation('add');
    } else if (e.key === '-') {
      this.setOperation('subtract');
    } else if (e.key === '*') {
      this.setOperation('multiply');
    } else if (e.key === '/') {
      e.preventDefault();
      this.setOperation('divide');
    } else if (e.key === 'Enter' || e.key === '=') {
      this.calculate();
    } else if (e.key === 'Escape' || e.key === 'c' || e.key === 'C') {
      this.clear();
    } else if (e.key === 'Backspace') {
      this.backspace();
    } else if (e.key === '%') {
      this.percent();
    }
  },

  // إظهار إشعار
  showNotification(message, type = 'info') {
    if (typeof showToast === 'function') {
      showToast(message, type);
    } else {
      alert(message);
    }
  }
};
🧮 إضافة وحدة الحاسبة الاحترافية (Calculator)
