/**
 * ArcadeBoy by Henry Tran (MIT) 2014
 *
 * frontend.js
 * -----------
 * Logic for the arcade display.
 * This involves animations and input.
 */

var launching = false;

// slide gameshows to the left
function moveLeft() {
    if (launching) { return; }

    var left = $('.gameshow.left').last()
    // if there is any games on the left
    if (left[0]) {
        // move the original featured game over
        $('.gameshow.featured')
            .removeClass("featured")
            .addClass("right")

        left
            .removeClass("left")
            .addClass("featured")
    }

    hideOthers();
}

// slide gameshows to right
function moveRight() {
    if (launching) { return; }

    var right = $('.gameshow.right').first()
    // if there is any games on the left
    if (right[0]) {
        // move the original featured game over
        $('.gameshow.featured')
            .removeClass("featured")
            .addClass("left")

        right
            .removeClass("right")
            .addClass("featured")
    }

    hideOthers();
}

function setCategory(name) {
    if (!name || name.length == 0) {
        $("#category")
            .addClass("hidden");
    } else {
        $("#category")
            .text(name)
            .removeClass("hidden");
    }
}

// hide other 'gameshows'
function hideOthers() {
    $('.gameshow.left').addClass("hidden")
    .last().removeClass("hidden")

    $('.gameshow.right').addClass("hidden")
    .first().removeClass("hidden")
}

var launchGameCb;
function launchGame() {
    if (launching) { return; }

    launchGameCb ? launchGameCb($(".gameshow.featured").data()) : null;
    $("#games").addClass("loading")
    launching = true;
}

var presetCb;
function presetChange() {
    presetCb();
}

function reset() {
    $("#games").removeClass("loading")
    launching = false;
}

function insertGame(data) {
    // todo: switch to templating system and use handlebar
    // but it's way too simple to have that...
    var gameshow = $(
        '<div class="gameshow">'
            + '<div class="screenshot">'
            + '<div class="caption">'
                + '<div class="caption-left">'
                    + '<h1></h1>'
                    + '<p class="authors"></p>'
                + '</div>'
                + '<div class="caption-right">'
                    + '<p class="description"></p>'
                + '</div>'
            + '</div>'
        + '</div>'
        )

    if ($(".gameshow").length > 0)
        gameshow.addClass("right");
    else
        gameshow.addClass("featured");

    $(".screenshot", gameshow).css({
        "background-image": "url(" + data.screenshot + ")"
    });

    $(".description", gameshow).text(data.description || "");

    $("h1", gameshow).text(data.name || "!! No name added !!");

    $(".authors", gameshow).text((data.authors || []).join(", "));

    $("#games").append(gameshow);

    gameshow.data(data.data);

    hideOthers();
}

function clearGames() {
    $("#games").html("");
}

function setLaunchGameCallback(cb) {
    launchGameCb = cb
}

function setPresetCallback(cb) {
    presetCb = cb;
}

$(window).keydown(function(e) {
    switch (e.keyCode) {
        case 65:
        case 37:
            moveLeft();
            break;
        case 68:
        case 39:
            moveRight();
            break;
        case 13:
        case 49:
        case 50:
        case 70:
        case 71:
        case 72:
        case 67:
        case 86:
        case 66:
        case 75:
        case 76:
        case 59:
        case 188:
        case 190:
        case 191:
            launchGame();
            break;
        case 32:
            reset();
            break;
        case 90:
            presetChange();
            break;
        default:
            console.log(e)
            console.log(e.keyCode)
            break;
    }
});