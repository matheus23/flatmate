import '../css/style.css'
// So that we have normalized styles
import 'tailwindcss/dist/base.css'

import { Elm } from './Main.elm';
// import IPFS from 'ipfs'
// import OrbitDB from 'orbit-db'

Elm.Main.init({
    node: document.querySelector('body')
});


// document.addEventListener('DOMContentLoaded', async () => {
//     // IPFS node setup
//     const node = await IPFS.create({ repo: String(Math.random() + Date.now()) })

//     function log(txt) {
//         console.info(txt)
//     }

//     const version = await node.version()

//     log(`The IPFS node version is ${version.version}`)


//     const orbitdb = await OrbitDB.createInstance(node)
//     const db = await orbitdb.log('first-database')
//     log(`db: ${db.address} running`)
//     db.add("test", "asd")
//     db.events.on('replicated', () => {
//         const res = db.iterator({ limit: -1 }).collect().map(e => e.payload.value)
//         log(`replicated! ${res}`)
//     })
//     setInterval(async () => {
//         await db.add('test', "" + new Date().getTime())
//     }, 1000)
// })
