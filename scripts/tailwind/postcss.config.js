module.exports = {
    plugins: [
        require('tailwindcss')("./scripts/tailwind/tailwind.config.js"),
        require("postcss-elm-css-tailwind")({
            elmFile: "src/Tailwind.elm", // change where the generated Elm module is saved
            elmModuleName: "Tailwind", // this must match the file name or Elm will complain
            nameStyle: "camel" // "snake" for snake case, "camel" for camel case
        }),
    ]
};
