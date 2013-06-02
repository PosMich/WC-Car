$ ->

  PORT_SERVER = "8080"
  PORT_SOCKET = "8081"
  OFFSET_LEFT = 60
  OFFSET_BWD = 60
  START_BWD = -40

  direction = 0
  motion_direction = 0;
  speed = 0
  motion_speed = 0;
  keys = {}

  connected = false
  connection = null

  IP = /[0-9]+.[0-9]+.[0-9]+.[0-9]+/i.exec document.URL

  $(".connect").click (e)->
    e.preventDefault()
    $(".connect").after("<img />")

    $img = $("#imgStream")
    height = $(".imgContainer").height()
    width =  $(".imgContainer").width()

    connection = new WebSocket( "ws://" + IP + ":" + PORT_SOCKET )
    connection.onopen = ->
      console.log "connection opened."
      connection.send JSON.stringify ( {"type": 0, "token": $("#token").val()} )
      connected = true

    connection.onmessage = (e)->
      message = JSON.parse e.data

      if message.type is "signal_strength"
        if message.value <= 9
          $("#Signal").html "You're going to loose the Wifi-Signal. Please drive back!"
        else
          $("#Signal").html ""
      else if message.type is "image_data"
        $("#imgStream").attr "src", "data:image/jpg;base64," + message.value


    #Get Device Orientation values

    keyDownEvent = (event) ->
      
      keys[e.which] = true
      for i in keys
        console.log i
        if i is 37
          if direction >= -1
            direction -= 0.025
            updateDirection direction
        else if i is 39
          if direction <= 1
            direction += 0.025
            updateDirection direction
        if i is 40
          if speed >= -1
            speed = 0  if speed > 0
            speed -= 0.025
            updateSpeed speed
        else if i is 38
          if speed <= 1
            speed = 0  if speed < 0
            speed += 0.025
            updateSpeed speed

    keyUpEvent = (event) ->
      delete keys[e.which];

    lagebestimmung = (event) ->
      alpha = Math.round(event.alpha)
      beta = Math.round(event.beta)
      gamma = Math.round(event.gamma)

      # console.log window.orientation

      if window.orientation is -90
        if connected
          l2r = Math.round( ( ( 2 / OFFSET_LEFT ) * beta ) * -100) / 100
          # l2r *= -1

          if l2r > 1
            l2r = 1
          else if l2r < -1
            l2r = -1


          # normalize start orientation (bwd 2 fwd)
          gamma = gamma + START_BWD;
          b2f = Math.round( ( ( 2 / OFFSET_BWD ) * gamma ) * -100) / 100

          if b2f > 1
            b2f = 1
          else if b2f < -1
            b2f = -1

          updateDirection l2r
          updateSpeed b2f
          
      else if window.orientation is 90
        if connected

          l2r = Math.round( ( ( 2 / OFFSET_LEFT ) * beta ) * 100) / 100

          if l2r > 1
            l2r = 1
          else if l2r < -1
            l2r = -1

          # normalize start orientation (bwd 2 fwd)
          gamma = gamma - START_BWD;
          
          b2f = Math.round( ( ( 2 / OFFSET_BWD ) * gamma ) * 100) / 100

          if b2f > 1
            b2f = 1
          else if b2f < -1
            b2f = -1

          updateDirection l2r
          updateSpeed b2f

        else if window.orientation is 0 or window.orientation is 180
          console.log "turn your phone in langscape mode"

    alpha = undefined
    beta = undefined
    gamma = undefined

    window.addEventListener "deviceorientation", lagebestimmung, false
    window.addEventListener "keydown", keyDownEvent, false
    window.addEventListener "keyup", keyUpEvent, false

    window.connection = connection

  # send post request to shut the connection down immediatly
  $(".kill").click ->
    console.log IP + ":" + PORT_SERVER
    post_to_url "http://" + IP + ":" + PORT_SERVER, {'passphrase': $("#passphrase").val()}, 'post'

  post_to_url = (path, params, method) ->
    method = method or "post" # Set method to post by default if not specified..
    form = document.createElement("form")
    form.setAttribute "method", method
    form.setAttribute "action", path
    for key of params
      if params.hasOwnProperty(key)
        hiddenField = document.createElement("input")
        hiddenField.setAttribute "type", "hidden"
        hiddenField.setAttribute "name", key
        hiddenField.setAttribute "value", params[key]
        form.appendChild hiddenField
    document.body.appendChild form
    form.submit()

  updateDirection = (direction) ->
    if direction <= (motion_direction - 0.1) or direction >= (motion_direction + 0.1)
      console.log "change"
      motion_direction = direction
      if motion_direction <= 0.05 && motion_direction >= 0 ||
          motion_direction >= -0.05 && motion_direction <= 0
        motion_direction = 0;

    $("#Direction").html direction
    sendMotion()

  updateSpeed = (speed) ->
    if speed <= (motion_speed - 0.1) or speed >= (motion_speed + 0.1)
      console.log "change"
      motion_speed = speed
      if motion_speed <= 0.05 && motion_speed >= 0 ||
          motion_speed >= -0.05 && motion_speed <= 0
        motion_speed = 0;

      $("#Speed").html speed
      sendMotion()

  sendMotion = ->
      connection.send JSON.stringify ( 
        {"type": 1, "l2r": motion_direction.toFixed(2), "b2f": motion_speed.toFixed(2)} )
      console.log "message sent."

  $(window).resize (->
      height = $(".imgContainer").height()
      width =  $(".imgContainer").width()

      $("#imgStream").css {
        width: width,
        height: height
      }
  )
  setInterval (->
    if connected
      if speed > 0.025
        speed -= 0.025
        updateSpeed speed
      else if speed <= 0
        speed += 0.025
        updateSpeed speed
  ), 200
