$(function(){

    var direction = 0;
    var speed = 0;
    var keys = {};


    $(document).keydown(function(e) {
        keys[e.which] = true;

        for (var i in keys) {

            if(i == 37) {
                if(direction >= -1) {

                    direction -= 0.025;

                    $('#leftButton').addClass('buttonsKeypressActive');
                    updateDirection(direction);
                }
            }
            else if(i == 39) {
                if(direction <= 1) {

                    direction += 0.025;
                    
                    $('#rightButton').addClass('buttonsKeypressActive');
                    updateDirection(direction);
                }
            }

            if(i == 40) {
                if(speed >= -1) {

                    speed -= 0.025;

                    $('#backButton').addClass('buttonsKeypressActive');
                    updateSpeed(speed);
                }
            }
            else if(i == 38) {
                if(speed <= 1) {

                    speed += 0.025;
                    $('#forwardButton').addClass('buttonsKeypressActive');
                    updateSpeed(speed);
                }
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
            delete keys[e.which];

        });

    });

    function updateDirection(direction) {
        console.log(direction);
        $("#directionKeypress").html(Math.round(direction*1000)/1000);

        //Animating thumb to display the direction
        $("#thumbDirection").css({left:(((Math.round(direction*1000)/1000)+1)*($('#direction').width()/2))});
    }

    function updateSpeed(speed) {
        console.log(speed);
        
        $("#speedKeypress").html(Math.round(speed*1000)/1000);
        $("#thumbForward").css({top:(((Math.round(-speed*100)/100)+1)*($('#forward').height()/2))});
    }

    setInterval(function() {
                  
        if (speed >= 0.025) {
            speed -= 0.025;
            updateSpeed(speed);
        }
        else if (speed < 0) {
            speed += 0.025;
            updateSpeed(speed);
        }   
    }, 200);

});
