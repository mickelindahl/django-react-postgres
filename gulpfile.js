"use strict";

const browserSync = require('browser-sync').create()
const concat = require('gulp-concat')
const {dest, parallel, series, src, watch} = require('gulp')
const notify = require('gulp-notify')
const sass = require('gulp-sass')(require('sass'));
const webpack = require('webpack-stream');
const webpackConfig = require('./webpack')

function fonts() {
    return src([
        'node_modules/@fortawesome/fontawesome-free/webfonts/**/*',
        'frontend-react/resources/fonts/**/*'
    ]).pipe(dest('build/fonts'))
}

function images() {
    return src([
        'frontend-react/resources/images/**/*'
    ]).pipe(dest('build/images'))
}

function favicon() {

    console.log('favicon')

    return src([
        'frontend-react/resources/favicon/*'
    ]).pipe(dest('build/'))
}

function transpileStyles() {

    console.log('Transpiling base styles')

    return src([
        'node_modules/bootstrap/scss/bootstrap.scss',
        'node_modules/@fortawesome/fontawesome-free/css/all.css',
        'frontend-react/resources/styles/app.scss'
    ])
        .pipe(sass({outputStyle: 'compressed'}))
        .on('error', notify.onError(function (e) {
            return 'Failed to compile base SCSS' + e.message;
        }))
        .pipe(concat('style.css'))
        .pipe(dest('build/css/'))
        .pipe(browserSync.stream())
}

function bundleJs() {

    console.log('Bundle js files');

    return src([
        'node_modules/bootstrap/dist/js/bootstrap.js',
        // 'resources/js/**/*.js',
    ])
        .on('error', notify.onError(function (e) {
            console.log(e);
            return 'Failed to minifying JS' + e.message;
        }))
        .pipe(concat('script.js'))
        .pipe(dest('build/js/'))
        .pipe(browserSync.stream())
}

function reactBundle(cb) {
    src('frontend-react/app.tsx')
        .pipe(
            webpack(webpackConfig)
        )
        .pipe(dest('build/js/'))
        .pipe(browserSync.stream())

    cb()
}

function openBrowserIfNotActive(cb) {
    if (browserSync.active) {
        console.log('openBrowserIfNotActive active')
        browserSync.exit();
    } else {

        console.log('openBrowserIfNotActive open')
        browserSync.init({
            proxy: 'localhost:8000',
            port: '2998'
        });
    }
    cb()
}

function liveUpdate(cb) {
    console.log('Watch')
    // watch('frontend-react/resources/fonts/**/*', fonts)
    // watch('frontend-react/resources/images/**/*', images)
    watch('frontend-react/resources/styles/**/*.scss', transpileStyles)
    // watch('frontend-react/resources/js/**/*.js', bundleJs)
    watch('**/templates/**/*.html').on('change', browserSync.reload);
     watch('/build/js/app.js').on('add', p=>{

         console.log('app.js add')
         browserSync.reload(p)
     });
     watch('/build/js/app.js').on('change',  p=>{

         console.log('app.js change')
         browserSync.reload(p)
     });
    cb()
}

// gulp.task('fonts', gulp.series())
// gulp.task('images', gulp.series())
// gulp.task('favicon', gulp.series());
// gulp.task('style-base', gulp.series());
// gulp.task('js', gulp.series());
// gulp.task('browserSync', gulp.series());
// gulp.task('scss', gulp.series('style-base'));
// gulp.task('build', gulp.series('scss', 'js', 'fonts', 'images', 'favicon', 'webfonts'));
// gulp.task('watch', gulp.series('browserSync',));
// gulp.task('default', gulp.series('build', 'watch'));

function clean(cb) {
    console.log('Clean!!!')
    cb();
}

exports.default = series(
    // clean,
    parallel(
        // fonts, images,
        images,
        favicon,
        transpileStyles,
        reactBundle
        //bundleJs,
    ),
    liveUpdate,
    openBrowserIfNotActive,
)
// function (cb) {
//
//     liveUpdate()
//     cb()
// }