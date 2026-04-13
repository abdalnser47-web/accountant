/**
 * Alzein ERP Ultra - Inventory Management Module
 * إدارة المخزون: أصناف، كميات، وتنبيهات
 */

export const Inventory = {
  // البيانات المبدئية (سيتم استبدالها بقاعدة البيانات لاحقاً)
  state: {
    items: [
      { id: 1, name: 'لابتوب HP Pro', sku: 'LPT-001', quantity: 12, price: 1200, minLevel: 5 },
      { id: 2, name: 'شاشة Samsung 24"', sku: 'SCR-024', quantity: 3, price: 250, minLevel: 5 },
      { id: 3, name: 'ماوس لاسلكي', sku: 'MOU-WL', quantity: 50, price: 15, minLevel: 10 },
      { id: 4, name: 'كيبورد ميكانيكي', sku: 'KBD-MECH', quantity: 0, price: 60, minLevel: 5 }
    ],
    searchQuery: ''
  },

  // التهيئة
  init() {
    this.render();
    this.bindEvents();
    console.log('📦 Inventory Module Initialized');
  },

  // عرض واجهة المخزون
  render() {
    const inventoryView = document.querySelector('.inventory-view');
    if (!inventoryView) return;

    // تصفية العناصر بناءً على البحث
    const filteredItems = this.state.items.filter(item => 
      item.name.toLowerCase().includes(this.state.searchQuery.toLowerCase()) ||
      item.sku.toLowerCase().includes(this.state.searchQuery.toLowerCase())
    );

    const html = `
      <div class="inventory-container">
        <div class="inventory-header">
          <h2>📦 المخزون الحالي (${filteredItems.length})</h2>
          <div class="search-box neon-border">
            <input type="text" id="inventory-search" placeholder="بحث بالاسم أو الرمز..." value="${this.state.searchQuery}">
          </div>
          <button id="add-item-btn" class="action-btn pulse">+ صنف جديد</button>
        </div>

        <div class="items-grid">
          ${filteredItems.length > 0 ? filteredItems.map(item => this.createItemCard(item)).join('') : `
            <div class="empty-state">
              <div class="empty-icon">📭</div>
              <p>لا توجد أصناف مطابقة للبحث</p>
            </div>
          `}
        </div>
      </div>
    `;

    inventoryView.innerHTML = html;
  },

  // إنشاء بطاقة الصنف
  createItemCard(item) {
    // تحديد حالة المخزون
    let stockStatus = 'good';
    let stockLabel = 'متوفر';
    let stockColor = 'var(--neon-green)';

    if (item.quantity === 0) {
      stockStatus = 'out';
      stockLabel = 'نفذ';
      stockColor = '#ff0055';
    } else if (item.quantity <= item.minLevel) {
      stockStatus = 'low';
      stockLabel = 'منخفض';
      stockColor = 'var(--neon-pink)';
    }

    return `
      <div class="item-card neon-border ${stockStatus}" data-id="${item.id}">
        <div class="item-header">
          <span class="item-sku">${item.sku}</span>
          <div class="item-actions">
            <button class="action-icon edit" title="تعديل">✏️</button>
            <button class="action-icon delete" title="حذف">🗑️</button>
          </div>
        </div>
        
        <div class="item-body">
          <h3 class="item-name">${item.name}</h3>
          <div class="item-stats">
            <div class="stat">
              <span class="label">الكمية</span>
              <span class="value">${item.quantity}</span>
            </div>
            <div class="stat">
              <span class="label">السعر</span>
              <span class="value">$${item.price}</span>
            </div>
          </div>
          
          <div class="stock-indicator">
            <div class="stock-bar-bg">
              <div class="stock-bar-fill" style="width: ${Math.min((item.quantity / (item.minLevel * 2)) * 100, 100)}%; background: ${stockColor};"></div>
            </div>
            <span class="stock-status" style="color: ${stockColor}">● ${stockLabel}</span>
          </div>
        </div>
      </div>
    `;
  },

  // ربط الأحداث
  bindEvents() {
    // البحث
    const container = document.querySelector('.inventory-view');
    if (!container) return;

    container.addEventListener('input', (e) => {
      if (e.target.id === 'inventory-search') {
        this.state.searchQuery = e.target.value;
        this.render(); // إعادة رسم مع كل كتابة (Debouncing يمكن إضافته لاحقاً)
      }
    });

    // إضافة صنف جديد
    container.addEventListener('click', (e) => {
      if (e.target.id === 'add-item-btn' || e.target.closest('#add-item-btn')) {
        this.showAddModal();
      }
      
      // حذف صنف
      if (e.target.closest('.delete')) {
        const card = e.target.closest('.item-card');
        const id = parseInt(card.dataset.id);
        this.deleteItem(id);
      }
    });
  },

  // إضافة صنف (محاكاة)
  showAddModal() {
    const name = prompt('اسم الصنف الجديد:');
    if (!name) return;
    
    const sku = prompt('رمز الصنف (SKU):', 'NEW-' + Math.floor(Math.random() * 1000));
    const quantity = parseInt(prompt('الكمية الافتتاحية:', '0'));
    const price = parseFloat(prompt('سعر البيع:', '0'));

    if (name && sku) {
      this.addItem({
        id: Date.now(),
        name,
        sku,
        quantity: isNaN(quantity) ? 0 : quantity,
        price: isNaN(price) ? 0 : price,
        minLevel: 5
      });
    }
  },

  // إضافة عنصر للمصفوفة
  addItem(item) {
    this.state.items.unshift(item); // إضافة في البداية
    this.render();
    if (typeof showToast === 'function') showToast('تمت إضافة الصنف بنجاح ✅', 'success');
  },

  // حذف عنصر
  deleteItem(id) {
    if (confirm('هل أنت متأكد من حذف هذا الصنف؟')) {
      this.state.items = this.state.items.filter(i => i.id !== id);
      this.render();
      if (typeof showToast === 'function') showToast('تم حذف الصنف 🗑️', 'warning');
    }
  },

  // دالة مساعدة للحصول على البيانات (للوحة التحكم)
  getSummary() {
    return {
      totalItems: this.state.items.length,
      lowStock: this.state.items.filter(i => i.quantity <= i.minLevel && i.quantity > 0).length,
      outOfStock: this.state.items.filter(i => i.quantity === 0).length,
      totalValue: this.state.items.reduce((sum, i) => sum + (i.price * i.quantity), 0)
    };
  }
};
📦 إضافة وحدة إدارة المخزون (Inventory)
