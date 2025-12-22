const path = require('path');
const { WebpackManifestPlugin } = require('webpack-manifest-plugin');
const { CleanWebpackPlugin } = require('clean-webpack-plugin');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');

module.exports = {
    mode: 'production',

    entry: {
        'css/test-custom-plugin': './source/sass/test-custom-plugin.scss',
        'js/test-custom-plugin': './source/js/test-custom-plugin.js',
    },
    
    output: {
        filename: '[name].[contenthash].js',
        path: path.resolve(__dirname, 'dist'),
        publicPath: '',
    },

    module: {
        rules: [
            // SCSS/CSS loader
            {
                test: /\.(sa|sc|c)ss$/,
                use: [
                    MiniCssExtractPlugin.loader,
                    {
                        loader: 'css-loader',
                        options: {
                            importLoaders: 1,
                        },
                    },
                    {
                        loader: 'sass-loader',
                        options: {}
                    },
                ],
            },
        ],
    },

    plugins: [
        // Clean dist folder
        new CleanWebpackPlugin(),

        // Output CSS files
        new MiniCssExtractPlugin({
            filename: '[name].[contenthash].css'
        }),

        // Output manifest.json for cache busting
        new WebpackManifestPlugin({
            filter: function (file) {
                // Don't include source maps
                if (file.path.match(/\.(map)$/)) {
                    return false;
                }
                return true;
            },
        }),
    ],

    devtool: 'source-map',
};

