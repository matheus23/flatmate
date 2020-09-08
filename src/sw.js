import "@babel/polyfill"; // Needed for kinto (regeneratorRuntime)
import Kinto from "kinto";

import { precacheAndRoute } from "workbox-precaching/precacheAndRoute";
import { Elm } from "./ServiceWorker.elm";


// Useful resource for writing webpack-built workbox serviceworkers:
// https://gist.github.com/jeffposnick/fc761c06856fa10dbf93e62ce7c4bd57

precacheAndRoute(self.__WB_MANIFEST);

// Anything that's not precached will fall through, since we didn't 'registerRoute' anything.
// Useful resource: https://developers.google.com/web/tools/workbox/modules/workbox-routing

const kintoEndpoint = "http://localhost:8888/v1";

const kinto = new Kinto({
    remote: kintoEndpoint,
    bucket: "flatmate",
});

const elmSW = Elm.ServiceWorker.init();

elmSW.ports.log.subscribe(async message => {
    const clients = await self.clients.matchAll({
        includeUncontrolled: true
    });
    clients.forEach(client => {
        client.postMessage({ type: "log", content: message });
    });
});

self.addEventListener('fetch', event => {
    if (event.request.url.startsWith(kintoEndpoint)) {
        event.respondWith(async () => {
            return fetch(event.request);
        });
    }
    // request.headers.get(key)
});

self.skipWaiting();
