# SJSU GameDev Arcade Launcher
An arcade launcher, similiar to the Winnitron launcher, but open source and released under the MIT license.

# launcherConfig.json
In order for the launcher to work, it must have a configuration file named launcherConfig.json

```
{
    // This is for when you want an arcade machine to display
    // a subset of the games available.
    "presetList" :
    [
        {
            // Give the preset a name
            "presetName": "Action",
            // And a list of ID's
            "gameList": ["TurtlesInTime", "Contra""]
        }
    ],
    
    "gameList" :
    [
        {
            // A clean, short, and unique ID with no spaces.
            "gameId": "TurtlesInTime",
            // The full name to be displayed on the machine.
            "gameName": "Teenage Mutant Ninja Turtles: Turtles In Time",
            // Short description of the game to be displayed.
            "gameDescription: "Teenage Mutant Ninja Turtles: Turtles in Time, released as Teenage Mutant Hero Turtles: Turtles in Time in Europe, is an arcade video game produced by Konami",
            // List of authors of the game to be displayed.
            "gameAuthor": "Konami", "Mutsuhiko Izumi", "Kozo Nakamura",
            // Path to the game relative to this file.
            "executablePath" : "_gameData/tmnt/game/tmnt.exe",
            // Path to a screenshot relative to this file.
            "screenshotName" : "_launcherData/kiss_screenshot.png"
        }
    ]
}
```

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