// Service Worker - Offline-First Strategy
const CACHE_NAME = 'alzein-v1';
const ASSETS_TO_CACHE = [
  '/',
  '/index.html',
  '/css/style.css',
  '/css/responsive.css',
  '/js/app.js',
  '/assets/icons/icon-192.png',
  '/assets/icons/icon-512.png'
];

// Install: Cache core assets
self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then((cache) => cache.addAll(ASSETS_TO_CACHE))
      .then(() => self.skipWaiting())
  );
});

// Activate: Clean old caches
self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((keys) => 
      Promise.all(keys
        .filter((key) => key !== CACHE_NAME)
        .map((key) => caches.delete(key))
      )
    ).then(() => self.clients.claim())
  );
});

// Fetch: Network-first with cache fallback
self.addEventListener('fetch', (event) => {
  // Skip non-GET requests
  if (event.request.method !== 'GET') return;
  
  event.respondWith(
    fetch(event.request)
      .then((response) => {
        // Cache successful responses
        if (response.ok) {
          const clone = response.clone();
          caches.open(CACHE_NAME).then((cache) => cache.put(event.request, clone));
        }
        return response;
      })
      .catch(() => caches.match(event.request)) // Fallback to cache
  );
});

// Background sync for offline transactions (future enhancement)
self.addEventListener('sync', (event) => {
  if (event.tag === 'sync-transactions') {
    event.waitUntil(syncPendingTransactions());
  }
});

async function syncPendingTransactions() {
  // Will be implemented with Firebase integration
  console.log('🔄 Syncing pending transactions...');
}
