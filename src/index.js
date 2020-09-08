import "./main.css";
// Normalize styles
import "tailwindcss/dist/base.css";

import { Elm } from "./Main.elm";

const seed = new Uint32Array(10);
window.crypto.getRandomValues(seed);

const app = Elm.Main.init({
  node: document.getElementById("root"),
  flags: { randomness: { r1: seed[1], r2: seed[2], r3: seed[3], r4: seed[4] } }
});

async function loadServiceWorker() {
  try {
    const registration = await navigator.serviceWorker.register('/sw.js');
    // used for native notifications. Best to call this when issuing the first notification
    // registration.pushManager.subscribe({ userVisibleOnly: true });
    console.log('SW registered: ', registration);
  } catch (registrationError) {
    console.log('SW registration failed: ', registrationError);
  }
}

if ('serviceWorker' in navigator) {
  navigator.serviceWorker.addEventListener('message', event => {
    switch (event.data.type) {
      case "log":
        console.log(event.data.content);
        break;
    }
  });

  window.addEventListener('load', loadServiceWorker);
}
window.loadServiceWorker = loadServiceWorker;
