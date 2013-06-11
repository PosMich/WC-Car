$(document).ready(function() {
  
  PORT_SERVER = "8080";
  PORT_SOCKET = "8081";
  OFFSET_LEFT = 60;
  OFFSET_BWD = 60;
  START_BWD = -40;

  direction = 0;
  motion_direction = 0;
  speed = 0;
  motion_speed = 0;
  keys = {};
  first_img = false;

  connected = false;
  connection = null;

  timeout = 0;
  max_timeout = 5;

  IP = /[0-9]+.[0-9]+.[0-9]+.[0-9]+/i.exec(document.URL);

  $(".connect").click( function( e ) {
    e.preventDefault();
    $("#dialog").animate({opacity: 0}, 750);
    $("#speedWrapper").animate({opacity: 1}, 750);
    $("#directionWrapper").animate({opacity: 1}, 750);

    $img = $("#imgStream");
    height = $(".imgContainer").height();
    width =  $(".imgContainer").width();

    connection = new WebSocket( "ws://" + IP + ":" + PORT_SOCKET );

    connection.onopen = function() {
      console.log( "connection opened." );
      connection.send( JSON.stringify ( {"type": 0, "token": $("#token").val()} ) );
      connected = true;
    }

    connection.onmessage = function(e) {

      timeout = 0;

      message = JSON.parse( e.data );

      if( message.type == "signal_strength" ) {
        if( message.value <= 9 )
          $("#signal").html( "You're going to loose the Wifi-Signal. Please drive back!" );
        else
          $("#Signal").html( "" );
      } else if( message.type == "image_data" ) {          
        $("#imgStream").attr( "src", "data:image/jpg;base64," + message.value )
        if( !first_img ) {
          first_img = true;
          $(window).resize();
        }
      }

    }

    $(document).keydown(function(e) {
      keys[e.which] = true;

      for (var i in keys) {
        if(i == 37) {
          if(direction >= -1) {
            if(direction > 0)
              direction = 0
            direction -= 0.025;
            updateDirection(direction);
          }
        } else if(i == 39) {
          if(direction <= 1) {
            if(direction < 0)
              direction = 0
            direction += 0.025;
            updateDirection(direction);
          }
        }

        if(i == 40) {
          if(speed >= -1) {
            if(speed > 0) {
              speed = 0;
            }
            speed -= 0.025;
            updateSpeed(speed);
          }
        } else if(i == 38) {
          if(speed <= 1) {
            if(speed < 0) {
              speed = 0;
            }
            speed += 0.025;
            updateSpeed(speed);
          }
        }
      }
    });

    $(document).keyup(function(e) {
      delete keys[e.which];
    });

    lagebestimmung = function( event ) {
      alpha = Math.round(event.alpha);
      beta = Math.round(event.beta);
      gamma = Math.round(event.gamma);

      if( window.orientation == -90 ) {
        $( "#hint" ).html( "" );
        if( connected ) {
          l2r = Math.round( ( ( 2 / OFFSET_LEFT ) * beta ) * -100) / 100;

          if ( l2r > 1 )
            l2r = 1;
          else if ( l2r < -1 )
            l2r = -1;

          // normalize start orientation (bwd 2 fwd)
          gamma = gamma + START_BWD;
          b2f = Math.round( ( ( 2 / OFFSET_BWD ) * gamma ) * -100) / 100;

          if ( b2f > 1 )
            b2f = 1;
          else if ( b2f < -1 )
            b2f = -1;

          updateDirection( l2r );
          updateSpeed( b2f );
        }
      } else if( window.orientation == 90 )
      $( "#hint" ).html( "" );
        if( connected ) {
          l2r = Math.round( ( ( 2 / OFFSET_LEFT ) * beta ) * 100) / 100;
          if( l2r > 1 )
            l2r = 1;
          else if( l2r < -1 )
            l2r = -1;

          // normalize start orientation (bwd 2 fwd)
          gamma = gamma - START_BWD;
          
          b2f = Math.round( ( ( 2 / OFFSET_BWD ) * gamma ) * 100) / 100;

          if( b2f > 1 )
            b2f = 1;
          else if( b2f < -1 )
            b2f = -1;

          updateDirection( l2r );
          updateSpeed( b2f );
        } else if( window.orientation == 0 || window.orientation == 180 )
          $( "#hint" ).html( "turn your phone in langscape mode" );
    }

    alpha = undefined;
    beta = undefined;
    gamma = undefined;

    window.addEventListener( "deviceorientation", lagebestimmung, false);

    window.connection = connection;
  });

  // send post request to shut the connection down immediatly

  $(".kill").click = function() {
    console.log( IP + ":" + PORT_SERVER );
    post_to_url( "http://" + IP + ":" + PORT_SERVER, {'passphrase': $("#passphrase").val()}, 'post' );
  }

  post_to_url = function( path, params, method ) {
    method = method || "post"; // Set method to post by default if not specified..
    
    form = document.createElement("form");
    form.setAttribute("method", method);
    form.setAttribute("action", path);

    for (key in params) {
      if (params.hasOwnProperty(key)) {
        hiddenField = document.createElement("input");
        hiddenField.setAttribute("type", "hidden");
        hiddenField.setAttribute("name", key);
        hiddenField.setAttribute("value", params[key]);
        form.appendChild(hiddenField);
      }
    }

    document.body.appendChild(form);

    form.submit();
  }

  updateDirection = function( direction ) {
    $("#thumbDirection").css({left:(((Math.round(direction*1000)/1000)+1)*($('#direction').width()/2))});
    if( direction <= (motion_direction - 0.1) || direction >= (motion_direction + 0.1) ) {
      motion_direction = direction;

      if( motion_direction <= 0.05 && motion_direction >= 0 ||
          motion_direction >= -0.05 && motion_direction <= 0 )
        motion_direction = 0;

    // $("#Direction").html( direction );
      sendMotion();
    }
  }

  updateSpeed = function( speed ) {
    $("#thumbForward").css({top:(((Math.round(-speed*1000)/1000)+1)*($('#forward').height()/2))});
      if( speed <= (motion_speed - 0.1) || speed >= (motion_speed + 0.1) ) {
          motion_speed = speed;
    
          if( motion_speed <= 0.05 && motion_speed >= 0 ||
              motion_speed >= -0.05 && motion_speed <= 0 )
            motion_speed = 0;
    
            //$("#Speed").html( speed )
            sendMotion();
        }
    }
    
    sendMotion = function() {
      connection.send( JSON.stringify ( {"type": 1, "l2r": motion_direction.toFixed(2), "b2f": motion_speed.toFixed(2)} ) );
    }
    
    
  $(window).resize(function() {
    height = $(".imgContainer").height();
    width = $(".imgContainer").width();
    $("#imgStream").css({
      width: width,
      height: height
    });
  });
  
  setInterval(function() {
    if (connected) {
      if (speed > 0.025) {
        speed -= 0.025;
        updateSpeed(speed);
      } else if (speed <= 0) {
        speed += 0.025;
        updateSpeed(speed);
      }
    }
  }, 200);

  // Timeout
  setInterval(function() {
    if (connected) {
      timeout++;
      if( timeout > max_timeout ) {
        $("#dialog").html("<h1>Something went wrong...<br> Please check the app-status and reload this page.</h1>");
        $("#dialog").animate({opacity: 1}, 750);
        connected = false;
      }
    }
  }, 1000);
});