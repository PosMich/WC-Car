$(document).ready ->

  direction = 0
  speed = 0
  motion_direction = 0
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
      window.controlChannel.send JSON.stringify
        l2r: direction
        b2f: speed

  #Get Device Orientation values
  offset_bwd = 35
  offset_left = 60
  start_bwd = -40
  lagebestimmung = (event) ->
    beta = Math.round(event.beta)
    gamma = Math.round(event.gamma)
    alpha = Math.round(event.alpha)
    orientation = window.orientation
    if orientation is 0
      $("#notification").hide()
      $("#blackening").hide()

      beta = beta + start_bwd

      direction = Math.round(((2 / offset_left) * gamma) * 100) / 100
      speed = Math.round(((2 / offset_bwd) * beta) * -100) / 100

      if direction > 1
        direction = 1
      if direction < -1
        direction = -1

      if speed > 1
        speed = 1
      if speed < -1
        speed = -1

      $("#gGamma").html direction
      $("#gBeta").html speed
      $("#orient").html orientation

      updateSpeed speed
      updateDirection direction

    #$("#wGamma").html(((Math.round(((1/90)*gamma)*100)/100)*($('#forward').height()/2)));
    else if orientation is 180
      $("#notification").hide()
      $("#blackening").hide()

      beta = beta - start_bwd

      direction = Math.round(((2 / (-1 * offset_left)) * gamma) * 100) / 100
      speed = Math.round(((2 / offset_bwd) * beta) * 100) / 100

      direction = 1 if direction > 1
      direction = -1 if direction < -1

      speed = 1 if speed > 1
      speed = -1 if speed < -1

      #Getting values and animating thumb to display speed
      #Query because of degree behavior at this orientation

      $("#gGamma").html direction
      $("#gBeta").html speed
      $("#orient").html orientation

      updateSpeed speed
      updateDirection direction

    #Portrait Mode
    else if orientation is 90 or orientation is -90
      $("#orient").html orientation
      $("#notification").show()
      $("#blackening").show()
    ###
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
    ###
  alpha = undefined
  beta = undefined
  gamma = undefined
  window.addEventListener "deviceorientation", lagebestimmung, false