$ ->
  updateDirection = (direction) ->
    $("#directionKeypress").html Math.round(direction * 1000) / 1000
    
    #Animating thumb to display the direction
    $("#thumbDirection").css left: (((Math.round(direction * 1000) / 1000) + 1) * ($("#direction").width() / 2))
  updateSpeed = (speed) ->
    $("#speedKeypress").html Math.round(speed * 1000) / 1000
    $("#thumbForward").css top: (((Math.round(-speed * 100) / 100) + 1) * ($("#forward").height() / 2))
  direction = 0
  speed = 0
  kd.run ->
    kd.tick()

  kd.LEFT.down ->
    if direction >= -1
      direction -= 0.025
      $("#leftButton").addClass "buttonsKeypressActive"
      updateDirection direction

  kd.LEFT.up ->
    $("#leftButton").removeClass "buttonsKeypressActive"

  kd.RIGHT.down ->
    if direction <= 1
      direction += 0.025
      $("#rightButton").addClass "buttonsKeypressActive"
      updateDirection direction

  kd.RIGHT.up ->
    $("#rightButton").removeClass "buttonsKeypressActive"

  kd.DOWN.down ->
    if speed >= -1
      speed -= 0.025
      $("#backButton").addClass "buttonsKeypressActive"
      updateSpeed speed

  kd.DOWN.up ->
    $("#backButton").removeClass "buttonsKeypressActive"

  kd.UP.down ->
    if speed <= 1
      speed += 0.025
      $("#forwardButton").addClass "buttonsKeypressActive"
      updateSpeed speed

  kd.UP.up ->
    $("#forwardButton").removeClass "buttonsKeypressActive"

  setInterval (->
    if (Math.round(speed * 1000) / 1000) >= 0.025
      speed -= 0.025
      updateSpeed speed
    else if (Math.round(speed * 1000) / 1000) < 0
      speed += 0.025
      updateSpeed speed
  ), 150
