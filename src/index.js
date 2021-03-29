import "./main.css";
import { Elm } from "./Main.elm";
import * as webnative from "webnative";
// import * as heartbeat from "./heartbeat.js";

webnative.setup.debug({ enabled: true });
window.webnative = webnative;

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
app.ports.redirectToLobby.subscribe(async () => {
  await webnative.redirectToLobby(permissions)
})

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

    app.ports.fsRequest.subscribe(async request => {
      const key = request.key
      try {
        const preprocess = request.preprocess
        const postprocess = request.postprocess
        const method = request.call.method
        let args = request.call.args

        for (const { index, process } of preprocess) {
          if (process === "encodeUtf8") {
            args[index] = new TextEncoder().encode(args[index])
          }
        }

        let result = await fs[method].apply(fs, args)

        if (postprocess === "decodeUtf8") {
          result = new TextDecoder().decode(result)
        }

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
