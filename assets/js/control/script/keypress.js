$(function(){

    var direction = 0;
    var speed = 0;

    $(document).keypress(function(e) {
        if(e.keyCode == 37) {
            if(direction >= -1) {
                direction -= 0.025;
                $("#directionKeypress").html(direction);

                //Animating thumb to display the direction
                $("#thumbDirection").css({left:(((Math.round(direction*100)/100)+1)*($('#direction').width()/2))});
                $('#leftButton').addClass('buttonsKeypressActive');
            }
        }
        else if(e.keyCode == 39) {
            if(direction <= 1) {
                direction += 0.025;
                $("#directionKeypress").html(direction);
                $("#thumbDirection").css({left:(((Math.round(direction*100)/100)+1)*($('#direction').width()/2))});
                $('#rightButton').addClass('buttonsKeypressActive');
            }
        }

        if(e.keyCode == 40) {
            if(speed >= -1) {
                speed -= 0.025;
                $("#speedKeypress").html(speed);
                $("#thumbForward").css({top:(((Math.round(-speed*100)/100)+1)*($('#forward').height()/2))});
                $('#backButton').addClass('buttonsKeypressActive');
            }
        }
        else if(e.keyCode == 38) {
            if(speed <= 1) {
                speed += 0.025;
                $("#speedKeypress").html(speed);
                $("#thumbForward").css({top:(((Math.round(-speed*100)/100)+1)*($('#forward').height()/2))});
                $('#forwardButton').addClass('buttonsKeypressActive');
            }
        }

        $(document).keyup(function(e) {
            switch (e.keyCode) {
                case 37:
                    $('#leftButton').removeClass('buttonsKeypressActive');
                    break;
                case 39:
                    $('#rightButton').removeClass('buttonsKeypressActive');
                    break;
                case 40:
                    $('#backButton').removeClass('buttonsKeypressActive');
                    break;
                case 38:
                    $('#forwardButton').removeClass('buttonsKeypressActive');
                    break;
            }
        });

    });



});
