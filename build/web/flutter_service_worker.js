'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "4c498d46808012c5e819db946351fe8a",
"assets/AssetManifest.bin.json": "855452388defc287b0dd3317b4267c15",
"assets/AssetManifest.json": "ac361308d5fae59a6b39119e54d4266d",
"assets/assets/images/babyshower.jpg": "18b3fc5f69c29ea73c5bfa72b2a3b72f",
"assets/assets/images/BaloonBlast.jpg": "756797b2790336c0daf34fdb9540ffaf",
"assets/assets/images/Baloondecor.png": "d22e5fbd9e79cf43d09669bd0e80269f",
"assets/assets/images/birthday-balloons.5b37eb6cd61e.jpg": "5b37eb6cd61ee0cb759267dc1d012220",
"assets/assets/images/birthday-balloons.jpg": "5b37eb6cd61ee0cb759267dc1d012220",
"assets/assets/images/birthday.jpg": "1605e4f83e7933c84e243a65af3a7b00",
"assets/assets/images/Chhathhi.jpg": "f09af60c36de4b6883de6e90c3c7fbdc",
"assets/assets/images/luxury-reception.d651ce9da23c.jpg": "d651ce9da23c3941f0e845186aac8114",
"assets/assets/images/luxury-reception.jpg": "d651ce9da23c3941f0e845186aac8114",
"assets/assets/images/mehndi.jpg": "f0cd39fa09ce10a36d1e732a094d0a7f",
"assets/assets/images/Mirror.jpg": "98512e1a30a94442b7a7ea669421d510",
"assets/assets/images/proposal-candles.b00354b212fe.jpg": "b00354b212fe0ef05e19d72623729d64",
"assets/assets/images/proposal-candles.jpg": "b00354b212fe0ef05e19d72623729d64",
"assets/assets/images/Pyro.jpg": "4f17fab01850ceb912587df9c3f8d7e7",
"assets/assets/images/SmokeEntry.jpg": "4d09aa2c2bf471f5f1abebb28407bc60",
"assets/assets/images/Vanarasam.jpg": "0a0927cef652ffedfc1a008f6a89df6b",
"assets/assets/images/wedding-stage.267d0a7739cf.jpg": "267d0a7739cf14eaa3557952ab5cdd7a",
"assets/assets/images/wedding-stage.jpg": "267d0a7739cf14eaa3557952ab5cdd7a",
"assets/assets/images/welcomebaby.jpg": "d5b56243ef9f69f453c5ec43505a6113",
"assets/assets/videos/Balloonblast.mp4": "0629f28650d2c3ab3640a4b97c620782",
"assets/assets/videos/Birthday.mp4": "85b023f6d13442d62f69d98d86e70745",
"assets/assets/videos/wedding-showcase.87c8570ed122.mp4": "87c8570ed1222db48043145768f9a9c2",
"assets/assets/videos/wedding-showcase.mp4": "87c8570ed1222db48043145768f9a9c2",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/fonts/MaterialIcons-Regular.otf": "0b60cd9226f2dc3f2b441a72bfe9eb41",
"assets/NOTICES": "63e0b2cc6d3873d0898512e1e8f08a45",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "6cfe36b4647fbfa15683e09e7dd366bc",
"canvaskit/canvaskit.js.symbols": "68eb703b9a609baef8ee0e413b442f33",
"canvaskit/canvaskit.wasm": "efeeba7dcc952dae57870d4df3111fad",
"canvaskit/chromium/canvaskit.js": "ba4a8ae1a65ff3ad81c6818fd47e348b",
"canvaskit/chromium/canvaskit.js.symbols": "5a23598a2a8efd18ec3b60de5d28af8f",
"canvaskit/chromium/canvaskit.wasm": "64a386c87532ae52ae041d18a32a3635",
"canvaskit/skwasm.js": "f2ad9363618c5f62e813740099a80e63",
"canvaskit/skwasm.js.symbols": "80806576fa1056b43dd6d0b445b4b6f7",
"canvaskit/skwasm.wasm": "f0dfd99007f989368db17c9abeed5a49",
"canvaskit/skwasm_st.js": "d1326ceef381ad382ab492ba5d96f04d",
"canvaskit/skwasm_st.js.symbols": "c7e7aac7cd8b612defd62b43e3050bdd",
"canvaskit/skwasm_st.wasm": "56c3973560dfcbf28ce47cebe40f3206",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"firebase-messaging-sw.js": "8f439a7cc8204081d66b3f2253420cd0",
"flutter.js": "76f08d47ff9f5715220992f993002504",
"flutter_bootstrap.js": "028076a8969df7c54f2fe293d30d4b4e",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "d4656328922624431ce0b5e6227a408f",
"/": "d4656328922624431ce0b5e6227a408f",
"main.dart.js": "a7825ddf83c75d004a8eb9d638f2506d",
"manifest.json": "a79c75ecae0a9b3ea9ac09211b1b2211",
"robots.txt": "4ebe0d1ab139920b9b281fc81be97758",
"sitemap.xml": "603df917b05b0cf16b984860f6a41b52",
"version.json": "3dd7f0b3b37356c0563c208ef9930611"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
