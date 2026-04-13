/**
 * مدير المزامنة الذكي - Offline-First Strategy
 * Local-First + Conflict Resolution (Last-Write-Wins)
 */

import { Collections } from '../config/firestore-schema.js';

export class SyncManager {
  constructor({ db, userId, conflictStrategy = 'server-wins' } = {}) {
    this.db = db;
    this.userId = userId;
    this.conflictStrategy = conflictStrategy;
    this.isSyncing = false;
    this.queueKey = 'alzein_sync_queue';
    this.lastSyncKey = 'alzein_last_sync';
    this._setupEventListeners();
  }

  _setupEventListeners() {
    window.addEventListener('online', () => this.processQueue());
    window.addEventListener('sync:available', () => this.processQueue());
    setInterval(() => {
      if (navigator.onLine && !this.isSyncing) this.processQueue();
    }, 5 * 60 * 1000);
  }

  async enqueue(collection, operation, data, options = {}) {
    const item = {
      id: crypto.randomUUID(), collection, operation, data,
      timestamp: Date.now(), retryCount: 0,
      maxRetries: options.maxRetries || 5,
      priority: options.priority || 'normal',
      meta options.metadata || {}
    };

    const queue = this._getQueue();
    item.priority === 'high' ? queue.unshift(item) : queue.push(item);
    this._saveQueue(queue);
    
    if (navigator.onLine) setTimeout(() => this.processQueue(), 100);
    return item.id;
  }

  async processQueue() {
    if (this.isSyncing || !navigator.onLine) return;
    this.isSyncing = true;
    const queue = this._getQueue();
    const processed = [], failed = [];

    try {      for (const item of queue) {
        if (item.retryCount >= item.maxRetries) {
          failed.push({ ...item, error: 'Max retries exceeded' });
          continue;
        }
        try {
          await this._executeSync(item);
          processed.push(item.id);
          if (item.collection === Collections.TRANSACTIONS) {
            localStorage.setItem(this.lastSyncKey, Date.now().toString());
          }
        } catch (error) {
          item.retryCount += 1;
          item.lastError = error.message;
          item.nextRetry = Date.now() + Math.min(1000 * Math.pow(2, item.retryCount), 30000);
          failed.push(item);
        }
      }
      const remaining = queue.filter(item => 
        !processed.includes(item.id) && item.retryCount < item.maxRetries
      );
      this._saveQueue(remaining);
      window.dispatchEvent(new CustomEvent('sync:complete', {
        detail: { processed: processed.length, failed: failed.length }
      }));
    } finally {
      this.isSyncing = false;
    }
  }

  async _executeSync(item) {
    const { collection, operation, data, timestamp } = item;
    if (!this.db) throw new Error('Firestore not initialized');

    const { doc, setDoc, updateDoc, deleteDoc, getDoc, serverTimestamp } = 
      await import('https://www.gstatic.com/firebasejs/10.7.1/firebase-firestore.js');

    const docRef = doc(this.db, collection, data.id);

    if (operation === 'delete') { await deleteDoc(docRef); return; }

    if (this.conflictStrategy !== 'client-wins') {
      const existing = await getDoc(docRef);
      if (existing.exists()) {
        const serverData = existing.data();
        const serverUpdatedAt = serverData.updatedAt?.toDate?.() || new Date(0);
        const clientUpdatedAt = new Date(data.updatedAt || timestamp);
        
        if (serverUpdatedAt > clientUpdatedAt && this.conflictStrategy === 'server-wins') {
          data = { ...serverData, ...data, auditLog: serverData.auditLog || [] };        }
      }
    }

    const syncData = {
      ...data, syncedAt: serverTimestamp(),
      _syncVersion: (data._syncVersion || 0) + 1
    };

    operation === 'set' ? await setDoc(docRef, syncData) : await updateDoc(docRef, syncData);
    this._removeLocalCopy(collection, data.id);
  }

  async mergeUserData(cloudData, localData) {
    const merged = { ...localData };
    for (const collection of Object.values(Collections)) {
      const cloudItems = cloudData[collection] || [];
      const localItems = localData[collection] || [];
      const cloudMap = new Map(cloudItems.map(i => [i.id, i]));
      const localMap = new Map(localItems.map(i => [i.id, i]));
      const result = [];

      for (const [id, cloudItem] of cloudMap) {
        const localItem = localMap.get(id);
        if (!localItem) {
          result.push(cloudItem);
        } else {
          const cloudTime = new Date(cloudItem.updatedAt || cloudItem.createdAt);
          const localTime = new Date(localItem.updatedAt || localItem.createdAt);
          if (cloudTime >= localTime || this.conflictStrategy === 'server-wins') {
            result.push(cloudItem);
          } else {
            result.push(localItem);
            await this.enqueue(collection, 'update', localItem);
          }
        }
      }

      for (const [id, localItem] of localMap) {
        if (!cloudMap.has(id) && !localItem.syncedAt) {
          result.push(localItem);
          await this.enqueue(collection, 'set', localItem);
        }
      }
      merged[collection] = result;
    }
    return merged;
  }

  _getQueue() {    try { return JSON.parse(localStorage.getItem(this.queueKey) || '[]'); }
    catch { return []; }
  }

  _saveQueue(queue) { localStorage.setItem(this.queueKey, JSON.stringify(queue)); }
  _removeLocalCopy(collection, id) { localStorage.removeItem(`alzein_${collection}_${id}`); }

  getLastSyncTime() { return localStorage.getItem(this.lastSyncKey); }
  
  getQueueStatus() {
    const queue = this._getQueue();
    return {
      pending: queue.length,
      highPriority: queue.filter(i => i.priority === 'high').length,
      retrying: queue.filter(i => i.retryCount > 0).length,
      isSyncing: this.isSyncing
    };
  }

  forceSync() {
    if (!navigator.onLine) throw new Error('No internet connection');
    return this.processQueue();
  }
}
