// Snowpack Configuration File
// See all supported options: https://www.snowpack.dev/reference/configuration

/** @type {import("snowpack").SnowpackUserConfig } */
module.exports = {
    mount: {
        "../src": "/",
    },
    optimize: {
        bundle: true,
        minify: true,
        target: 'es2018'
    },
    plugins: [
        "snowpack-plugin-elm",
        // "./elm-tailwind-origami-plugin.js", // Shelved for now as for a lack of ESM support
    ],
    packageOptions: {
        /* ... */
    },
    devOptions: {
        open: "none", // Don't open a browser on start
    },
    buildOptions: {
        /* ... */
    },
};
