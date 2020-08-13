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

function attachPorts(app) {

  const kinto = new Kinto({
    remote: "http://localhost:8888/v1/",
    bucket: "shopping-list-test",
  });
  const shoppingList = kinto.collection("shopping-list");
  
  const sendCurrentList = async () => {
    const currentList = await shoppingList.list();
    app.ports.kintoReceive.send(currentList.data);
  }

  const commands = {
    add: async title => {
      await shoppingList.create({ title: title, content: "empty!" });
      await sendCurrentList()
    },
    update: async ({item}) => {
      await shoppingList.update(item);
      await sendCurrentList()
    },
    delete: async id => {
      await shoppingList.delete(id)
      await sendCurrentList();
    },
    fetchList : async () => {
      await sendCurrentList();
    }
  }

  app.ports.kintoSend.subscribe(async ({command, argument}) => {
    const executor = commands[command]
    if(!executor) {
      console.error("unknown command", command)
      return;
    }
    await executor(argument)
  });
}

attachPorts(app)


// If you want your app to work offline and load faster, you can change
// unregister() to register() below. Note this comes with some pitfalls.
// Learn more about service workers: https://bit.ly/CRA-PWA
serviceWorker.unregister();
