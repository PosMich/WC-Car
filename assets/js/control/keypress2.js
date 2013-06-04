$(function(){

    var direction = 0;
    var speed = 0;

    kd.run(function () {
        kd.tick();
    });


    kd.LEFT.down(function () {
        if(direction >= -1) {

            direction -= 0.0125;

            $('#leftButton').addClass('buttonsKeypressActive');
            updateDirection(direction);
        }
    });
    kd.LEFT.up(function () {
        $('#leftButton').removeClass('buttonsKeypressActive');
    });

    kd.RIGHT.down(function () {
        if(direction <= 1) {

            direction += 0.0125;
            
            $('#rightButton').addClass('buttonsKeypressActive');
            updateDirection(direction);
        }
    });
    kd.RIGHT.up(function () {
        $('#rightButton').removeClass('buttonsKeypressActive');
    });

    kd.DOWN.down(function () {
        if(speed >= -1) {

            speed -= 0.0125;

            $('#backButton').addClass('buttonsKeypressActive');
            updateSpeed(speed);
        }
    });

    kd.DOWN.up(function () {
        $('#backButton').removeClass('buttonsKeypressActive');
    });

    kd.UP.down(function () {
        if(speed <= 1) {

            speed += 0.0125;
            $('#forwardButton').addClass('buttonsKeypressActive');
            updateSpeed(speed);
        }
    });
    kd.UP.up(function () {
        $('#forwardButton').removeClass('buttonsKeypressActive');
    });

    kd.SPACE.press(function() {
        speed = 0;
        direction = 0;
        updateSpeed(speed);
        updateDirection(direction);
    })
    

    function updateDirection(direction) {
        $("#directionKeypress").html(Math.round(direction*1000)/1000);

        //Animating thumb to display the direction
        $("#thumbDirection").css({left:(((Math.round(direction*1000)/1000)+1)*($('#direction').width()/2))});
    }

    function updateSpeed(speed) {
        $("#speedKeypress").html(Math.round(speed*1000)/1000);
        $("#thumbForward").css({top:(((Math.round(-speed*1000)/1000)+1)*($('#forward').height()/2))});
    }

    setInterval(function() {
                  
        if ((Math.round(speed*1000)/1000) >= 0.0125) {
            speed -= 0.0125;
            updateSpeed(speed);
        }
        else if ((Math.round(speed*1000)/1000) < 0) {
            speed += 0.0125;
            updateSpeed(speed);
        }   
    }, 150);

});