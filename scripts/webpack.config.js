const HtmlWebpackPlugin = require('html-webpack-plugin')
const path = require('path');

const isDev = process.env.NODE_ENV === 'production';

module.exports = {
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
                use: {
                    loader: 'elm-webpack-loader',
                    options: {}
                }
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
};
