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
        ["./elm-tailwind-modules-snowpack.js", {
            directory: "./gen",
            moduleName: "Tailwind",
            postcssPlugins: [require("autoprefixer")],
            tailwindConfigPath: "./config/styles.tailwind.js",
            verbose: true,
        }],
        "snowpack-plugin-elm",
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
