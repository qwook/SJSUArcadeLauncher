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
var CONFIG_PATH = path.join(path.dirname(process.execPath), "..", "games-for-launcher", "launcherConfig.json");
// var CONFIG_PATH_DEV = path.join(process.cwd(), "launcherConfig.json");

console.log(CONFIG_PATH);

// The working directory should be the directory
// the config.json file is in.
var WORKING_DIRECTORY;

var configStr;
if (fs.existsSync(CONFIG_PATH)) {
    configStr = fs.readFileSync(CONFIG_PATH, {encoding: "utf8"});
    WORKING_DIRECTORY = path.join(path.dirname(process.execPath), "..");
} else {
    console.error("Cannot find config file!");
}

var config = JSON.parse(stripJSON(configStr));
var preset = -1;

var STATISTICS_FILE = path.join(WORKING_DIRECTORY, "statistics.json");
// create statistics file if it doesn't exist
if (!fs.existsSync(STATISTICS_FILE)) {
    fs.writeFileSync(STATISTICS_FILE, 'statistics={}');
}

function getGameStatistics() {
    return JSON.parse(fs.readFileSync(STATISTICS_FILE, {encoding: "utf8"}).substring(11));
}

function saveGameStatistics(statistics) {
    fs.writeFileSync(STATISTICS_FILE, "statistics="+JSON.stringify(statistics));
}

var SAVE_FILE = path.join(WORKING_DIRECTORY, "savefile.json");
// create save file if it doesn't exist
if (!fs.existsSync(SAVE_FILE)) {
    fs.writeFileSync(SAVE_FILE, 'savefile={}');
}

function getSaveFile() {
    return JSON.parse(fs.readFileSync(SAVE_FILE, {encoding: "utf8"}).substring(9));
}

function saveSaveFile(statistics) {
    fs.writeFileSync(SAVE_FILE, "statistics="+JSON.stringify(statistics));
}

function addPlayTime(game, time) {
    var statistics = getGameStatistics();
    statistics[game] = statistics[game] || {
        playTime: 0,
        playCount: 0
    };

    statistics[game].playTime += time;

    saveGameStatistics(statistics);
}

function addPlayCount(game) {
    var statistics = getGameStatistics();
    statistics[game] = statistics[game] || {
        playTime: 0,
        playCount: 0
    };

    statistics[game].playCount++;

    saveGameStatistics(statistics);
}

function loadAllGames() {
    // load games in config file
    for (id in config.gameList)
    {
        var gameInfo = config.gameList[id];

        insertGame({
            "name": gameInfo.gameName,
            "authors": [gameInfo.gameAuthors],
            "description": gameInfo.gameDescription,
            "screenshot": "file:///" + path.join(WORKING_DIRECTORY, "games-for-launcher", gameInfo.screenshotName).replace(/\\/gm, "/"),
            "data": { "id": gameInfo.gameId, "path": "/", "exe": gameInfo.executablePath, "autohotkey": gameInfo.ahkHacks }
        });
    }
}

function loadPresetGame(id) {
	if (!config.presetList) {
		loadAllGames();
	}

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
            "screenshot": "file:///" + path.join(WORKING_DIRECTORY, "games-for-launcher", gameInfo.screenshotName).replace(/\\/gm, "/"),
            "data": { "path": "/", "exe": gameInfo.executablePath, "autohotkey": gameInfo.ahkHacks }
        });
    }
}

function playBackgroundMusicBackend() {
	if (!config.backgroundMusic) return;
	playBackgroundMusic("file:///" + path.join(WORKING_DIRECTORY, "games-for-launcher", config.backgroundMusic).replace(/\\/gm, "/"));
}

setPresetCallback(function() {
	if (!config.presetList) return;

    preset = (preset + 1) % (config.presetList.length + 1);
    clearGames();

    if (!config.presetList[preset]) {
        setCategory();
        loadAllGames();
    } else {
        setCategory(config.presetList[preset].presetName);
        loadPresetGame(preset);
    }

    var saveFile = getSaveFile();
    saveFile.presetId = preset;
    saveSaveFile(saveFile);
})

// if (has_windows) {
    setLaunchGameCallback(function(data) {
        var found = false;
        var monitor = new Monitor(path.basename(data.exe));

        var gameTimeStart = (new Date()).getTime() / 60000;

        addPlayCount(data.id);

        win.setAlwaysOnTop(false);

        console.log(path.join(WORKING_DIRECTORY, "games-for-launcher", data.path, data.exe));

        var ahk;
        if (data.autohotkey != undefined && data.autohotkey.length > 0) {
            ahk = cp.exec("\"" + path.join(WORKING_DIRECTORY, "games-for-launcher", data.path, data.autohotkey) + "\""
            , function (error, stdout, stderr){
                console.log('stdout: ' + stdout);
                console.log('stderr: ' + stderr);
                if (error !== null) {
                  console.log('exec error: ' + error);
                }
            });
            console.log("\"" + path.join(WORKING_DIRECTORY, "games-for-launcher", data.path, data.autohotkey) + "\"");
        }

        try {
	        var childProcess = cp.exec("\"" + path.join(WORKING_DIRECTORY, "games-for-launcher", data.path, data.exe) + "\"", function() {

		        // spawned the child process

				stopBackgroundMusic();

		        found = true;
		        win.setAlwaysOnTop(false);
		        // win.minimize();
		        // clearTimeout(timeOut);
				
		        gameTimeStart = (new Date()).getTime() / 60000

	        });

	        childProcess.on('exit', function() {
	            reset();
				playBackgroundMusicBackend();
	            win.setAlwaysOnTop(true);
	            win.focus();
	            // clearTimeout(timeOut);
	            found = false;

	            var currentTime = (new Date()).getTime() / 60000;
	            var gamePlayTime = Math.floor((currentTime - gameTimeStart)*100)/100;

	            // save to the statistics the game time.
	            addPlayTime(data.id, gamePlayTime);

	            if (ahk != undefined) {
	                cp.spawn('Taskkill', ['/F', '/IM', path.basename(data.autohotkey)]);
	                console.log(['/F', '/IM', path.basename(data.autohotkey)]);
	            }
	        });
	    } catch (e) {
            reset();
			playBackgroundMusicBackend();
            win.setAlwaysOnTop(true);
            win.focus();
	    }

        // setTimeout(function() {

            // I'm giving this thing 10 seconds to load...
     //        var timeOut = setTimeout(function() {
     //            if (found == false) {
     //                monitor.kill();

     //                reset();
					// playBackgroundMusicBackend();
     //                win.focus();
     //                win.setAlwaysOnTop(true);
     //                found = false;

     //                if (ahk != undefined) {
     //                    cp.spawn('Taskkill', ['/F', '/IM', path.basename(data.autohotkey)]);
     //                    console.log(['/F', '/IM', path.basename(data.autohotkey)]);
     //                }
     //            }
     //        }, 10000);

     //        monitor.setCallbacks(

     //            // on game loading (every tick)
     //            function() {
     //                // console.log("sup loading");
     //            },
     //            // on game loaded
     //            function() {
					// stopBackgroundMusic();

     //                found = true;
     //                win.setAlwaysOnTop(false);
     //                // win.minimize();
     //                // clearTimeout(timeOut);
					
     //                gameTimeStart = (new Date()).getTime() / 60000
     //            },
     //            // on game closed
     //            function () {
     //                reset();
					// playBackgroundMusicBackend();
     //                win.setAlwaysOnTop(true);
     //                win.focus();
     //                // clearTimeout(timeOut);
     //                found = false;

     //                var currentTime = (new Date()).getTime() / 60000;
     //                var gamePlayTime = Math.floor((currentTime - gameTimeStart)*100)/100;

     //                // save to the statistics the game time.
     //                addPlayTime(data.id, gamePlayTime);

     //                if (ahk != undefined) {
     //                    cp.spawn('Taskkill', ['/F', '/IM', path.basename(data.autohotkey)]);
     //                    console.log(['/F', '/IM', path.basename(data.autohotkey)]);
     //                }
     //            }
     //        )
     //        monitor.start();
        // }, 1000);
    })
// }

var saveFile = getSaveFile();
if (saveFile.presetId) {
	loadPresetGame(saveFile.presetId);
} else {
	loadAllGames();
}
playBackgroundMusicBackend();

} catch(err) {

	console.log(err.stack);
    console.error(err);

}