// common
const HtmlWebpackPlugin = require('html-webpack-plugin');
const path = require('path');

// production
const TerserPlugin = require('terser-webpack-plugin');

module.exports = env => {
    const isDev = figureOutBuildmode(env);

    console.log(`Running flatmate packaging with webpack in ${isDev ? 'development' : 'production'} mode.`);

    return {
        mode: isDev ? 'development' : 'production',
        entry: './src/index.js',
        output: {
            path: path.resolve(__dirname, '..', 'dist'),
            filename: 'bundle.js',
        },
        devtool: isDev ? 'inline-source-maps' : undefined,
        devServer: isDev
            ? { contentBase: './dist' }
            : undefined,

        module: {
            rules: [
                {
                    test: /\.elm$/,
                    exclude: [/elm-stuff/, /node_modules/],
                    use:
                        isDev ?
                            [
                                { loader: 'elm-hot-webpack-loader' },
                                {
                                    loader: 'elm-webpack-loader',
                                    options: {}
                                },
                            ] :
                            [
                                {
                                    loader: 'elm-webpack-loader',
                                    options: {
                                        optimize: true,
                                    }
                                },
                            ],
                },
                {
                    test: /\.css$/,
                    use:
                        [
                            'style-loader',
                            {
                                loader: 'postcss-loader',
                                options: { config: { path: './scripts/' } }
                            }
                        ]
                },
            ]
        },

        // from https://github.com/romariolopezc/elm-webpack-starter/blob/d4297e0887283bfdb1bf82603b2e3a5c5096c312/build-utils/webpack.production.js#L39-L60
        optimization: isDev ? {} : {
            minimizer: [
                // https://elm-lang.org/0.19.0/optimize
                new TerserPlugin({
                    extractComments: false,
                    terserOptions: {
                        mangle: false,
                        compress: {
                            pure_funcs:
                                [
                                    'F2', 'F3', 'F4', 'F5', 'F6', 'F7', 'F8', 'F9',
                                    'A2', 'A3', 'A4', 'A5', 'A6', 'A7', 'A8', 'A9',
                                ],
                            pure_getters: true,
                            keep_fargs: false,
                            unsafe_comps: true,
                            unsafe: true,
                        },
                    },
                }),
                new TerserPlugin({
                    extractComments: false,
                    terserOptions: { mangle: true },
                }),
            ],

            // Automatically split vendor and commons
            // https://twitter.com/wSokra/status/969633336732905474
            // splitChunks: {
            //     chunks: 'all',
            // },
            // Keep the runtime chunk seperated to enable long term caching
            // https://twitter.com/wSokra/status/969679223278505985
            // runtimeChunk: true,
        },

        plugins: [
            new HtmlWebpackPlugin({
                filename: 'index.html',
                //favicon: 'assets/favicon.ico',
                meta: [],
                inject: true,
                minify: isDev ? false : {
                    removeComments: true,
                    collapseWhitespace: true,
                    removeRedundantAttributes: true,
                    useShortDoctype: true,
                    removeEmptyAttributes: true,
                    removeStyleLinkTypeAttributes: true,
                    keepClosingSlash: true,
                    minifyJS: true,
                    minifyCSS: true,
                    minifyURLs: true,
                },
                title: 'Flatmate',
            })
        ],
    }
}


function figureOutBuildmode(env) {
    if (env == null) {
        throw new Error(
            `We detected that you didn't configure any build directives!
You need to specify whether to build Flatmate 
for production or for development via the 'buildfor'
environment directive like so:

    webpack --env.buildfor=production

This directive *is not an environment variable*.
It has to be either 'production' or 'development'.`
        );
    }
    if (env.buildfor !== 'production' && env.buildfor !== 'development') {
        throw new Error(
            `You need to specify whether to build Flatmate 
for production or for development via the 'buildfor'
environment directive like so:

    webpack --env.buildfor=production

This directive *is not an environment variable*.
It has to be either 'production' or 'development'.
It was set to '${env.buildfor}'.`
        );
    }

    return env.buildfor === 'development';
}