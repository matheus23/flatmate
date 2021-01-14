import elmTailwindOrigami from "elm-tailwind-origami";
import tailwindConfig from "../tailwind/tailwind.config.js";
import autoprefixer from "autoprefixer";

elmTailwindOrigami({
    directory: "./gen",
    moduleName: "Tailwind",
    postcssPlugins: [autoprefixer],
    tailwindConfig,
});
