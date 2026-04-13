/**
 * نظام إدارة حالة خفيف الوزن مع دعم الاشتراكات
 */

export class StateManager {
  constructor(initialState = {}) {
    this._state = {
      user: null,
      auth: { loading: true, error: null },
      inventory: { items: [], loading: false, lastUpdate: null },
      accounting: { 
        accounts: [], transactions: [], 
        summary: { balance: 0, receivable: 0, payable: 0 }
      },
      settings: {
        currency: 'USD', language: 'ar',
        privacyMode: false, theme: 'neon-dark'
      },
      sync: { status: 'idle', lastSync: null, queueLength: 0 },
      ui: { activeView: 'dashboard', notifications: [], loading: false },
      ...initialState
    };
    this._subscribers = new Map();
    this._computed = new Map();
    this._loadPersistedState();
  }

  get(path, defaultValue = null) {
    return path.split('.').reduce((obj, key) => obj?.[key] ?? defaultValue, this._state);
  }

  set(path, value, options = {}) {
    const keys = path.split('.');
    const lastKey = keys.pop();
    const target = keys.reduce((obj, key) => {
      if (!(key in obj)) obj[key] = {};
      return obj[key];
    }, this._state);
    
    const oldValue = target[lastKey];
    target[lastKey] = value;
    this._updateComputed(path);
    
    if (options.persist) this._persist(path, value);
    if (!options.silent) this._notify(path, value, oldValue, options);
    return this;
  }

  batch(updates) {
    for (const [path, value] of Object.entries(updates)) {      this.set(path, value, { silent: true });
    }
    this._notify('*', updates);
    return this;
  }

  subscribe(path, callback) {
    if (!this._subscribers.has(path)) this._subscribers.set(path, new Set());
    this._subscribers.get(path).add(callback);
    return () => this._subscribers.get(path)?.delete(callback);
  }

  computed(name, dependencies, computeFn) {
    this._computed.set(name, { dependencies, computeFn });
    this._updateComputed(name);
    return () => this.get(`_computed.${name}`);
  }

  _updateComputed(changedPath) {
    for (const [name, { dependencies, computeFn }] of this._computed) {
      if (dependencies.some(dep => changedPath === dep || changedPath.startsWith(dep + '.'))) {
        const value = computeFn(this);
        this.set(`_computed.${name}`, value, { silent: true });
      }
    }
  }

  _notify(path, newValue, oldValue, options) {
    if (options?.silent) return;
    const notify = (p) => {
      this._subscribers.get(p)?.forEach(cb => {
        try { cb(newValue, oldValue, { path, timestamp: Date.now() }); }
        catch (err) { console.error('Subscriber error:', err); }
      });
    };
    notify(path);
    notify('*');
  }

  _persist(path, value) {
    const persistablePaths = ['settings', 'ui.activeView'];
    if (persistablePaths.some(p => path === p || path.startsWith(p + '.'))) {
      const key = `alzein_state_${path.replace(/\./g, '_')}`;
      try { localStorage.setItem(key, JSON.stringify(value)); }
      catch (e) { console.warn('Persist failed:', e); }
    }
  }

  _loadPersistedState() {
    const settings = localStorage.getItem('alzein_state_settings');    if (settings) {
      try { this._state.settings = { ...this._state.settings, ...JSON.parse(settings) }; }
      catch (e) { console.warn('Load settings failed:', e); }
    }
  }

  reset(path) {
    const initial = { user: null, auth: { loading: true, error: null } };
    return this.set(path || '_', path ? initial[path] : initial);
  }

  toJSON() { return { ...this._state }; }
}

export const createState = (initial) => new StateManager(initial);
