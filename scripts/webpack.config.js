const HtmlWebpackPlugin = require('html-webpack-plugin')
const path = require('path');

module.exports = env => {
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

    const isDev = env.buildfor === 'development';

    console.log(`Running webpack in ${isDev ? 'development' : 'production'} mode.`);

    return {
        mode: isDev ? 'development' : 'production',
        entry: './src/index.js',
        output: {
            path: path.resolve(__dirname, '..', 'dist'),
            filename: 'bundle.js'
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
                        [
                            { loader: 'elm-hot-webpack-loader' },
                            {
                                loader: 'elm-webpack-loader',
                                options: {}
                            },
                        ]
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
        plugins: [
            new HtmlWebpackPlugin({
                filename: 'index.html',
                //favicon: 'assets/favicon.ico',
                meta: [],
                minify: 'auto',
                title: 'Flatmate',
            })
        ],
    }
}
