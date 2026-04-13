/**
 * نظام معالجة الأخطاء المركزي مع Logging و Retry
 */

export const ErrorLevel = {
  DEBUG: 'debug', INFO: 'info', WARNING: 'warning',
  ERROR: 'error', CRITICAL: 'critical'
};

export class ErrorHandler {
  static config = {
    maxLogs: 100, sendToServer: true,
    userFeedback: true,
    retryableCodes: ['NETWORK_ERROR', 'TIMEOUT', 'CONFLICT']
  };

  static logs = [];

  static log(error, context = {}) {
    const entry = {
      id: crypto.randomUUID(),
      timestamp: new Date().toISOString(),
      level: error instanceof SecurityError ? ErrorLevel.WARNING : ErrorLevel.ERROR,
      message: error.message || String(error),
      stack: error.stack,
      code: error.code || 'UNKNOWN',
      context,
      userAgent: navigator.userAgent,
      url: window.location.href
    };

    this.logs.unshift(entry);
    if (this.logs.length > this.config.maxLogs) this.logs.pop();
    this._saveLocal(entry);

    if (this.config.sendToServer && navigator.onLine) {
      this._sendToServer(entry).catch(() => {});
    }

    if (this.config.userFeedback && entry.level !== ErrorLevel.DEBUG) {
      this._notifyUser(entry);
    }

    console[entry.level === ErrorLevel.ERROR ? 'error' : 'log']('[Alzein Error]', entry);
    return entry.id;
  }

  static async withRetry(fn, options = {}) {
    const {
      maxAttempts = 3, delayMs = 1000, onRetry = null,      retryable = (err) => this.config.retryableCodes.includes(err?.code)
    } = options;

    let lastError;
    for (let attempt = 1; attempt <= maxAttempts; attempt++) {
      try { return await fn(); }
      catch (error) {
        lastError = error;
        if (!retryable(error) || attempt === maxAttempts) {
          this.log(error, { attempt, context: options.context });
          throw error;
        }
        if (onRetry) onRetry(error, attempt);
        await new Promise(r => setTimeout(r, delayMs * Math.pow(2, attempt - 1)));
      }
    }
  }

  static wrap(fn, errorHandler = null) {
    return async (...args) => {
      try { return await fn(...args); }
      catch (error) {
        if (errorHandler) return errorHandler(error);
        this.log(error, { fn: fn.name, args });
        throw error;
      }
    };
  }

  static exportLogs(format = 'json') {
    if (format === 'json') return JSON.stringify(this.logs, null, 2);
    if (format === 'csv') {
      const headers = ['timestamp', 'level', 'code', 'message', 'context'];
      const rows = this.logs.map(log => headers.map(h => JSON.stringify(log[h] || '')).join(','));
      return [headers.join(','), ...rows].join('\n');
    }
  }

  static clearLogs(keepCritical = true) {
    this.logs = keepCritical ? this.logs.filter(l => l.level === ErrorLevel.CRITICAL) : [];
    localStorage.setItem('alzein_error_logs', JSON.stringify(this.logs));
  }

  static _saveLocal(entry) {
    try {
      localStorage.setItem(`alzein_error_${entry.id}`, JSON.stringify(entry));
      const index = JSON.parse(localStorage.getItem('alzein_error_index') || '[]');
      index.unshift(entry.id);
      if (index.length > 50) index.pop();
      localStorage.setItem('alzein_error_index', JSON.stringify(index));    } catch (e) {}
  }

  static async _sendToServer(entry) {
    console.log('[ErrorHandler] Would send to server:', entry.id);
  }

  static _notifyUser(entry) {
    if (typeof showToast === 'function') {
      const messages = {
        [ErrorLevel.ERROR]: 'حدث خطأ غير متوقع',
        [ErrorLevel.WARNING]: 'تنبيه: تحقق من الصلاحيات',
        [ErrorLevel.CRITICAL]: 'خطأ حرج: يرجى إعادة التحميل'
      };
      showToast(messages[entry.level] || entry.message, 
        entry.level === ErrorLevel.CRITICAL ? 'error' : 'warning',
        { duration: 5000, action: 'عرض التفاصيل' });
    }
  }
}

// Global error capture
window.addEventListener('error', (e) => {
  ErrorHandler.log(e.error || e, { source: 'global', filename: e.filename });
});
window.addEventListener('unhandledrejection', (e) => {
  ErrorHandler.log(e.reason, { source: 'promise' });
});
