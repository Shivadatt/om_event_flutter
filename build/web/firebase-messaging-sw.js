// ============================================================
// Firebase Cloud Messaging Service Worker for Flutter Web
// ============================================================
// Config values sourced from firebase_options.dart (Web platform):
//   apiKey        : 'AIzaSyDSsocB8vMnFd4d13moCQBmKqB9wEtjfvY'
//   authDomain    : 'om-event.firebaseapp.com'
//   projectId     : 'om-event'
//   storageBucket : 'om-event.firebasestorage.app'
//   messagingSenderId : '443981257323'
//   appId         : '1:443981257323:web:845ec22c4774094264af2e'
//   measurementId : 'G-RTEJQ1HFKY'
// ============================================================

importScripts('https://www.gstatic.com/firebasejs/10.12.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.12.0/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: 'AIzaSyDSsocB8vMnFd4d13moCQBmKqB9wEtjfvY',
  authDomain: 'om-event.firebaseapp.com',
  projectId: 'om-event',
  storageBucket: 'om-event.firebasestorage.app',
  messagingSenderId: '443981257323',
  appId: '1:443981257323:web:845ec22c4774094264af2e',
  measurementId: 'G-RTEJQ1HFKY',
});

const messaging = firebase.messaging();

// ============================================================
// Background Message Handler
// Called when the app is in the BACKGROUND or TERMINATED state.
// ============================================================
messaging.onBackgroundMessage(function (payload) {
  console.log('[firebase-messaging-sw.js] Background message received:', payload);

  const notification = payload.notification || {};
  const data = payload.data || {};

  const notificationTitle = notification.title || data.title || 'Om Events';
  const notificationOptions = {
    body: notification.body || data.body || '',
    icon: '/icons/Icon-192.png',
    badge: '/icons/Icon-192.png',
    data: data,
    tag: data.tag || 'om-events-notification',
    renotify: true,
  };

  return self.registration.showNotification(notificationTitle, notificationOptions);
});

// ============================================================
// Notification Click Handler — navigates to the correct page
// ============================================================
self.addEventListener('notificationclick', function (event) {
  event.notification.close();

  const data = event.notification.data || {};
  const type = data.type || '';
  const url = data.url || '/';

  let targetUrl = '/';
  if (type === 'booking') {
    targetUrl = '/dashboard';
  } else if (type === 'admin') {
    targetUrl = '/admin-dashboard';
  } else if (url) {
    targetUrl = url;
  }

  event.waitUntil(
    clients.matchAll({ type: 'window', includeUncontrolled: true }).then(function (windowClients) {
      for (let i = 0; i < windowClients.length; i++) {
        const client = windowClients[i];
        if (client.url.includes(self.location.origin) && 'focus' in client) {
          client.focus();
          client.navigate(targetUrl);
          return;
        }
      }
      if (clients.openWindow) {
        return clients.openWindow(targetUrl);
      }
    })
  );
});
