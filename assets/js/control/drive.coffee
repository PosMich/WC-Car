$(document).ready ->
  direction = 0
  motion_direction = 0
  speed = 0
  motion_speed = 0

  updateDirection = (direction) ->
    if direction <= (motion_direction - 0.1) or direction >= (motion_direction + 0.1)
      motion_direction = direction
      motion_direction = 0  if motion_direction <= 0.05 and motion_direction >= 0 or motion_direction >= -0.05 and motion_direction <= 0
      sendMotion()

    $("#thumbDirection").css left: (((Math.round(direction * 1000) / 1000) + 1) * ($("#direction").width() / 2))
  updateSpeed = (speed) ->
    if speed <= (motion_speed - 0.1) or speed >= (motion_speed + 0.1)
      motion_speed = speed
      motion_speed = 0  if motion_speed <= 0.05 and motion_speed >= 0 or motion_speed >= -0.05 and motion_speed <= 0
      sendMotion()

    $("#thumbForward").css top: (((Math.round(-speed * 1000) / 1000) + 1) * ($("#forward").height() / 2))

  sendMotion = ->
    if window.controlChannel isnt null
      console.log("l2r:"+direction, "b2f:"+speed);
      window.controlChannel.send JSON.stringify
        l2r: direction
        b2f: speed
    else
      console.log "controlChannel isn't initialized"

  kd.run ->
    kd.tick()

  kd.LEFT.down ->
    if direction >= -1
      direction = 0  if direction > 0
      direction -= 0.0125
      $("#leftButton").addClass "buttonsKeypressActive"
      updateDirection direction

  kd.LEFT.up ->
    $("#leftButton").removeClass "buttonsKeypressActive"

  kd.RIGHT.down ->
    if direction <= 1
      direction = 0  if direction < 0
      direction += 0.0125
      $("#rightButton").addClass "buttonsKeypressActive"
      updateDirection direction

  kd.RIGHT.up ->
    $("#rightButton").removeClass "buttonsKeypressActive"

  kd.DOWN.down ->
    if speed >= -1
      speed = 0  if speed > 0
      speed -= 0.0125
      $("#backButton").addClass "buttonsKeypressActive"
      updateSpeed speed

  kd.DOWN.up ->
    $("#backButton").removeClass "buttonsKeypressActive"

  kd.UP.down ->
    if speed <= 1
      speed = 0  if speed < 0
      speed += 0.0125
      $("#forwardButton").addClass "buttonsKeypressActive"
      updateSpeed speed

  kd.UP.up ->
    $("#forwardButton").removeClass "buttonsKeypressActive"

  kd.SPACE.press ->
    speed = 0
    direction = 0
    updateSpeed speed
    updateDirection direction



#Automatically reduces speed
#setInterval(function() {
#
#        if ((Math.round(speed*1000)/1000) >= 0.0125) {
#            speed -= 0.0125;
#            updateSpeed(speed);
#        }
#        else if ((Math.round(speed*1000)/1000) < 0) {
#            speed += 0.0125;
#            updateSpeed(speed);
#        }
#    }, 150);

  #Get Device Orientation values
  offset_bwd = 60
  offset_left = 60
  start_bwd = -40
  lagebestimmung = (event) ->
    beta = Math.round(event.beta)
    gamma = Math.round(event.gamma)
    alpha = Math.round(event.alpha)
    orientation = window.orientation
    if orientation is -90
      $("#notification").hide()
      $("#blackening").hide()

      gamma = gamma + start_bwd
      direction = Math.round(((2 / offset_left) * beta) * -100) / 100
      speed = Math.round(((2 / offset_bwd)*gamma)*-100)/100

      if direction > 1
        direction = 1
      if direction < -1
        direction = -1

      if speed > 1
        speed = 1
      if speed < -1
        speed = -1

      $("#gGamma").html speed
      $("#gBeta").html direction
      $("#orient").html orientation

      updateSpeed speed
      updateDirection direction

    #$("#wGamma").html(((Math.round(((1/90)*gamma)*100)/100)*($('#forward').height()/2)));
    else if orientation is 90
      $("#notification").hide()
      $("#blackening").hide()

      direction = Math.round(((2 / offset_left) * beta) * 100) / 100

      direction = 1 if direction > 1
      direction = -1 if direction < -1

      # normalize start orientation (bwd 2 fwd)
      gamma = gamma - start_bwd
      speed = Math.round(((2 / offset_bwd) * gamma) * 100) / 100
      speed = 1 if speed > 1
      speed = -1 if speed < -1

      #Getting values and animating thumb to display speed
      #Query because of degree behavior at this orientation

      $("#gGamma").html speed
      $("#gBeta").html direction
      $("#orient").html orientation

      updateSpeed speed
      updateDirection direction

    #Portrait Mode
    else if orientation is 0 or orientation is 180
      $("#orient").html orientation
      $("#notification").show()
      $("#blackening").show()

    if speed > 0
      $("#forwardButton").addClass "buttonsKeypressActive"
      $("#backButton").removeClass "buttonsKeypressActive"
    else if speed < 0
      $("#backButton").addClass "buttonsKeypressActive"
      $("#forwardButton").removeClass "buttonsKeypressActive"

    if direction > 0
      $("#leftButton").removeClass "buttonsKeypressActive"
      $("#rightButton").addClass "buttonsKeypressActive"
    else if direction < 0
      $("#rightButton").removeClass "buttonsKeypressActive"
      $("#leftButton").addClass "buttonsKeypressActive"

  alpha = undefined
  beta = undefined
  gamma = undefined
  window.addEventListener "deviceorientation", lagebestimmung, false