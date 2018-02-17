"use strict";
var xml2js = require("xml2js");
var fs = require("fs");

var macaw = {};

macaw.getConfiguration = function getConfigFile(filename) {
  var data = fs.readFileSync(filename);

  var parser = new xml2js.Parser();
  var content;
  parser.parseString(data, function (err, result) {
    if (err !== null) throw err;

    content = result;
  });
  return content;
};

macaw.getSiteUrl = function getSiteUrl(options) {
  if (!options) options = {};

  var publishFile = options.publishingSettingsFile ? options.publishingSettingsFile : "./publishsettings.targets";
  try {
      var configuration = macaw.getConfiguration(publishFile);
    return configuration.Project.PropertyGroup[0].publishUrl[0];
  } catch(error) {
    error.message = "Could not get the site URL from '" + publishFile + "'. Error:" + error.message;
    throw(error);
  }
};

module.exports = macaw;