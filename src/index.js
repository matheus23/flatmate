import '../css/style.css'
// So that we have normalized styles
import 'tailwindcss/dist/base.css'

import { Elm } from './Main.elm';
import IPFS from 'ipfs';
import OrbitDB from 'orbit-db';
import IPFSClient from 'ipfs-http-client';

async function main() {
    // const node = await IPFS.create({
    //     repo: String(Math.random() + Date.now()),
    //     EXPERIMENTAL: {
    //         pubsub: true,
    //     },
    //     config: {
    //         Addresses: {
    //             Swarm: [
    //                 // Use IPFS dev signal server
    //                 // Websocket:
    //                 '/dns4/ws-star-signal-1.servep2p.com/tcp/443/wss/p2p-websocket-star',
    //                 '/dns4/ws-star-signal-2.servep2p.com/tcp/443/wss/p2p-websocket-star',
    //                 '/dns4/ws-star.discovery.libp2p.io/tcp/443/wss/p2p-websocket-star',
    //                 // WebRTC:
    //                 // '/dns4/star-signal.cloud.ipfs.team/wss/p2p-webrtc-star',
    //                 // Use local signal server
    //                 // '/ip4/0.0.0.0/tcp/4002/ws/p2p-circuit',
    //             ]
    //         },
    //     },
    // });
    const node = IPFSClient('/ip4/127.0.0.1/tcp/4003');
    console.log(`IPFS version ${(await node.version()).version}`);
    const orbitdb = await OrbitDB.createInstance(node);
    window.orbitdb = orbitdb;
    console.log(`loaded orbitdb ${orbitdb.identity.id}`);

    const db = await orbitdb.log('first-database', {
        accessController: {
            write: ['*']
        }
    });
    // const db = await orbitdb.log('/orbitdb/zdpuB1PsYMn8XY2prCRNkYRW65oWuirJA2DgTGQuyLddjtCZJ/first-database');
    window.db = db;
    console.log('loaded db');


    Elm.Main.init({
        node: document.querySelector('body')
    });
}

main();
