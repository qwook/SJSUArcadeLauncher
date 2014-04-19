// Arcade Frontend

// hide other 'gameshows'
function hideOthers() {
    $('.gameshow.left').addClass("hidden")
    .last().removeClass("hidden")

    $('.gameshow.right').addClass("hidden")
    .first().removeClass("hidden")
}

// slide gameshows to the left
function moveLeft() {
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

var launchGameCb;
function launchGame() {
    launchGameCb ? launchGameCb() : null;
    $("#games").addClass("loading")
}

function reset() {
    $("#games").removeClass("loading")
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

    console.log((data.authors || []).join(", "))

    $("#games").append(gameshow);

    hideOthers();
}

function setLaunchGameCallback(cb) {
    launchGameCb = cb
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
            launchGame();
            break;
        case 32:
            reset();
            break;
        default:
            console.log(e.keyCode)
            break;
    }
});