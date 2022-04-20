// const webpack = require('webpack');
const assert = require("assert");
const mode = (process.env.NODE_ENV || 'development').trim().toLowerCase();
const path = require('path');

assert(['production', 'development'].includes(mode), 'Error environment variable NODE_ENV needs to be set to ' +
    'either production for development')

module.exports = {
    output: {
        filename: 'app.js'
    },
    // context: path.resolve(__dirname, 'frontend-react'),
    mode,
    watch: mode == 'development',
    devtool: mode == 'development' ? 'eval-source-map' : 'source-map',
    watchOptions: {
        aggregateTimeout: 300,
    },
    module: {
        rules: [
            {
                test: [ /\.tsx?$/,  /\.ts$/],
                use: 'ts-loader',
                exclude: /node_modules/,
            },
            // {
            //     test: /\.jsx$/,
            //     exclude: /node_modules/,
            //     use: {
            //         loader: "babel-loader"
            //     }
            // },
            {
                test: /\.s[ac]ss$/i,
                exclude: /node_modules/,
                use: [
                    // Creates `style` nodes from JS strings
                    'style-loader',
                    // Translates CSS into CommonJS (also css modules)
                    'css-loader',
                    // Compiles Sass to CSS
                    'sass-loader',
                ],
            }
        ]
    },
    // plugins: [
    //     // Work around for Buffer is undefined:
    //     // https://github.com/webpack/changelog-v5/issues/10
    //     new webpack.ProvidePlugin({
    //         Buffer: ['buffer', 'Buffer'],
    //     })
    // ],
    resolve: {
        extensions: ['.tsx', '.ts', '.js'],
        // fallback: {
        //     "stream": require.resolve("stream-browserify"),
        //     "buffer": require.resolve("buffer")
        // }
    },
    // output: {
    //     filename: 'app.js',
    //     path: path.resolve(__dirname, 'build'),
    // },
};