import fetch from "node-fetch";
import { promises as fs } from "fs";
import path from "path";
import { fileURLToPath } from "url";

const username = "admin";
const password = "Flatmate";
const bucketId = "flatmate";
const shopsId = "shops";
const itemsId = "items";
const entriesId = "entries";

const dirname = path.dirname(fileURLToPath(import.meta.url));

function basicAuth(username, password) {
    const authBase64 = Buffer.from(`${username}:${password}`).toString("base64");
    return `Basic ${authBase64}`;
}

function assert(cond) {
    if (!cond) {
        throw new Error("assertion failed")
    }
}
            "utf8"
        ) //testasddas
    );
    console.log(await addShop(shopSchema.examples[0]));
}

async function upsertShop(shopData) {
    const url = `http://localhost:8888/v1/buckets/${bucketId}/collections/${shopsId}/records/${shopData.id}`
    
    const result = await fetch(url, {
        method: "PUT",
        body: JSON.stringify({
            data: shopData
        }),
        headers: {
            "Accept": "application/json",
            "Content-Type": "application/json",
            "Authorization": basicAuth(username, password),
        },
    });

    return await result.json();
}

run();
