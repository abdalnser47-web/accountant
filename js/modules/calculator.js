/**
 * Alzein ERP Ultra - Calculator Module
 */
export const Calculator = {
  state: { display: '0', prev: null, op: null, wait: false, history: [] },
  
  init() {
    this.render();
    this.bindEvents();
  },

  render() {
    const html = `
      <div id="calc-modal" class="calculator-modal">
        <div class="calculator-container neon-border">
          <div class="calc-header"><h3>🧮 الحاسبة</h3><button id="close-calc" class="close-btn">✕</button></div>
          <div class="calc-display">
            <div class="calc-history" id="calc-hist"></div>
            <div class="calc-value" id="calc-val">0</div>
          </div>
          <div class="calc-keys">
            <button class="ck btn-f" data-a="clear">C</button>
            <button class="ck btn-f" data-a="back">⌫</button>
            <button class="ck btn-f" data-a="percent">%</button>
            <button class="ck btn-op" data-a="divide">÷</button>
            <button class="ck" data-n="7">7</button><button class="ck" data-n="8">8</button>
            <button class="ck" data-n="9">9</button><button class="ck btn-op" data-a="multiply">×</button>
            <button class="ck" data-n="4">4</button><button class="ck" data-n="5">5</button>
            <button class="ck" data-n="6">6</button><button class="ck btn-op" data-a="subtract">−</button>
            <button class="ck" data-n="1">1</button><button class="ck" data-n="2">2</button>
            <button class="ck" data-n="3">3</button><button class="ck btn-op" data-a="add">+</button>
            <button class="ck" data-n="0">0</button><button class="ck" data-n=".">.</button>
            <button class="ck btn-eq" data-a="calc">=</button>
            <button class="ck btn-send" data-a="send">إرسال ↗</button>
          </div>
        </div>
      </div>`;
    if (!document.getElementById('calc-modal')) document.body.insertAdjacentHTML('beforeend', html);
  },

  bindEvents() {
    const fab = document.getElementById('calculator-fab');
    const modal = document.getElementById('calc-modal');
    const close = document.getElementById('close-calc');
    if(fab) fab.onclick = () => modal?.classList.add('active');
    if(close) close.onclick = () => modal?.classList.remove('active');

    document.addEventListener('click', (e) => {
      if (e.target.matches('[data-n]')) this.inputNum(e.target.dataset.n);
      if (e.target.matches('[data-a]')) this.action(e.target.dataset.a);
    });
    document.addEventListener('keydown', (e) => this.keyHandler(e));
  },

  inputNum(n) {
    const { display, wait } = this.state;
    this.state.display = wait ? n : (display === '0' ? n : display + n);
    this.state.wait = false;
    this.updateUI();
  },

  action(a) {
    const { display, prev, op } = this.state;
    if (a === 'clear') { this.state = { display: '0', prev: null, op: null, wait: false, history: [] }; this.updateUI(); return; }
    if (a === 'back') { this.state.display = display.length > 1 ? display.slice(0,-1) : '0'; this.updateUI(); return; }
    if (a === 'percent') { this.state.display = (parseFloat(display)/100).toString(); this.updateUI(); return; }
    
    if (['add','subtract','multiply','divide'].includes(a)) {
      if (prev && !this.state.wait) this.calc();
      this.state.prev = parseFloat(display);
      this.state.op = a;
      this.state.wait = true;
      return;
    }
    if (a === 'calc') this.calc();
    if (a === 'send') this.sendToAmount();
  },

  calc() {
    const { display, prev, op } = this.state;
    if (!prev || !op) return;
    const curr = parseFloat(display);
    let res = 0;
    if (op === 'add') res = prev + curr;
    else if (op === 'subtract') res = prev - curr;
    else if (op === 'multiply') res = prev * curr;
    else if (op === 'divide') res = prev / curr;
    
    res = Math.round(res * 100) / 100;
    this.state.history.unshift(`${prev} ${this.sym(op)} ${curr} = ${res}`);
    this.state.display = res.toString();
    this.state.prev = null; this.state.op = null; this.state.wait = true;
    this.updateUI();
  },

  sendToAmount() {
    const val = this.state.display;
    const input = document.querySelector('input[name="amount"], #txAmount, .amount-input');
    if (input) { input.value = val; input.dispatchEvent(new Event('input')); }
    document.getElementById('calc-modal')?.classList.remove('active');
    if (typeof showToast === 'function') showToast(`تم نقل المبلغ: ${val}`, 'success');
  },

  updateUI() {
    const el = document.getElementById('calc-val');
    const hist = document.getElementById('calc-hist');
    if (el) el.textContent = parseFloat(this.state.display).toLocaleString();
    if (hist) hist.innerHTML = this.state.history.slice(0,3).map(h => `<div>${h}</div>`).join('');
  },

  sym(op) { return {add:'+', subtract:'−', multiply:'×', divide:'÷'}[op] || op; },

  keyHandler(e) {
    if (e.key >= '0' && e.key <= '9') this.inputNum(e.key);
    else if (e.key === '.') this.inputNum('.');
    else if (e.key === '+') this.action('add');
    else if (e.key === '-') this.action('subtract');
    else if (e.key === '*') this.action('multiply');
    else if (e.key === '/') { e.preventDefault(); this.action('divide'); }
    else if (e.key === 'Enter' || e.key === '=') this.action('calc');
    else if (e.key === 'Escape') this.action('clear');
    else if (e.key === 'Backspace') this.action('back');
  }
};
