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
function attachPorts() {

  const kinto = new Kinto({
    remote: "http://localhost:8888/v1/",
    bucket: "shopping-list-test",
  });
  const shoppingList = kinto.collection("shopping-list");
  
  const sendCurrentList = async () => {
    const currentList = await shoppingList.list();
    app.ports.kintoReceive.send(currentList.data);
  }

  app.ports.kintoSend.subscribe(async (message) => {
    switch (message.command) {
      case "add":
        await shoppingList.create({ title: message.title, content: "empty!" });
        await sendCurrentList()
        break;
      case "update":
        shoppingList.update(message.item);
      case "list-items":
        await sendCurrentList()
        break;
      case "remove":
        await shoppingList.delete(message.id)
        await sendCurrentList()
      case "sync":
        const ads = await shoppingList.sync();
        console.log(ads)
      
      default:
        console.error(`unknown command`, message);
    }
  });
}
attachPorts(app)


// If you want your app to work offline and load faster, you can change
// unregister() to register() below. Note this comes with some pitfalls.
// Learn more about service workers: https://bit.ly/CRA-PWA
serviceWorker.unregister();
