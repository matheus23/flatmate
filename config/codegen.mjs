import elmTailwindOrigami from "elm-tailwind-origami";
import tailwindConfig from "../config/styles.tailwind.js";
import autoprefixer from "autoprefixer";

elmTailwindOrigami({
    directory: "./gen",
    moduleName: "Tailwind",
    postcssPlugins: [autoprefixer],
    tailwindConfig,
});
