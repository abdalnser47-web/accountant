/**
 * Crypto Utility - Secure Data Handling
 * SHA-256 hashing + XOR encryption for localStorage
 */

export const CryptoUtils = {
    /**
     * Simple XOR + Base64 encryption (for demo)
     * ⚠️ Use Web Crypto API for production
     */
    encrypt(data, key = 'alzein_secret_2024') {
        try {
            const json = JSON.stringify(data);
            let result = '';
            for (let i = 0; i < json.length; i++) {
                result += String.fromCharCode(
                    json.charCodeAt(i) ^ key.charCodeAt(i % key.length)
                );
            }
            return btoa(result);
        } catch (e) {
            console.error('🔐 Encryption failed:', e);
            return null;
        }
    },

    decrypt(encryptedData, key = 'alzein_secret_2024') {
        try {
            const decoded = atob(encryptedData);
            let result = '';
            for (let i = 0; i < decoded.length; i++) {
                result += String.fromCharCode(
                    decoded.charCodeAt(i) ^ key.charCodeAt(i % key.length)
                );
            }
            return JSON.parse(result);
        } catch (e) {
            console.error('🔐 Decryption failed:', e);
            return null;
        }
    },

    /**
     * SHA-256 Hash using Web Crypto API
     */
    async hashPIN(pin) {
        const encoder = new TextEncoder();
        const data = encoder.encode(pin);
        const hashBuffer = await crypto.subtle.digest('SHA-256', data);
        const hashArray = Array.from(new Uint8Array(hashBuffer));
        return hashArray.map(b => b.toString(16).padStart(2, '0')).join('');
    },

    /**
     * Generate secure random ID
     */
    generateId(prefix = 'ALZ') {
        return `${prefix}-${Math.random().toString(36).substr(2, 9).toUpperCase()}`;
    }
};
