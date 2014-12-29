# SJSU GameDev Arcade Launcher
An arcade launcher, similiar to the Winnitron launcher, but open source and released under the MIT license.

## Dependencies
[nodejs v0.10.*](http://nodejs.org)  
[node-webkit v0.8.4](https://github.com/rogerwang/node-webkit)  
Python 2.7 (For dependency compiling)  

## Installation
Run `npm install` to install node dependencies.

For FFI to work, you need to download nw-gyp using `npm install -g nw-gyp`  
Then call `nw-gyp clean configure build --target=0.8.4` on the folders:  
`node_modules/ffi/` and `/node_modules/ffi/node_modules/ref/`  

*todo: make a file that automates this process*

## Binaries
*Coming soon*

## License

    The MIT License (MIT)

    Copyright (c) 2014 Henry Tran

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
    THE SOFTWARE.