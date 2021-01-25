async function clientLog(message) {
    const clients = await self.clients.matchAll({
        includeUncontrolled: true
    });
    clients.forEach(client => {
        client.postMessage({ type: "log", content: message });
    });
}

self.skipWaiting();
