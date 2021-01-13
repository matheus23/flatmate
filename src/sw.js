import { precacheAndRoute } from "workbox-precaching/precacheAndRoute";

// Useful resource for writing webpack-built workbox serviceworkers:
// https://gist.github.com/jeffposnick/fc761c06856fa10dbf93e62ce7c4bd57

precacheAndRoute(self.__WB_MANIFEST);

// Anything that's not precached will fall through, since we didn't 'registerRoute' anything.
// Useful resource: https://developers.google.com/web/tools/workbox/modules/workbox-routing

async function clientLog(message) {
    const clients = await self.clients.matchAll({
        includeUncontrolled: true
    });
    clients.forEach(client => {
        client.postMessage({ type: "log", content: message });
    });
}

self.skipWaiting();
