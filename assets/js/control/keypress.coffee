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
  keys = {}
  $(document).keydown (e) ->
    keys[e.which] = true
    for i of keys
      if i is 37
        if direction >= -1
          direction -= 0.025
          $("#leftButton").addClass "buttonsKeypressActive"
          updateDirection direction
      else if i is 39
        if direction <= 1
          direction += 0.025
          $("#rightButton").addClass "buttonsKeypressActive"
          updateDirection direction
      if i is 40
        if speed >= -1
          speed -= 0.025
          $("#backButton").addClass "buttonsKeypressActive"
          updateSpeed speed
      else if i is 38
        if speed <= 1
          speed += 0.025
          $("#forwardButton").addClass "buttonsKeypressActive"
          updateSpeed speed
    $(document).keyup (e) ->
      switch e.keyCode
        when 37
          $("#leftButton").removeClass "buttonsKeypressActive"
        when 39
          $("#rightButton").removeClass "buttonsKeypressActive"
        when 40
          $("#backButton").removeClass "buttonsKeypressActive"
        when 38
          $("#forwardButton").removeClass "buttonsKeypressActive"
      delete keys[e.which]


  setInterval (->
    if speed >= 0.025
      speed -= 0.025
      updateSpeed speed
    else if speed < 0
      speed += 0.025
      updateSpeed speed
  ), 200
