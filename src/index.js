import "./main.css";
// Normalize styles
import "tailwindcss/dist/base.css";

import { Elm } from "./Main.elm";
import * as serviceWorker from "./serviceWorker";
import "@babel/polyfill"; // Needed for kinto (regeneratorRuntime)

const seed = new Uint32Array(10);
window.crypto.getRandomValues(seed);

const app = Elm.Main.init({
  node: document.getElementById("root"),
  flags: { randomness: { r1: seed[1], r2: seed[2], r3: seed[3], r4: seed[4] } }
});


// If you want your app to work offline and load faster, you can change
// unregister() to register() below. Note this comes with some pitfalls.
// Learn more about service workers: https://bit.ly/CRA-PWA
serviceWorker.unregister();
