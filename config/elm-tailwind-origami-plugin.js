// Shelved for now. Need to figure out how to define this using ESM (since elm-tailwind-origami requires ESM)

const elmTailwindOrigami = require("elm-tailwind-origami");
const autoprefixer = require("autoprefixer");

module.exports = function (snowpackConfig, pluginOptions) {
    return {
        name: "elm-tailwind-origami-plugin",
        resolve: { input: [".tailwind.js"], output: [".elm"] },
        knownEntrypoints: ["elm-tailwind-origami", "autoprefixer"],
        config() {
        },
        async load({ filePath, isDev }) {
            const tailwindConfig = require(filePath);
            console.log("loaded tailwind config");
            elmTailwindOrigami({
                directory: "./gen",
                moduleName: "Tailwind",
                postcssPlugins: [autoprefixer],
                tailwindConfig,
            });
            this.markChanged("./gen/Tailwind.elm");
        }
    };
};
