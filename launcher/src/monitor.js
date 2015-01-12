/**
 * ArcadeBoy by Henry Tran (MIT) 2014
 *
 * monitor.js
 * ----------
 * Accesses system functions
 * and monitors window states.
 */

// var FFI = require('ffi')
// ,   ref = require('ref')
// ,   StructType = require('ref-struct')
// ,   ArrayType = require('ref-array')
var async = require('async');

var monitor = require('../monitor/build/Release/monitor');

// Just Ctrl-F your way to the Monitor definition.
// There really isn't anything interesting or human-readable
// until the Monitor class definition.

function MAKELANGID(p, s) { return (s << 10) | p }

/**
 * Monitor class
 * @param {String} exename Name of the executable to monitor.
 */
function Monitor(exename) {
    monitor.Start(exename);

    monitor.SetCallbacks(
        function() {},
        function() {},
        function() {}
    );
}

Monitor.prototype.start = function() {
    console.log("Tried to start");
    
    // Make sure to keep this monitor running asynchroniously.
    // This will allow us to run other classes as coroutines.
    async.whilst(
        function() { return monitor.IsRunning(); }.bind(this),
        function(cb) {
            this.tick();

            setTimeout(cb, 0);
        }.bind(this),
        function(err) {
            if (err) {
                throw err;
            }
        }
    );
}

/**
 * Kill this monitor
 */
Monitor.prototype.kill = function() {
    monitor.Kill();
}

/**
 * Set the callbacks for this monitor
 * @param {Function} loadingCallback called when game is loading
 * @param {Function} foundCallback   called when the process is loaded
 * @param {Function} closedCallback  called when process is closed
 */
Monitor.prototype.setCallbacks = function(loadingCallback, foundCallback, closedCallback) {
    console.log("SetCallbacked");
    monitor.SetCallbacks(
        loadingCallback,
        foundCallback,
        closedCallback
    );
}

/**
 * The brain of the monitor, this is called every second.
 */
Monitor.prototype.tick = function() {
    monitor.Tick();
}

module.exports = Monitor;
