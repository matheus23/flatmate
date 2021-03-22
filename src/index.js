import "./main.css";
import { Elm } from "./Main.elm";
import * as webnative from "webnative";
import * as webnativeElm from "webnative-elm";
// import * as heartbeat from "./heartbeat.js";

webnative.setup.debug({ enabled: true });

const seed = new Uint32Array(10);
window.crypto.getRandomValues(seed);

const permissions = {
  app: {
    name: "Flatmate",
    creator: "matheus23-test",
  },
}

const app = Elm.Main.init({
  flags: { randomness: { r1: seed[1], r2: seed[2], r3: seed[3], r4: seed[4] } }
});

app.ports.log.subscribe(msg => console.log("Flatmate Elm:", msg))

async function initializeWebnative() {
  try {

    const state = await webnative.initialise({ permissions });

    let fs = state.fs;

    if (state.authenticated) {
      window.wn = state;
      window.fs = fs;

      const appPath = fs.appPath();
      const appDirectoryExists = await fs.exists(appPath);

      if (!appDirectoryExists) {
        await fs.mkdir(appPath);
        await fs.publish();
      }

      // heartbeat.start({
      //   bpm: 30,
      //   async onBeat() {
      //     fs = await webnative.loadFileSystem(permissions, state.username)
      //     window.fs = fs;
      //     app.ports.heartbeat.send({})
      //   }
      // })
    }

    webnativeElm.setup(app, () => state.fs);

    app.ports.fsRequest.subscribe(async request => {
      try {
        const key = request.key
        const method = request.call.method
        const args = request.call.args
        const result = await fs[method].apply(fs, args)
        app.ports.fsResponse.send({ key, result })
      } catch (err) {
        app.ports.fsResponse.send({ key, error: typeof err.message === "string" ? err.message : "Unknown Error" })
      }
    })

    app.ports.initializedWebnative.send(state);

  } catch (error) {
    console.error("Error while trying to initialize webnative, perhaps your browser is incompatible?");
    console.error(error);
  }
}

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

loadServiceWorker();
initializeWebnative();
