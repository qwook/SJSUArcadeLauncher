/**
 * ArcadeBoy by Henry Tran (MIT) 2014
 *
 * backend.js
 * ----------
 * Logic for the arcade backend.
 * This involves reading config files,
 * running system commands,
 * executing processes,
 * and deploying launchers.
 */

// Check if we're on windows
var has_windows = /^win/.test(process.platform);

// using the require() function will break in browsers
// this file will exit with an error if it runs in the browser
var fs = require("fs")
,   path = require("path")
,   stripJSON = require("strip-json-comments")
,   gui = require('nw.gui')
,   cp = require('child_process')


// var Monitor;
if (has_windows) {
    // Monitor = require('./monitor.js')
}

var win = gui.Window.get();

$("#games").html(""); // clear the games for backend

// Try to find the config.json file!
var CONFIG_PATH = path.join(path.dirname(process.execPath), "launcherConfig.json");
var CONFIG_PATH_DEV = path.join(process.cwd(), "launcherConfig.json");

// The working directory should be the directory
// the config.json file is in.
var WORKING_DIRECTORY;

var configStr;
if (fs.existsSync(CONFIG_PATH)) {
    configStr = fs.readFileSync(CONFIG_PATH, {encoding: "utf8"});
    WORKING_DIRECTORY = path.dirname(process.execPath);
} else if (fs.existsSync(CONFIG_PATH_DEV)) {
    configStr = fs.readFileSync(CONFIG_PATH_DEV, {encoding: "utf8"});
    WORKING_DIRECTORY = process.cwd();
} else {
    throw "Cannot find config file!";
}

var config = JSON.parse(stripJSON(configStr));
var preset = -1;

function loadAllGames() {
    // load games in config file
    for (id in config.gameList)
    {
        var game = config.gameList[id];

        var gameInfoStr = fs.readFileSync(path.join(WORKING_DIRECTORY, game.folderPath, "gameInfo.json"), {encoding: "utf8"});
        var gameInfo = JSON.parse(stripJSON(gameInfoStr));

        insertGame({
            "name": gameInfo.gameName,
            "authors": [gameInfo.gameAuthors],
            "description": gameInfo.gameDescription,
            "screenshot": "file:///" + path.join(WORKING_DIRECTORY, game.folderPath, gameInfo.screenshotName).replace(/\\/gm, "/"),
            "data": { "path": game.folderPath, "exe": gameInfo.executablePath }
        });
    }
}

function loadPresetGame(id) {
    var allowed = config.presetList[id].gameList;

    // load games in config file
    for (id in config.gameList)
    {
        var game = config.gameList[id];

        // filter by allowed
        if (allowed.indexOf(game.gameId) == -1) { continue; }

        var gameInfoStr = fs.readFileSync(path.join(WORKING_DIRECTORY, game.folderPath, "gameInfo.json"), {encoding: "utf8"});
        var gameInfo = JSON.parse(stripJSON(gameInfoStr));

        insertGame({
            "name": gameInfo.gameName,
            "authors": [gameInfo.gameAuthors],
            "description": gameInfo.gameDescription,
            "screenshot": "file:///" + path.join(WORKING_DIRECTORY, game.folderPath, gameInfo.screenshotName).replace(/\\/gm, "/"),
            "data": { "path": game.folderPath, "exe": gameInfo.executablePath }
        });
    }
}

setPresetCallback(function() {
    preset = (preset + 1) % (config.presetList.length + 1);
    clearGames();

    if (preset == config.presetList.length) {
        setCategory();
        loadAllGames();
    } else {
        setCategory(config.presetList[preset].presetName);
        loadPresetGame(preset);
    }
})

if (has_windows) {
    setLaunchGameCallback(function(data) {
        cp.exec(path.join(WORKING_DIRECTORY, data.path, data.exe));
        setTimeout(function() {
            console.log(data.exe);
            // var monitor = new Monitor(data.exe);
            // monitor.setCallbacks(
            //     // on game loading (every tick)
            //     function() {
            //     },
            //     // on game loaded
            //     function() {
            //         win.minimize();
            //     },
            //     // on game closed
            //     function () {
            //         reset();
            //         win.focus();
            //     }
            // )
        }, 1000);
    })
}

loadAllGames();
