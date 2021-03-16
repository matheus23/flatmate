const elmTailwindModules = require("elm-tailwind-modules/dist/index.js");
const path = require("path");
const fs = require("fs");

module.exports = function (snowpackConfig, pluginOptions) {
    return {
        name: "elm-tailwind-modules-plugin",
        config() {
            this.tailwindConfigPath = path.resolve(pluginOptions.tailwindConfigPath);
        },
        async run({ isDev }) {
            await this.runCodegen();
            if (isDev) {
                console.log(`elm-tailwind-modules-plugin watches "${pluginOptions.tailwindConfigPath}".`);
                fs.watchFile(this.tailwindConfigPath, async () => {
                    console.log(`"${pluginOptions.tailwindConfigPath}" changed, running elm-tailwind-modules.`);
                    await this.runCodegen();
                });
            }
        },
        async runCodegen() {
            this.tailwindConfig = require(this.tailwindConfigPath);
            await elmTailwindModules.run({
                directory: pluginOptions.directory,
                moduleName: pluginOptions.moduleName,
                generateDocumentation: pluginOptions.generateDocumentation,
                postcssPlugins: pluginOptions.postcssPlugins,
                tailwindConfig: this.tailwindConfig,
                logFunction: msg => console.log(msg)
            });
        }
    };
};
