$(function(){

    var windowWidth = $(window).width();
    var windowHeight = $(window).height();
    console.log(windowHeight);

    console.log("touchscreen is", VirtualJoystick.touchScreenAvailable() ? "available" : "not available");
    
    var joystick = new VirtualJoystick({
            container: document.getElementById('container'),
            mouseSupport: true
        });

        setInterval(function(){
            if (((joystick.deltaX()/(windowWidth/3)) < 1 && (joystick.deltaX()/(windowWidth/3)) > -1) && ((joystick.deltaY()/(windowHeight/3)) < 1 && (joystick.deltaY()/(windowHeight/3)) > -1)){
                var outputEl = document.getElementById('result');
                outputEl.innerHTML  = '<h1>Joystick Values:</h1> '
                + ' left/right:'+ (Math.round(joystick.deltaX()/(windowWidth/3)*100)/100) + '<br/>'
                + ' up/down:'+ (Math.round(joystick.deltaY()/(windowHeight/(-3))*100)/100) + '<br/>'  
            }

}, 1/30 * 1000);
    

});