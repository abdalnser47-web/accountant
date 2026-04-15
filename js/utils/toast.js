/**
 * Toast Notification System
 */

export function showToast(message, type = 'info', duration = 3000) {
    const container = document.getElementById('toast-container');
    if (!container) return;

    const toast = document.createElement('div');
    toast.className = `toast ${type}`;
    toast.textContent = message;
    
    container.appendChild(toast);
    
    // Auto-remove
    setTimeout(() => {
        toast.style.opacity = '0';
        toast.style.transform = 'translateY(-10px)';
        setTimeout(() => toast.remove(), 300);
    }, duration);
    
    // Haptic feedback if supported
    if (navigator.vibrate && type !== 'info') {
        navigator.vibrate(type === 'error' ? [50, 30, 50] : 20);
    }
}
