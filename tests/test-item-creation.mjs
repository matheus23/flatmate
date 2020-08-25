import fetch from "node-fetch";
import { promises as fs } from "fs";
import path from "path";
import { fileURLToPath } from "url";

const dirname = path.dirname(fileURLToPath(import.meta.url));

const username = "admin";
const password = "Flatmate";
const bucketId = "flatmate";
const shopsId = "shops";
const itemsId = "items";
const suggestionsId = "suggestions";
const endpoint = "http://localhost:8888/v1"; // kinto endpoint
const headers = {
    "Accept": "application/json",
    "Content-Type": "application/json",
    "Authorization": basicAuth(username, password),
};

function basicAuth(username, password) {
    const authBase64 = Buffer.from(`${username}:${password}`).toString("base64");
    return `Basic ${authBase64}`;
}

function assert(cond, message) {
    if (!cond) {
        throw new Error(message || "Assertion failed");
    }
}

async function loadSchemaFile(filename) {
    const file = await fs.readFile(
        path.resolve(dirname, "..", "json-schemas", filename),
        { encoding: "utf-8" }
    );
    return JSON.parse(file);
}

async function upsert(collectionId, record) {
    const url = `${endpoint}/buckets/${bucketId}/collections/${collectionId}/records/${record.id}`;

    return await fetch(url, {
        method: "PUT",
        body: JSON.stringify({
            data: record
        }),
        headers,
    });
}

async function updateSchema(collectionId, schema) {
    const url = `${endpoint}/buckets/${bucketId}/collections/${collectionId}`;

    return await fetch(url, {
        method: "PATCH",
        body: JSON.stringify({
            data: { schema }
        }),
        headers,
    });
}

async function tryAddingExamplesFromSchemaFiles() {
    const schemaShops = await loadSchemaFile("shop.json");
    const schemaSuggestions = await loadSchemaFile("suggestion.json");
    const schemaItems = await loadSchemaFile("item.json");

    async function testExample(example, collectionId) {
        const result = await upsert(collectionId, example);
        assert(result != null, "Expected non-null response");
        assert(result.status != null, "Expected non-null status in response");
        assert(200 <= result.status && result.status < 300,
            `Expected 2xx status code, but was ${result.status}
            Record: ${JSON.stringify(example)}
            Collection: ${collectionId}`
        );
        const data = await result.json();
        assert(data != null, "Expected non-null json response");
    }

    for await (const shopExample of schemaShops.examples) {
        await testExample(shopExample, shopsId);
    }

    for await (const entryExample of schemaSuggestions.examples) {
        await testExample(entryExample, suggestionsId);
    }

    for await (const itemExample of schemaItems.examples) {
        await testExample(itemExample, itemsId);
    }
}

async function updateSchemasInCollections() {
    const schemaShops = await loadSchemaFile("shop.json");
    const schemaSuggestions = await loadSchemaFile("suggestion.json");
    const schemaItems = await loadSchemaFile("item.json");

    async function assertOk(response) {
        assert(
            200 <= response.status && response.status < 300,
            `Got response.status ${response.status} while setting up schemas.`
        );
    }

    await assertOk(await updateSchema(shopsId, schemaShops));
    console.log("Updated shop schema.");
    await assertOk(await updateSchema(suggestionsId, schemaSuggestions));
    console.log("Updated entry schema.");
    await assertOk(await updateSchema(itemsId, schemaItems));
    console.log("Updated item schema.");
}

async function runWithCatch() {
    try {
        await updateSchemasInCollections();
        await tryAddingExamplesFromSchemaFiles();
    } catch (e) {
        console.error(e);
        process.exit(1);
    }
}

runWithCatch();