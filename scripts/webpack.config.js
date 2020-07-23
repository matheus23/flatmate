const HtmlWebpackPlugin = require('html-webpack-plugin')
const path = require('path');

module.exports = {
    entry: './src/index.js',
    output: {
        path: path.resolve(__dirname, '..', 'dist'),
        filename: 'bundle.js'
    },
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
