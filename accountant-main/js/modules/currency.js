/**
 * Alzein ERP Ultra - Currency Converter Module
 * محول عملات فوري مع أسعار مباشرة من API
 */

export const CurrencyUltra = {
  // الإعدادات
  apiKey: 'YOUR_EXCHANGE_RATE_API_KEY', // استبدله بمفتاحك من exchangerate-api.com
  baseCurrency: 'USD',
  rates: {},
  lastUpdate: null,

  // العملات الشائعة
  popularCurrencies: [
    { code: 'USD', name: 'دولار أمريكي', symbol: '$' },
    { code: 'EUR', name: 'يورو', symbol: '€' },
    { code: 'GBP', name: 'جنيه إسترليني', symbol: '£' },
    { code: 'SAR', name: 'ريال سعودي', symbol: 'ر.س' },
    { code: 'AED', name: 'درهم إماراتي', symbol: 'د.إ' },
    { code: 'EGP', name: 'جنيه مصري', symbol: 'ج.م' },
    { code: 'JOD', name: 'دينار أردني', symbol: 'د.ا' },
    { code: 'KWD', name: 'دينار كويتي', symbol: 'د.ك' }
  ],

  // التهيئة
  async init() {
    await this.fetchRates();
    this.render();
    this.bindEvents();
    console.log('💱 Currency Converter Initialized');
  },

  // جلب أسعار الصرف من API
  async fetchRates() {
    try {
      // محاولة جلب البيانات من LocalStorage أولاً (للتسريع)
      const cachedData = localStorage.getItem('currency_rates');
      const cachedTime = localStorage.getItem('currency_rates_time');
      
      const now = Date.now();
      const oneHour = 60 * 60 * 1000;
      
      if (cachedData && cachedTime && (now - parseInt(cachedTime)) < oneHour) {
        this.rates = JSON.parse(cachedData);
        console.log('📦 Using cached rates');
        return;
      }

      // جلب من API (استخدم API مجاني مثل exchangerate-api.com)
      const response = await fetch(`https://api.exchangerate-api.com/v4/latest/${this.baseCurrency}`);
      const data = await response.json();
      
      this.rates = data.rates;
      this.lastUpdate = new Date().toISOString();
      
      // حفظ في LocalStorage
      localStorage.setItem('currency_rates', JSON.stringify(this.rates));
      localStorage.setItem('currency_rates_time', now.toString());
      
      console.log('🌐 Rates fetched from API');
    } catch (error) {
      console.error('Failed to fetch rates:', error);
      // استخدام أسعار افتراضية في حالة الفشل
      this.useFallbackRates();
    }
  },

  // أسعار احتياطية (في حالة عدم وجود اتصال)
  useFallbackRates() {
    this.rates = {
      USD: 1,
      EUR: 0.92,
      GBP: 0.79,
      SAR: 3.75,
      AED: 3.67,
      EGP: 47.5,
      JOD: 0.71,
      KWD: 0.31
    };
    console.log('🔄 Using fallback rates');
  },

  // عرض المحول
  render() {
    const converterHTML = `
      <div id="currency-converter" class="currency-converter neon-border">
        <div class="converter-header">
          <h3>💱 محول العملات</h3>
          <span class="last-update" id="rates-update"></span>
        </div>
        
        <div class="converter-main">
          <div class="converter-input-group">
            <label>المبلغ</label>
            <input type="number" id="convert-amount" value="1" min="0" step="0.01">
          </div>
          
          <div class="converter-currencies">
            <div class="currency-select">
              <label>من</label>
              <select id="from-currency">
                ${this.popularCurrencies.map(c => 
                  `<option value="${c.code}" ${c.code === 'USD' ? 'selected' : ''}>
                    ${c.code} - ${c.name}
                  </option>`
                ).join('')}
              </select>
            </div>
            
            <button id="swap-currencies" class="swap-btn">⇄</button>
            
            <div class="currency-select">
              <label>إلى</label>
              <select id="to-currency">
                ${this.popularCurrencies.map(c => 
                  `<option value="${c.code}" ${c.code === 'SAR' ? 'selected' : ''}>
                    ${c.code} - ${c.name}
                  </option>`
                ).join('')}
              </select>
            </div>
          </div>
          
          <div class="converter-result">
            <div class="result-amount" id="convert-result">0.00</div>
            <div class="result-rate" id="exchange-rate">1 USD = 3.75 SAR</div>
          </div>
        </div>
        
        <div class="mini-rates">
          <h4>أسعار سريعة (USD)</h4>
          <div class="rates-grid" id="mini-rates-grid">
            ${this.getMiniRates()}
          </div>
        </div>
      </div>
    `;

    // إضافة المحول للصفحة
    const toolsView = document.querySelector('.tools-view');
    if (toolsView) {
      toolsView.insertAdjacentHTML('beforeend', converterHTML);
    }
  },

  // ربط الأحداث
  bindEvents() {
    document.addEventListener('input', (e) => {
      if (e.target.id === 'convert-amount' || 
          e.target.id === 'from-currency' || 
          e.target.id === 'to-currency') {
        this.convert();
      }
    });

    document.addEventListener('click', (e) => {
      if (e.target.id === 'swap-currencies') {
        this.swapCurrencies();
      }
    });

    // تحديث عند تحميل الصفحة
    this.convert();
    this.updateLastUpdate();
  },

  // التحويل
  convert() {
    const amount = parseFloat(document.getElementById('convert-amount')?.value) || 0;
    const from = document.getElementById('from-currency')?.value || 'USD';
    const to = document.getElementById('to-currency')?.value || 'SAR';

    if (!this.rates[from] || !this.rates[to]) {
      console.error('Currency not found');
      return;
    }

    // التحويل: (المبلغ / سعر العملة الأصلية) × سعر العملة الهدف
    const rate = this.rates[to] / this.rates[from];
    const result = amount * rate;

    // عرض النتيجة
    const resultEl = document.getElementById('convert-result');
    const rateEl = document.getElementById('exchange-rate');
    
    if (resultEl) {
      resultEl.textContent = this.formatCurrency(result, to);
    }
    
    if (rateEl) {
      rateEl.textContent = `1 ${from} = ${rate.toFixed(4)} ${to}`;
    }
  },

  // تبديل العملات
  swapCurrencies() {
    const fromSelect = document.getElementById('from-currency');
    const toSelect = document.getElementById('to-currency');
    
    if (fromSelect && toSelect) {
      const temp = fromSelect.value;
      fromSelect.value = toSelect.value;
      toSelect.value = temp;
      
      this.convert();
    }
  },

  // عرض الأسعار السريعة
  getMiniRates() {
    return this.popularCurrencies
      .filter(c => c.code !== 'USD')
      .slice(0, 4)
      .map(c => {
        const rate = this.rates[c.code] || 0;
        return `
          <div class="rate-item">
            <span class="rate-currency">${c.code}</span>
            <span class="rate-value">${rate.toFixed(2)}</span>
          </div>
        `;
      })
      .join('');
  },

  // تحديث وقت آخر تحديث
  updateLastUpdate() {
    const updateEl = document.getElementById('rates-update');
    if (updateEl && this.lastUpdate) {
      const date = new Date(this.lastUpdate);
      updateEl.textContent = `آخر تحديث: ${date.toLocaleTimeString('ar-SA')}`;
    }
  },

  // تنسيق العملة
  formatCurrency(amount, currency) {
    try {
      return new Intl.NumberFormat('en-US', {
        style: 'currency',
        currency: currency,
        minimumFractionDigits: 2,
        maximumFractionDigits: 2
      }).format(amount);
    } catch (e) {
      return amount.toFixed(2) + ' ' + currency;
    }
  },

  // دالة عامة للتحويل (للاستخدام من وحدات أخرى)
  convertAmount(amount, from, to) {
    if (!this.rates[from] || !this.rates[to]) return 0;
    const rate = this.rates[to] / this.rates[from];
    return amount * rate;
  }
};
💱 إضافة وحدة محول العملات (Currency Converter)
