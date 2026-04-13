/**
 * أدوات الأمان: Safe Parser + Encryption + Sanitization
 */

export const Security = {
  safeCalculate(expression) {
    const sanitized = expression
      .replace(/[^0-9+\-*/().,\s]/g, '')
      .replace(/,/g, '.')
      .trim();

    const parenCount = sanitized.split('').reduce((acc, char) => {
      if (char === '(') return acc + 1;
      if (char === ')') return acc - 1;
      return acc;
    }, 0);
    
    if (parenCount !== 0) throw new SyntaxError('Unbalanced parentheses');

    try {
      const result = Function(`"use strict"; return (${sanitized})`)();
      if (typeof result !== 'number' || !isFinite(result)) {
        throw new Error('Invalid calculation result');
      }
      return Math.round(result * 100) / 100;
    } catch (e) {
      throw new Error(`Calculation error: ${e.message}`);
    }
  },

  safeEvaluate(expression, variables = {}) {
    const scope = Object.create(null);
    Object.keys(variables).forEach(key => {
      if (/^[a-zA-Z_][a-zA-Z0-9_]*$/.test(key)) scope[key] = variables[key];
    });

    const sanitized = expression.replace(/[^a-zA-Z0-9+\-*/().,\s_$]/g, '').replace(/,/g, '.');

    try {
      const keys = Object.keys(scope);
      const values = Object.values(scope);
      const fn = new Function(...keys, `"use strict"; return (${sanitized})`);
      const result = fn(...values);
      if (typeof result !== 'number' || !isFinite(result)) throw new Error('Invalid result');
      return Math.round(result * 100) / 100;
    } catch (e) {
      throw new Error(`Evaluation error: ${e.message}`);
    }
  },
  encrypt(data, secretKey) {
    if (!secretKey) {
      console.warn('Encryption called without key - data stored plaintext');
      return JSON.stringify(data);
    }
    try {
      // Simple XOR-based encryption for demo (use CryptoJS in production)
      const json = JSON.stringify(data);
      let encrypted = '';
      for (let i = 0; i < json.length; i++) {
        encrypted += String.fromCharCode(
          json.charCodeAt(i) ^ secretKey.charCodeAt(i % secretKey.length)
        );
      }
      return btoa(encrypted);
    } catch (e) {
      console.error('Encrypt error:', e);
      return null;
    }
  },

  decrypt(encryptedData, secretKey) {
    if (!secretKey || !encryptedData) return null;
    try {
      const decoded = atob(encryptedData);
      let decrypted = '';
      for (let i = 0; i < decoded.length; i++) {
        decrypted += String.fromCharCode(
          decoded.charCodeAt(i) ^ secretKey.charCodeAt(i % secretKey.length)
        );
      }
      return JSON.parse(decrypted);
    } catch (e) {
      console.error('Decrypt error:', e);
      return null;
    }
  },

  deriveKey(password, salt = 'alzein-salt-v1') {
    let hash = 0;
    const str = password + salt;
    for (let i = 0; i < str.length; i++) {
      hash = ((hash << 5) - hash) + str.charCodeAt(i);
      hash |= 0;
    }
    return Math.abs(hash).toString(36);
  },

  sanitize(input) {
    if (typeof input !== 'string') return input;    const map = { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#039;' };
    return input.replace(/[&<>"']/g, char => map[char]);
  },

  async verifyPIN(inputPin, storedHash) {
    const inputHash = await this._hashPIN(inputPin);
    return inputHash === storedHash;
  },

  async _hashPIN(pin) {
    const encoder = new TextEncoder();
    const data = encoder.encode(`alzein-pin:${pin}`);
    const hashBuffer = await crypto.subtle.digest('SHA-256', data);
    const hashArray = Array.from(new Uint8Array(hashBuffer));
    return hashArray.map(b => b.toString(16).padStart(2, '0')).join('');
  },

  generateClientId() {
    const timestamp = Date.now().toString(36);
    const random = Math.random().toString(36).substring(2, 8);
    return `AZN-${timestamp}-${random}`.toUpperCase();
  }
};

export const calculate = Security.safeCalculate;
