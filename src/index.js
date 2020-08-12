import "./main.css";
// Normalize styles
import "tailwindcss/dist/base.css";

import { Elm } from "./Main.elm";
import * as serviceWorker from "./serviceWorker";
import "@babel/polyfill"; // Needed for kinto (regeneratorRuntime)
import Kinto from "kinto";

const app = Elm.Main.init({
  node: document.getElementById("root"),
});

const kinto = new Kinto({
  remote: "http://localhost:8888/v1/",
  bucket: "shopping-list-test",
});
const shoppingList = kinto.collection("shopping-list");

app.ports.kintoSend.subscribe((message) => {
  switch (message.command) {
    case "add-item":
      shoppingList.create({ title: message.shoppingItem, content: "empty!" });
      shoppingList.sync();
      break;
    default:
      console.error(`unknown command ${message}`);
  }
});

// If you want your app to work offline and load faster, you can change
// unregister() to register() below. Note this comes with some pitfalls.
// Learn more about service workers: https://bit.ly/CRA-PWA
serviceWorker.unregister();
