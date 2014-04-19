// a - 65, d - 68, w - 87, s - 83
// up - 38, down - 40, left - 37, right - 39

function moveLeft() {
    var left = $('.gameshow.left')
    left = left[left.length-1]
    // if there is any games on the left
    if (left) {
        // move the original featured game over
        $('.gameshow.featured')
            .removeClass("featured")
            .addClass("right")

        $(left)
            .removeClass("left")
            .addClass("featured")
    }
}

function moveRight() {
    var right = $('.gameshow.right')
    right = right[right.length-1]
    // if there is any games on the left
    if (right) {
        // move the original featured game over
        $('.gameshow.featured')
            .removeClass("featured")
            .addClass("left")

        $(right)
            .removeClass("right")
            .addClass("featured")
    }
}

$(window).keydown(function(e) {
    switch (e.keyCode) {
        case 65:
        case 37:
        moveRight();
        break;
        case 68:
        case 39:
        moveLeft();
        break;
    }
});