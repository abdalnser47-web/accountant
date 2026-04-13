/**
 * محرك المحاسبة مزدوج القيد (Debit/Credit)
 * يربط المخزون بالمحاسبة تلقائياً
 */

import { SecurityError } from '../config/roles-permissions.js';

export class AccountingEngine {
  constructor(userId, db) {
    this.userId = userId;
    this.db = db;
    this.ACCOUNT_TYPES = {
      ASSET: 'asset', LIABILITY: 'liability', EQUITY: 'equity',
      REVENUE: 'revenue', EXPENSE: 'expense'
    };
  }

  createBalancedEntry(entry) {
    if (!entry?.debit || !entry?.credit) throw new Error('Missing debit/credit');
    
    const debitTotal = entry.debit.reduce((sum, i) => sum + (i.amount || 0), 0);
    const creditTotal = entry.credit.reduce((sum, i) => sum + (i.amount || 0), 0);
    
    if (Math.abs(debitTotal - creditTotal) > 0.001) {
      throw new Error(`Unbalanced: Debit ${debitTotal} ≠ Credit ${creditTotal}`);
    }

    return {
      id: crypto.randomUUID(),
      userId: this.userId,
      entries: {
        debit: entry.debit.map(d => ({ ...d, side: 'debit' })),
        credit: entry.credit.map(c => ({ ...c, side: 'credit' }))
      },
      totals: { debit: debitTotal, credit: creditTotal },
      description: entry.description,
      reference: entry.reference || null,
      metadata: entry.metadata || {},
      createdAt: new Date().toISOString(),
      balanced: true
    };
  }

  async processSale({ itemId, quantity, unitPrice, customerId, accountId, currency = 'USD' }) {
    if (quantity < 1 || unitPrice < 0) throw new Error('Invalid sale params');
    
    const totalAmount = quantity * unitPrice;
    await this._adjustInventory(itemId, -quantity, 'out');
    
    const journalEntry = this.createBalancedEntry({      description: `Sale: ${quantity}x Item#${itemId}`,
      reference: `SALE-${Date.now()}`,
      debit: [{ accountId, amount: totalAmount, accountType: this.ACCOUNT_TYPES.ASSET }],
      credit: [{ accountId: 'revenue:sales', amount: totalAmount, accountType: this.ACCOUNT_TYPES.REVENUE }],
      metadata: { type: 'sale', itemId, quantity, unitPrice, customerId, currency }
    });

    return await this._saveJournalEntry(journalEntry);
  }

  async processPurchase({ itemId, quantity, unitCost, supplierId, accountId, currency = 'USD' }) {
    if (quantity < 1 || unitCost < 0) throw new Error('Invalid purchase params');
    
    const totalCost = quantity * unitCost;
    await this._adjustInventory(itemId, quantity, 'in');
    
    const journalEntry = this.createBalancedEntry({
      description: `Purchase: ${quantity}x Item#${itemId}`,
      reference: `PUR-${Date.now()}`,
      debit: [{ accountId: 'inventory:assets', amount: totalCost, accountType: this.ACCOUNT_TYPES.ASSET }],
      credit: [{ accountId, amount: totalCost, accountType: this.ACCOUNT_TYPES.ASSET }],
      meta { type: 'purchase', itemId, quantity, unitCost, supplierId, currency }
    });

    return await this._saveJournalEntry(journalEntry);
  }

  async _adjustInventory(itemId, quantity, direction) {
    // سيتم التنفيذ عبر Inventory Module مع ربط المحاسبة
    console.log(`[Accounting] Inventory adjustment: ${itemId} ${direction} ${quantity}`);
  }

  async _saveJournalEntry(entry) {
    try {
      if (navigator.onLine && this.db) {
        const { collection, doc } = await import('https://www.gstatic.com/firebasejs/10.7.1/firebase-firestore.js');
        await doc(collection(this.db, 'transactions'), entry.id).set(entry);
      }
      this._saveLocal(entry);
      return { success: true, entry, synced: navigator.onLine };
    } catch (error) {
      await this._queueForSync(entry, 'transactions');
      return { success: true, entry, synced: false, queued: true };
    }
  }

  _saveLocal(entry) {
    localStorage.setItem(`alzein_txn_${entry.id}`, JSON.stringify(entry));
    const index = JSON.parse(localStorage.getItem('alzein_txn_index') || '[]');
    if (!index.includes(entry.id)) {      index.push(entry.id);
      localStorage.setItem('alzein_txn_index', JSON.stringify(index));
    }
  }

  async _queueForSync(data, collection) {
    const queue = JSON.parse(localStorage.getItem('alzein_sync_queue') || '[]');
    queue.push({
      id: crypto.randomUUID(), collection, operation: 'set', data,
      timestamp: Date.now(), retryCount: 0
    });
    localStorage.setItem('alzein_sync_queue', JSON.stringify(queue));
    window.dispatchEvent(new CustomEvent('sync:available'));
  }

  async getAccountBalance(accountId, untilDate = null) {
    // تجميع جميع القيود التي تؤثر على هذا الحساب
    return 0; // Placeholder
  }

  async generateTrialBalance(startDate, endDate) {
    return {
      generatedAt: new Date().toISOString(),
      period: { start: startDate, end: endDate },
      accounts: [],
      totals: { debit: 0, credit: 0, difference: 0 }
    };
  }
}
