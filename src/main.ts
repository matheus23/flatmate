import IPFS from 'ipfs';
import OrbitDB from 'orbit-db';

const node = new IPFS({ repo: String(Math.random() + Date.now()) })
node.on('ready', async () => {
    const version = await node.version()

    console.log(`The IPFS node version is ${version.version}`)

    const orbitdb = await OrbitDB.createInstance(node)
    const db = await orbitdb.docstore('first-database')
    window["db"] = db;
    console.log(`db: ${db.address} running`)
    db.put("test", "asd")
    db.events.on('replicated', () => {
        const res = db.query(() => true)
        console.log(`replicated! ${res}`)
    })
    setInterval(async () => {
        await db.put('test', "" + new Date().getTime())
    }, 1000)
})