
// using the require() function will break in browsers
// this file will exit with an error if it runs in the browser
var fs = require("fs"),
    path = require("path"),
    stripJSON = require("strip-json-comments");

$("#games").html(""); // clear the games for backend

// Try to find the config.json file!
var CONFIG_PATH = path.join(process.execPath, "config.json");
var CONFIG_PATH_DEV = path.join(process.cwd(), "config.json");

// The working directory should be the directory
// the config.json file is in.
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

insertGame({});
insertGame({});
insertGame({});
insertGame({
    "screenshot": "http://globalgamejam.org/sites/default/files/styles/game_content__normal/public/games/screenshots/screenshot_2014-01-26_16.27.03.png?itok=h6D-8YiZ"
});

insertGame(
    {
        "name": "Test Game",
        "authors": ["Test Person", "Test Person2", "John Smith", "Jane Doe"],
        "description": "This is a test description blah blah hi there!",
        "screenshot": "http://placehold.it/640x480"
    }
);

