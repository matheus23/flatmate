module.exports = {
    plugins: [
        require('tailwindcss')("./scripts/tailwind.config.js"),
        require("postcss-elm-css-tailwind")({
            // The name of your base Tailwind.css file (see below about working with bundlers) 
            baseTailwindCSS: "./css/tailwind.css",
            // The root directory where the code will be generated
            rootOutputDir: "./gen", // the generated output directory 
            // The root module name for both the Utilities and Breakpoints module
            rootModule: "Tailwind",
        }),
        require('autoprefixer'),
    ]
};
