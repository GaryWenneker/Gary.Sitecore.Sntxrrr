/// <binding />
var gulp = require('gulp');
var runSequence = require("run-sequence")

var config = require("./deploy/gulp/gulp-config.js")();
require("./deploy/gulp/gulpfile-backend.js")();


//run this for complete local deployment
gulp.task("_LocalDeploy", function (callback) {
    config.runCleanBuilds = true;
    return runSequence(
        "BE-Sync-Unicorn",
        callback);
});