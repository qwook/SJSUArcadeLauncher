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

try {

// Check if we're on windows
var has_windows = /^win/.test(process.platform);

// using the require() function will break in browsers
// this file will exit with an error if it runs in the browser
var fs = require('fs')
,   path = require('path')
,   stripJSON = require('strip-json-comments')
,   gui = require('nw.gui')
,   cp = require('child_process')

// var monitor = require('./monitor.js')
// console.log( monitor.hello() );

var Monitor;
if (has_windows) {
    Monitor = require('./src/monitor.js')
}

var win = gui.Window.get();

$("#games").html(""); // clear the games for backend

// Try to find the config.json file!
// var CONFIG_PATH = path.join(path.dirname(process.execPath), "launcherConfig.json");
var CONFIG_PATH = path.join(path.dirname(process.execPath), "../launcherConfig.json");
// var CONFIG_PATH_DEV = path.join(process.cwd(), "launcherConfig.json");

console.log(CONFIG_PATH);

// The working directory should be the directory
// the config.json file is in.
var WORKING_DIRECTORY;

var configStr;
if (fs.existsSync(CONFIG_PATH)) {
    configStr = fs.readFileSync(CONFIG_PATH, {encoding: "utf8"});
    WORKING_DIRECTORY = path.join(path.dirname(process.execPath), "..");
// } else if (fs.existsSync(CONFIG_PATH_DEV)) {
//     configStr = fs.readFileSync(CONFIG_PATH_DEV, {encoding: "utf8"});
//     WORKING_DIRECTORY = process.cwd();
} else {
    console.error("Cannot find config file!");
}

var config = JSON.parse(stripJSON(configStr));
var preset = -1;

function loadAllGames() {
    // load games in config file
    for (id in config.gameList)
    {
        var gameInfo = config.gameList[id];

        // var gameInfoStr = fs.readFileSync(path.join(WORKING_DIRECTORY, game.folderPath, "gameInfo.json"), {encoding: "utf8"});
        // var gameInfo = JSON.parse(stripJSON(gameInfoStr));

        insertGame({
            "name": gameInfo.gameName,
            "authors": [gameInfo.gameAuthors],
            "description": gameInfo.gameDescription,
            // "screenshot": "file:///" + path.join(WORKING_DIRECTORY, game.folderPath, gameInfo.screenshotName).replace(/\\/gm, "/"),
            // "data": { "path": game.folderPath, "exe": gameInfo.executablePath }
            "screenshot": "file:///" + path.join(WORKING_DIRECTORY, gameInfo.screenshotName).replace(/\\/gm, "/"),
            "data": { "path": "/", "exe": gameInfo.executablePath }
        });
    }
}

function loadPresetGame(id) {
    var allowed = config.presetList[id].gameList;

    // load games in config file
    for (id in config.gameList)
    {
        var gameInfo = config.gameList[id];

        // filter by allowed
        if (allowed.indexOf(gameInfo.gameId) == -1) { continue; }

        // var gameInfoStr = fs.readFileSync(path.join(WORKING_DIRECTORY, game.folderPath, "gameInfo.json"), {encoding: "utf8"});
        // var gameInfo = JSON.parse(stripJSON(gameInfoStr));

        insertGame({
            "name": gameInfo.gameName,
            "authors": [gameInfo.gameAuthors],
            "description": gameInfo.gameDescription,
            // "screenshot": "file:///" + path.join(WORKING_DIRECTORY, gameInfo.folderPath, gameInfo.screenshotName).replace(/\\/gm, "/"),
            // "data": { "path": gameInfo.folderPath, "exe": gameInfo.executablePath }
            "screenshot": "file:///" + path.join(WORKING_DIRECTORY, gameInfo.screenshotName).replace(/\\/gm, "/"),
            "data": { "path": "/", "exe": gameInfo.executablePath }
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

// if (has_windows) {
    setLaunchGameCallback(function(data) {
        console.log(path.join(WORKING_DIRECTORY, data.path, data.exe));
        cp.exec(path.join(WORKING_DIRECTORY, data.path, data.exe));
        setTimeout(function() {
            var found = false;
            var monitor = new Monitor(path.basename(data.exe));
            monitor.setCallbacks(
                // on game loading (every tick)
                function() {
                    console.log("sup loading");
                },
                // on game loaded
                function() {
                    console.log("found");
                    found = true;
                    win.setAlwaysOnTop(false);
                    // win.blur();
                    // win.leaveKioskMode();
                    win.minimize();
                },
                // on game closed
                function () {
                    console.log("closed");
                    reset();
                    win.focus();
                    win.setAlwaysOnTop(true);
                    // win.enterKioskMode();
                    found = false;
                }
            )
            monitor.start();
        }, 1000);
    })
// }

loadAllGames();

} catch(err) {

    console.error(err);

}