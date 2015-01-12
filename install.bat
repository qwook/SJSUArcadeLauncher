cd launcher
npm install .
bower install .
cd monitor
nw-gyp configure --target=0.11.5
nw-gyp build
pause