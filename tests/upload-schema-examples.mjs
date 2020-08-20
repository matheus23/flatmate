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

async function run() {

    // Shop

    const shopSchema = await importJson("../json-schemas/shop.json");
    assert(shopSchema.examples.length > 0);

    for await (const shopExample of shopSchema.examples) {
        const result = await upsertExpectSuccess(shopsId, shopExample);
        console.log(result);
        assert(result.data)
        assert(result.data.name === shopExample.name)
    }

    // Entry

    const entrySchema = await importJson("../json-schemas/entry.json");
    assert(entrySchema.examples.length > 0);

    for await (const entryExample of entrySchema.examples) {
        const result = await upsertExpectSuccess(entriesId, entryExample);
        console.log(result);
        assert(result.data)
        assert(result.data.name === entryExample.name)
    }

    // Items

    const itemSchema = await importJson("../json-schemas/item.json");
    assert(itemSchema.examples.length > 0);

    for await (const item of itemSchema.examples) {
        const result = await upsertExpectSuccess(entriesId, item);
        console.log(result);
        assert(result.data)
        assert(result.data.name === item.name)
    }
}

async function upsertExpectSuccess(collectionId, recordData) {
    const result = await upsert(collectionId, recordData);
    assert(200 <= result.status && result.status < 300);

    return result.json();
}

async function upsert(collectionId, recordData) {
    const url = `http://localhost:8888/v1/buckets/${bucketId}/collections/${collectionId}/records/${recordData.id}`

    const result = await fetch(url, {
        method: "PUT",
        body: JSON.stringify({
            data: recordData
        }),
        headers: {
            "Accept": "application/json",
            "Content-Type": "application/json",
            "Authorization": basicAuth(username, password),
        },
    });

    return result;
}

async function importJson(jsonpath) {
    const fileContent = await fs.readFile(path.join(dirname, jsonpath), "utf8");
    return JSON.parse(fileContent);
}

async function runAndCatch() {
    try {
        await run();
    } catch (e) {
        console.log(e);
        process.exit(1);
    }
}

runAndCatch();
