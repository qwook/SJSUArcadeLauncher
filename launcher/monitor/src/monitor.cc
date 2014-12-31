#include <node.h>
#include <v8.h>

#include <iostream>
#include <string>
#include <utility>
#include <algorithm>

#include <windows.h>
#include <tlhelp32.h>

using namespace v8;

bool foundProcess = false;
std::string exeName = "";

void Method(const FunctionCallbackInfo<Value>& info) {
	info.GetReturnValue().Set(42);
}

void Tick(const FunctionCallbackInfo<Value>& info) {
	HANDLE snapshot = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
	PROCESSENTRY32 entry;

	bool looping = Process32First(snapshot, &entry);
	do {
		std::string szExeFile = entry.szExeFile;
		std::transform(szExeFile.begin(), szExeFile.end(), szExeFile.begin(), toupper);
		std::transform(exeName.begin(), exeName.end(), exeName.begin(), toupper);

		if (szExeFile.compare(exeName) == 0) {

		}
		looping = Process32Next(snapshot, &entry);
	} while (looping);
	
}

void init(Handle<Object> exports) {
	Isolate* isolate = Isolate::GetCurrent();
	exports->Set(String::NewFromUtf8(isolate, "hello"),
		FunctionTemplate::New(isolate, Method)->GetFunction());
}

NODE_MODULE(monitor, init)