import gulp from 'gulp';
import eslint from 'gulp-eslint';
import uglify from 'gulp-uglify';
import clean from 'gulp-clean';
import autoprefixer from 'gulp-autoprefixer';
import sass from 'gulp-sass';
import notify from 'gulp-notify';
import babelify from 'babelify';
import exorcist from 'exorcist';
import browserify from 'browserify';
import browserSync, { reload } from 'browser-sync';
import runSequence from 'run-sequence';
import watchify from 'watchify';
import source from 'vinyl-source-stream';
import buffer from 'vinyl-buffer';

const config = {
  proxy: 'localhost:8080',
  js: {
    entry: 'src/js/scripts.js',
    all: 'src/js/**/*.js',
    src: 'src/js/',
    map: 'public/src/js/scripts.js.map',
    output: 'public/src/js', 
  },
  css: {
    entry: 'src/scss/style.scss',
    all: 'src/scss/**/*.scss',
    output: 'public/src/css',
  },
}

/*
 * esLint
 * task: lint
 */
gulp.task('lint', () => {
  gulp.src([config.js.all])
    .pipe(eslint())
    .pipe(eslint.format())
    .pipe(eslint.failAfterError());
});

/*
 * Browserify
 * task: browserify
 */
gulp.task('browserify', () => {
  browserify(config.js.entry, {extensions: ['.js', '.json', '.jsx'], debug: true})
    .on('error', notify.onError())
    .transform(babelify)
    .bundle()
    .pipe(exorcist(config.js.map))
    .pipe(source('scripts.min.js'))
    .pipe(buffer())
    .pipe(uglify())
    .pipe(gulp.dest(config.js.output));
});

/*
 * Watchify
 * task: watchify
 */
const customOptions = {
  entries: config.js.entry,
  extensions: ['.js', '.json', '.jsx'],
  debug: true
};
const options = Object.assign({}, watchify.args, customOptions);
gulp.task('watchify', () => {
  let bundler = watchify(browserify(options));
  function rebundle() {
    return bundler.bundle()
      .on('error', notify.onError())
      .pipe(exorcist(config.js.map))
      .pipe(source('scripts.js'))
      .pipe(buffer())
      .pipe(gulp.dest(config.js.output))
      .pipe(reload({stream: true}));
  }
  bundler.transform(babelify)
    .on('update', rebundle);
  return rebundle();
});

/*
 * Browser-sync
 * browserSync
 */
gulp.task('browserSync', () => {
    const bs = browserSync.create();
    bs.init({
        port: 8000,
        proxy: config.proxy,
    });
});

/*
 * SASS
 * task: sass
 */
gulp.task('sass', () => {
  gulp.src([config.css.all])
    .on('error', notify.onError())
    .pipe(sass())
    .pipe(gulp.dest(config.css.output))
    .pipe(reload({stream: true}));
});

/*
 * Autoprefixer
 * task: autoprefixer
 */
gulp.task('autoprefixer', () => {
  gulp.src(`${config.css.output}/style.css`)
    .on('error', notify.onError())
    .pipe(autoprefixer({
        browsers: ['last 2 versions'],
        cascade: false
    }))
    .pipe(gulp.dest(config.css.output));
});

/*
 * Clean
 * task: clean
 */
gulp.task('clean', () => {
  return gulp.src([config.js.output, config.css.output], { read: false })
    .pipe(clean({ force:true }));
});

/*
 * Build
 * task: build
 */
gulp.task('build', cb => {
  process.env.NODE_ENV = 'production';
  runSequence('clean', ['sass', 'autoprefixer', 'browserify'], cb);
});

/*
 * Watch Task
 * task: watchTask
 * task: watch
 */
gulp.task('watchTask', () => {
    gulp.watch(config.css.all, ['sass']);
    gulp.watch(config.js.all, ['lint']);
});
gulp.task('watch', cb => {
    runSequence('clean', ['browserSync', 'watchTask', 'watchify', 'sass', 'lint'], cb);
});

/*
 * Default
 * default task: css, browserify
 */
gulp.task('default', [ 'sass', 'browserify' ]);
