module.exports = {
    cacheId: "matheus23/flatmate",
    clientsClaim: true,
    globDirectory: "build/",
    globPatterns: ["**/*"],
    inlineWorkboxRuntime: true,
    navigateFallback: "index.html",
    runtimeCaching: [],
    skipWaiting: true,
    sourcemap: false,
    swDest: "build/sw.js",
};
