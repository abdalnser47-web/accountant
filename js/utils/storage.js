/**
 * Storage Utility - Safe LocalStorage Wrapper
 * With encryption support and sync queue
 */

import { CryptoUtils } from './crypto.js';

export const StorageUtils = {
    prefix: 'alzein_',
    syncQueue: [],

    /**
     * Set item with optional encryption and sync
     */
    set(key, value, { encrypt = false, sync = false } = {}) {
        try {
            const storageKey = this.prefix + key;
            const data = encrypt 
                ? CryptoUtils.encrypt(value) 
                : JSON.stringify(value);
            
            localStorage.setItem(storageKey, data);
            
            if (sync && navigator.onLine) {
                this.addToSyncQueue(key, value);
            }
            return true;
        } catch (e) {
            console.error(`❌ Storage set failed: ${key}`, e);
            return false;
        }
    },

    /**
     * Get item with optional decryption
     */
    get(key, { decrypt = false } = {}) {
        try {
            const storageKey = this.prefix + key;
            const data = localStorage.getItem(storageKey);
            if (!data) return null;
            return decrypt ? CryptoUtils.decrypt(data) : JSON.parse(data);
        } catch (e) {
            console.error(`❌ Storage get failed: ${key}`, e);
            return null;
        }
    },

    /**
     * Remove item
     */
    remove(key) {
        localStorage.removeItem(this.prefix + key);
    },

    /**
     * Clear all app data
     */
    clear() {
        Object.keys(localStorage)
            .filter(k => k.startsWith(this.prefix))
            .forEach(k => localStorage.removeItem(k));
    },

    /**
     * Offline-First Sync Queue
     */
    addToSyncQueue(key, value) {
        this.syncQueue.push({
            key,
            value,
            timestamp: Date.now(),
            id: `${key}_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`
        });
        this.processSyncQueue();
    },

    async processSyncQueue() {
        if (!navigator.onLine || this.syncQueue.length === 0) return;
        
        console.log(`📤 Processing ${this.syncQueue.length} sync items...`);
        
        // TODO: Implement Firebase sync here
        // For now, just clear queue on success simulation
        this.syncQueue = [];
    },

    /**
     * Initialize sync listeners
     */
    initSyncListener() {
        window.addEventListener('online', () => this.processSyncQueue());
        window.addEventListener('offline', () => {
            console.log('📴 Offline mode - queuing changes');
        });
    }
};

// Auto-init sync listener
StorageUtils.initSyncListener();
