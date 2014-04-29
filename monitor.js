/**
 * ArcadeBoy by Henry Tran (MIT) 2014
 *
 * monitor.js
 * ----------
 * Accesses system functions
 * and monitors window states.
 */

var FFI = require('ffi')
,   ref = require('ref')
,   StructType = require('ref-struct')
,   ArrayType = require('ref-array')
,   async = require('async')
;

// Just Ctrl-F your way to the Monitor definition.
// There really isn't anything interesting or human-readable
// until the Monitor class definition.


// Define constants and libraries to load.
var MAX_PATH = 0x00000104;
var TH32CS_SNAPPROCESS = 0x00000002;
var FORMAT_MESSAGE_ALLOCATE_BUFFER = 0x00000100;
var FORMAT_MESSAGE_ARGUMENT_ARRAY = 0x00002000;
var FORMAT_MESSAGE_FROM_HMODULE = 0x00000800;
var FORMAT_MESSAGE_FROM_STRING = 0x00000400;
var FORMAT_MESSAGE_FROM_SYSTEM = 0x00001000;
var FORMAT_MESSAGE_IGNORE_INSERTS = 0x00000200;
var LANG_NEUTRAL = 0x00
var SUBLANG_DEFAULT = 0x01
var SM_CXSCREEN = 0
var SM_CYSCREEN = 1
var SMTO_ABORTIFHUNG = 0x0002
var SMTO_BLOCK = 0x0001
var WM_GETTEXT = 0x000D

var DWORD = ref.types.uint32;
var LPDWORD = ref.refType(ref.types.uint32);
var HANDLE = ref.types.uint32;
var HWND = ref.types.uint32;
var LPARAM = ref.types.int32;
var WPARAM = ref.types.int32;
var LRESULT = ref.types.int32;
var TCHAR = ref.types.char;

var CharArray = ArrayType(ref.types.char);

var PROCESSENTRY32 = StructType({
    'dwSize': DWORD,
    'cntUsage': DWORD,
    'th32ProcessID': DWORD,
    'th32DefaultHeapID': ref.types.ulong,
    'th32ModuleID': DWORD,
    'cntThreads': DWORD,
    'th32ParentProcessID': DWORD,
    'pcPriClassBase': ref.types.long,
    'dwFlags': DWORD,
    'szExeFile': ArrayType(ref.types.char, MAX_PATH)
})

var PROCESSENTRY32Ptr = ref.refType(PROCESSENTRY32);

var RECT = StructType({
	'left': 'long',
	'top': 'long',
	'right': 'long',
	'bottom': 'long'
})

var RECTPtr = ref.refType(RECT);

function TEXT(text){
   return new Buffer(text, 'ucs2').toString('binary');
}

/**
 * User32.dll
 * @type {FFI}
 */
var user32 = new FFI.Library('user32', {
    'MessageBoxW': [
        'int32', [ 'int32', 'string', 'string', 'int32' ]
    ],
    'EnumWindows': [
    	'bool', ['pointer', LPARAM]
    ],
    'GetWindowThreadProcessId': [
    	DWORD, [HWND, LPDWORD]
    ],
    'SetForegroundWindow': [
    	'bool', [HWND]
    ],
    'SetActiveWindow': [
    	HWND, [HWND]
    ],
    'GetForegroundWindow': [
    	HWND, []
    ],
    'SetFocus': [
    	HWND, [HWND]
    ],
    'BringWindowToTop': [
    	'bool', [HWND]
    ],
    'AttachThreadInput': [
    	'bool', [DWORD, DWORD, 'bool']
    ],
    'IsWindow': [
    	'bool', [HWND]
    ],
    'IsWindowVisible': [
    	'bool', [HWND]
    ],
    'ShowWindow': [
    	'bool', [HWND, 'int32']
    ],
    'GetSystemMetrics': [
    	'int32', ['int32']
    ],
    'ChangeDisplaySettingsW': [
    	'long', ['int32', DWORD]
    ],
    'SendMessageTimeoutW': [
    	LRESULT, [HWND, 'uint', WPARAM, LPARAM, 'uint', 'uint', 'pointer']
    ],
    'GetWindowRect': [
    	'bool', [HWND, RECTPtr]
    ]
});


/**
 * Kernel32.dll
 * @type {FFI}
 */
var kernel32 = new FFI.Library('kernel32', {
    'CreateToolhelp32Snapshot': [
        HANDLE, [ 'uint32', 'uint32' ]
    ],
    'Process32First': [
        'bool', [ HANDLE, PROCESSENTRY32Ptr ]
    ],
    'Process32Next': [
        'bool', [ HANDLE, PROCESSENTRY32Ptr ]
    ],
    'CloseHandle': [
    	'bool', [HANDLE]
    ],
    'GetCurrentThreadId': [
    	DWORD, []
    ],
    'GetCurrentProcessId': [
    	DWORD, []
    ],
    'GetLastError': [
    	DWORD, []
    ],
    'FormatMessageW': [
    	DWORD, [DWORD, 'pointer', DWORD, DWORD, 'pointer', DWORD, 'pointer']
    ],
    'OpenProcess': [
    	HANDLE, [DWORD, 'bool', DWORD]
    ],
    'TerminateProcess': [
    	'bool', [HANDLE, 'uint32']
    ],
    'GetExitCodeProcess': [
    	'bool', [HANDLE, 'pointer']
    ]
});

var msvcrt = new FFI.Library('msvcrt', {
	'wcstombs': [
		'size_t', ['pointer', 'pointer', 'size_t']
	]
});

function MAKELANGID(p, s) { return (s << 10) | p }

/**
 * Get the dimensions of the main monitor.
 * @return {Object} width and height of the screen
 */
function getScreenSize() {
	var width = user32.GetSystemMetrics(SM_CXSCREEN);
	var height = user32.GetSystemMetrics(SM_CYSCREEN);
	return {width: width, height: height};
}

/**
 * Get the dimension of a window from it's handle
 * @param  {Handle} hWnd the handle
 * @return {Object} width and height of the screen.
 */
function getWindowSize(hWnd) {
	var rect = new RECT();
	user32.GetWindowRect(hWnd, rect.ref());

	return {width: rect.right - rect.left, height: rect.bottom - rect.top}
}

/**
 * Print the last system error
 */
function printLastError() {
    var dw = kernel32.GetLastError();

    var strptr = ref.alloc('pointer');
    kernel32.FormatMessageW(
        FORMAT_MESSAGE_ALLOCATE_BUFFER |
        FORMAT_MESSAGE_FROM_SYSTEM |
        FORMAT_MESSAGE_IGNORE_INSERTS,
        null,
        dw,
        0x01,
        strptr,
        0,
        null
    );

    var message = ref.reinterpretUntilZeros(new Buffer(strptr, 'utf8'), 1).toString();
    console.log(message);
}

/**
 * Check to see if the process is still running.
 * @param  {[type]}  handle [description]
 * @return {Boolean}        if the process is still running
 */
function isProcessRunning(handle) {
    var exitCode = ref.alloc(DWORD);
    if (!kernel32.GetExitCodeProcess(handle, exitCode))
        printLastError();

    return exitCode.deref() == 259;
}

/**
 * Monitor class
 * @param {String} exename Name of the executable to monitor.
 */
function Monitor(exename) {
	this.exename = exename;
	this.running = true;

	// maybe rename this to current process?
	this.processThreadId = kernel32.GetCurrentThreadId();
	this.processProcessId = kernel32.GetCurrentProcessId();

	this.foundProcess = false;
	this.processid = null;
	this.handle = null;

	this.foundhWnd = false;
	this.threadId = null;
	this.hWnd = null;

	this.once = false

    // Define the callbacks
	this.cbLoading = function() {}
	this.cbFound = function() {}
	this.cbClosed = function() {}

    // Make sure to keep this monitor running asynchroniously.
    // This will allow us to run other classes as coroutines.
	async.whilst(
		function() { return this.running; }.bind(this),
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
    this.running = false;
}

/**
 * Set the callbacks for this monitor
 * @param {Function} loadingCallback called when game is loading
 * @param {Function} foundCallback   called when the process is loaded
 * @param {Function} closedCallback  called when process is closed
 */
Monitor.prototype.setCallbacks = function(loadingCallback, foundCallback, closedCallback) {
    this.cbLoading = loadingCallback;
    this.cbFound = foundCallback;
    this.cbClosed = closedCallback;
}

/**
 * The brain of the monitor, this is called every second.
 */
Monitor.prototype.tick = function() {

    // Primitive state machine

	if (!this.foundProcess) {
	// step 1. we haven't found the process yet
    // dedicate each tick to finding the process.

        // call our callback
		this.cbLoading();

        // create a snapshot of all processes
	    var snapshot = kernel32.CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
	    var entry = new PROCESSENTRY32();

        // Loop through all the processes in our snapshot
	    var bool = kernel32.Process32First(snapshot, entry.ref());
	    do {
	        var szExeFile = ref.reinterpretUntilZeros(new Buffer(entry.szExeFile), 1).toString();

            // Do the file names match? notepad.exe == notepad.exe?
	        if (szExeFile.toLowerCase() === this.exename.toLowerCase()) {
	        	this.processid = entry.th32ProcessID;
	        	this.handle = kernel32.OpenProcess(0x0001 | 0x0800 | 0x1000, true, this.processid);
	        	this.foundProcess = true;
	        }
	        bool = kernel32.Process32Next(snapshot, entry.ref());
		} while (bool);

        // Clean up
	    kernel32.CloseHandle(snapshot);
	} else if (!this.foundhWnd && isProcessRunning(this.handle)) {
	// step 2. so we found the process,
    // now we need to find the window that goes with the process.

        // take a snapshot of ALL windows visible
		var hWnds = [];
		var enumCb = FFI.Callback('bool', [HWND, LPARAM], function(hWnd, lParam) {
			hWnds.push(hWnd);
			return true;
		}.bind(this));
		user32.EnumWindows(enumCb, 0);

        // iterate through the snapshot of all windows
		for (i in hWnds) {
			var hWnd = hWnds[i];

            // Make sure it's a window and we can see it
			if (user32.IsWindow(hWnd) && user32.IsWindowVisible(hWnd)) {

                // grab the process id of the window
				var processId = ref.alloc(DWORD);
				var threadId = user32.GetWindowThreadProcessId(hWnd, processId);
				processId = ref.deref(processId);

                // okay, we've found a window with a matching process!
				if (processId == this.processid && !this.foundhWnd) {
					var size = getWindowSize(hWnd);
					var screensize = getScreenSize();

                    // the size of the window is the same as the screen! jackpot!
                    // the window must be fullscreen!
					if (screensize.width == size.width && screensize.height == size.height) {
						this.foundhWnd = true;
						this.threadId = threadId;
						this.hWnd = hWnd;
						this.cbFound();
						return;
					}
				}
			}
		}
	} else if (user32.IsWindow(this.hWnd) && isProcessRunning(this.handle)) {
    // step 3. we've found the window, and it is up and running!

        // attach to the foreground window (this ensures that
        // we have permission to bring windows into focus)
		var fgProcessId = ref.alloc(DWORD);
		var fgThreadId = user32.GetWindowThreadProcessId(user32.GetForegroundWindow(), fgProcessId);
		user32.AttachThreadInput(this.processThreadId, fgThreadId, true);
		user32.AttachThreadInput(this.threadId, this.processThreadId, true);

		// check if our window is in focus
		// if it isn't, then bring it to focus
		if (user32.GetForegroundWindow() != this.hWnd) {
			user32.ShowWindow(this.hWnd, 0) // hide
			user32.ShowWindow(this.hWnd, 9) // show
            // ^^ (I know, it's hacky.)
			user32.SetActiveWindow(this.hWnd);
			user32.SetForegroundWindow(this.hWnd);
			user32.SetFocus(this.hWnd);

            // ping the window to check if it's responding
			var result = ref.alloc('pointer');
			var hung = user32.SendMessageTimeoutW(
				this.hWnd,
				WM_GETTEXT,
				0,
				0,
				SMTO_ABORTIFHUNG | SMTO_BLOCK,
				1000,
				result
				);

			// application is hung, we should exit.
			if (hung == 0) {
				console.log("hung");
				kernel32.TerminateProcess(this.handle, 1);
			}
		}

		// remove all attachments to the foreground window
        // (we don't need it until next tick)
		user32.AttachThreadInput(this.threadId, this.processThreadId, false);
		user32.AttachThreadInput(this.processThreadId, fgThreadId, false);

	} else if (!isProcessRunning(this.handle)) {
    // step 4. process is closed! kill everything!

		kernel32.CloseHandle(this.handle);

		// the window is no longer open
		// kill this monitor.
		this.kill();

		// reset screen resolution to default
		// in case the game doesn't do that
		user32.ChangeDisplaySettingsW(0, 0);

		this.cbClosed();
	}

}

module.exports = Monitor;
