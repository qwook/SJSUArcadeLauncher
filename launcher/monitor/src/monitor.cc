#include <node.h>
#include <v8.h>

#include <iostream>
#include <vector>
#include <string>
#include <utility>
#include <algorithm>

#include <windows.h>
#include <tlhelp32.h>

using namespace v8;

std::string exeName = "";
bool running = false;

DWORD currentThreadId;
DWORD currentProcessId;

bool foundProcess = false;
DWORD processId = NULL;
HANDLE processHandle = NULL;

bool foundhWnd = false;
DWORD processThreadId = NULL;
HWND hWnd = NULL;

std::vector<HWND> hWnds;

v8::Persistent<v8::Function> cbLoading;
v8::Persistent<v8::Function> cbFound;
v8::Persistent<v8::Function> cbClosed;

struct Size {
	long width;
	long height;
};

void Method(const FunctionCallbackInfo<Value>& args) {
	args.GetReturnValue().Set(42);
}

bool IsProcessRunning(HANDLE handle) {
	DWORD exitCode;
	if (!GetExitCodeProcess(handle, &exitCode)) {
		// todo: print error;
	}
	return exitCode == 259;
}

/**
 * Get the dimensions of the main monitor.
 * @return {Object} width and height of the screen
 */
Size GetScreenSize() {
	Size size;
	size.width = GetSystemMetrics(SM_CXSCREEN);
	size.height = GetSystemMetrics(SM_CYSCREEN);
	return size;
}

/**
 * Get the dimension of a window from it's handle
 * @param  {Handle} hWnd the handle
 * @return {Object} width and height of the screen.
 */
Size GetWindowSize(HWND hWnd) {
	Size size;

	RECT rect;
	GetWindowRect(hWnd, &rect);
	size.width = rect.right - rect.left;
	size.height = rect.bottom - rect.top;

	return size;
}

void CallLoadingCallback() {
	v8::Handle<v8::Value> *args = NULL;
	v8::Local<v8::Function> value = v8::Local<v8::Function>::New(v8::Isolate::GetCurrent(), cbLoading);
	value->Call(value, 0, args);
	// auto cb = cbLoading.As<v8::Function>();
	// cb->Call();
	// ((v8::Function )cbLoading).As<v8::Function>()->Call(v8::Isolate::GetCurrent(), v8::Null(v8::Isolate::GetCurrent()), 0, args);
	// MessageBox (NULL, "loading_cb", " c_cb", MB_OK);
}

void CallFoundCallback() {
	// v8::Handle<v8::Value> args = v8::Array::New(v8::Isolate::GetCurrent(), 0);
	// v8::Function::Cast(&cbFound);
	// cbFound.As<v8::Function>()->Call(v8::Isolate::GetCurrent(), v8::Null(v8::Isolate::GetCurrent()), 0, &args);

	v8::Handle<v8::Value> *args = NULL;
	v8::Local<v8::Function> value = v8::Local<v8::Function>::New(v8::Isolate::GetCurrent(), cbFound);
	value->Call(value, 0, args);
	// MessageBox (NULL, "found_cb", " found_cb", MB_OK);
}

void CallClosedCallback() {
	v8::Handle<v8::Value> *args = NULL;
	v8::Local<v8::Function> value = v8::Local<v8::Function>::New(v8::Isolate::GetCurrent(), cbClosed);
	value->Call(value, 0, args);
	// v8::Handle<v8::Value> args = v8::Array::New(v8::Isolate::GetCurrent(), 0);
	// cbClosed.As<v8::Function>()->Call(v8::Isolate::GetCurrent(), v8::Null(v8::Isolate::GetCurrent()), 0, &args);
	// MessageBox (NULL, "c_cb", " c_cb", MB_OK);
}

void Start(const FunctionCallbackInfo<Value>& args) {
	// std::cout << "Start" << std::endl;
	currentThreadId = GetCurrentThreadId();
	currentProcessId = GetCurrentProcessId();

	::exeName = *v8::String::Utf8Value(args[0]);
	::running = true;

	::foundProcess = false;
	::processId = NULL;
	::processHandle = NULL;

	::foundhWnd = false;
	::processThreadId = NULL;
	::hWnd = NULL;

	// MessageBox (NULL, "start", exeName.c_str(), MB_OK);
	std::cout << "Bleh" << std::endl;
}

void Tick(const FunctionCallbackInfo<Value>& args) {
	if (!::foundProcess) {
	// step 1. we haven't found the process yet
    // dedicate each tick to finding the process.

		// callback
		CallLoadingCallback();

	    // create a snapshot of all processes
		HANDLE snapshot = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
		PROCESSENTRY32 entry;

	    // Loop through all the processes in our snapshot
		bool looping = Process32First(snapshot, &entry);
		do {
			std::string szExeFile = entry.szExeFile;
			std::transform(szExeFile.begin(), szExeFile.end(), szExeFile.begin(), toupper);
			std::transform(exeName.begin(), exeName.end(), exeName.begin(), toupper);

			if (szExeFile.compare(exeName) == 0) {
				::processId = entry.th32ProcessID;
				::processHandle = OpenProcess(0x0001 | 0x0800 | 0x1000, true, ::processId);
				::foundProcess = true;
			}
			looping = Process32Next(snapshot, &entry);
		} while (looping);

	    // Clean up
	    CloseHandle(snapshot);
	} else if (!::foundhWnd && IsProcessRunning(::processHandle)) {
	// step 2. so we found the process,
    // now we need to find the window that goes with the process.

		hWnds.clear();
		EnumWindows([](HWND hWnd, LPARAM lParam)->BOOL{
			hWnds.push_back(hWnd);
			return true;
		}, 0);

		for (HWND hWnd : hWnds) {

			if (IsWindow(hWnd) && IsWindowVisible(hWnd)) {
				DWORD processId;
				DWORD threadId = GetWindowThreadProcessId(hWnd, &processId);

					// char test[200];
					// sprintf(test, "%d == %d", processId, ::processId);
					// MessageBox (NULL, test, test, MB_OK);

				if (processId == ::processId && !::foundhWnd) {
					Size size = GetWindowSize(hWnd);
					Size screenSize = GetScreenSize();

					// char test[200];
					// sprintf(test, "%d == %d, %d == %d", size.width, screenSize.width, size.height, screenSize.height);
					// MessageBox (NULL, test, test, MB_OK);

					if (size.width == screenSize.width && size.height == screenSize.height) {
						::foundhWnd = true;
						::processThreadId = threadId;
						::hWnd = hWnd;
						CallFoundCallback();
						return;
					}
				}
			}

		}

	} else if (IsWindow(::hWnd) && IsProcessRunning(::processHandle)) {
    // step 3. we've found the window, and it is up and running!

        // attach to the foreground window (this ensures that
        // we have permission to bring windows into focus)
		DWORD fgProcessId;
		DWORD fgThreadId = GetWindowThreadProcessId(GetForegroundWindow(), &fgProcessId);
		AttachThreadInput(::currentThreadId, fgThreadId, true);
		AttachThreadInput(::processThreadId, ::currentThreadId, true);

		// check if our window is in focus
		// if it isn't, then bring it to focus
		if (GetForegroundWindow() != ::hWnd) {
            // ping the window to check if it's responding
			DWORD_PTR result;
			LRESULT hung = SendMessageTimeoutW(
				::hWnd,
				WM_GETTEXT,
				0,
				0,
				SMTO_ABORTIFHUNG | SMTO_BLOCK,
				1000,
				&result
				);

			// application is hung, we should exit.
			if (hung == 0) {
				TerminateProcess(::processHandle, 1);
			}
			
			// ShowWindow(::hWnd, 0); // hide
			ShowWindow(::hWnd, 9); // show
			SetFocus(::hWnd);
            // ^^ (I know, it's hacky.)
			SetForegroundWindow(::hWnd);
			SetActiveWindow(::hWnd);
		}

		// remove all attachments to the foreground window
        // (we don't need it until next tick)
		AttachThreadInput(::processThreadId, ::currentThreadId, false);
		AttachThreadInput(::currentThreadId, fgThreadId, false);

	} else if (!IsProcessRunning(::processHandle)) {
    // step 4. process is closed! kill everything!

		CloseHandle(::processHandle);

		// the window is no longer open
		// kill this monitor.
		::running = false;

		// reset screen resolution to default
		// in case the game doesn't do that
		ChangeDisplaySettingsW(0, 0);

		CallClosedCallback();
	}
}

void Kill(const FunctionCallbackInfo<Value>& args) {
	// MessageBox (NULL, "Kill", " kills", MB_OK);
	::running = false;
}

void SetCallbacks(const FunctionCallbackInfo<Value>& args) {
	HandleScope scope(args.GetIsolate());
	Handle<Function> cbLoadingHandle = Handle<Function>::Cast(args[0]);
	cbLoading.Reset(args.GetIsolate(), cbLoadingHandle);

	Handle<Function> cbFoundHandle = Handle<Function>::Cast(args[1]);
	cbFound.Reset(args.GetIsolate(), cbFoundHandle);

	Handle<Function> cbClosedHandle = Handle<Function>::Cast(args[2]);
	cbClosed.Reset(args.GetIsolate(), cbClosedHandle);

	// MessageBox (NULL, "set callbacks", "set callbacks", MB_OK);
}

void IsRunning(const FunctionCallbackInfo<Value>& args) {
	args.GetReturnValue().Set(v8::Boolean::New(args.GetIsolate(), running));
}

void init(Handle<Object> exports) {
	// MessageBox (NULL, "heyy", " heeey", MB_OK);
	Isolate* isolate = Isolate::GetCurrent();
	exports->Set(String::NewFromUtf8(isolate, "Start"),
		FunctionTemplate::New(isolate, Start)->GetFunction());
	exports->Set(String::NewFromUtf8(isolate, "Tick"),
		FunctionTemplate::New(isolate, Tick)->GetFunction());
	exports->Set(String::NewFromUtf8(isolate, "Kill"),
		FunctionTemplate::New(isolate, Kill)->GetFunction());
	exports->Set(String::NewFromUtf8(isolate, "SetCallbacks"),
		FunctionTemplate::New(isolate, SetCallbacks)->GetFunction());
	exports->Set(String::NewFromUtf8(isolate, "IsRunning"),
		FunctionTemplate::New(isolate, IsRunning)->GetFunction());
}

NODE_MODULE(monitor, init)