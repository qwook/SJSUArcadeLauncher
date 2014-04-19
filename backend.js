// using the require() function will break in browsers
// this file will exit with an error if it runs in the browser
var fs = require("fs"),
    path = require("path"),
    stripJSON = require("strip-json-comments");

$("#games").html(""); // clear the games for backend

var CONFIG_PATH = path.join(process.execPath, "config.json");
var CONFIG_PATH_DEV = path.join(process.cwd(), "config.json");
var WORKING_DIRECTORY;

var configStr;
if (fs.existsSync(CONFIG_PATH)) {
    configStr = fs.readFileSync(CONFIG_PATH, {encoding: "utf8"});
    WORKING_DIRECTORY = process.execPath;
} else if (fs.existsSync(CONFIG_PATH_DEV)) {
    configStr = fs.readFileSync(CONFIG_PATH_DEV, {encoding: "utf8"});
    WORKING_DIRECTORY = process.cwd();
} else {
    throw "Cannot find config file!";
}

var config = JSON.parse(stripJSON(configStr));
