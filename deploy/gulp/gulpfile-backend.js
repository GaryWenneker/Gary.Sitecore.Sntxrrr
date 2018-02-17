var gulp = require("gulp");
var msbuild = require("gulp-msbuild");
var debug = require("gulp-debug");
var foreach = require("gulp-foreach");
var rename = require("gulp-rename");
var watch = require("gulp-watch");
var merge = require("merge-stream");
var newer = require("gulp-newer");
var util = require("gulp-util");
var runSequence = require("run-sequence");
var path = require("path");
var config = require("./gulp-config.js")();
var nugetRestore = require('gulp-nuget-restore');
var fs = require('fs');
var unicorn = require("./unicorn.js");
var macaw = require("./macaw.js");
var yargs = require("yargs").argv;

module.exports = function () {
    gulp.task("BE-Sync-Unicorn", function (callback) {
        var options = {};
        options.siteHostName = macaw.getSiteUrl();
        options.authenticationConfigFile = config.websiteRoot + "/App_config/Include/Unicorn/Unicorn.zSharedSecret.config";

        unicorn(function () { return callback() }, options);
    });
}