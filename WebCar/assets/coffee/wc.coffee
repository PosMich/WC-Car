$ ->

  PORT_SERVER = "8080"
  PORT_SOCKET = "8081"
  OFFSET_LEFT = 45;
  OFFSET_BWD = 30;
  START_BWD = -60;


  connected = false;
  IP = /[0-9]+.[0-9]+.[0-9]+.[0-9]+/i.exec document.URL

  $(".connect").click (e)->
    e.preventDefault()
    $(".connect").after("<img />");

    $img = $("#imgStream");


    height = $(".imgContainer").width()
    width =  $(".imgContainer").height()

    $img.css {
      width: width,
      height: height,
      top: (width-height)/2
      left: (height-width)/2
    }

    $img.css {
      "-webkit-transform": "rotate(90deg)",
      "-moz-transform": "rotate(90deg)",
      "transform": "rotate(90deg)"
    }

    conn = new WebSocket( "ws://" + IP + ":" + PORT_SOCKET )
    conn.onopen = ->
      conn.send JSON.stringify ( {"type": 0, "token": $("#token").val()} )
      connected = true;

    conn.onmessage = (e)->
      $("#imgStream").attr "src", "data:image/jpg;base64,"+e.data


    #Get Device Orientation values

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

          console.log "b2f: " + b2f + ", l2r: " + l2r
          # conn.send JSON.stringify ( {"type": 0, "token": $("#token").val()} )
          conn.send JSON.stringify ( {"type": 1, "l2r": l2r, "b2f": b2f} )
          
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

          console.log "b2f: " + b2f + ", l2r: " + l2r

          conn.send JSON.stringify ( {"type": 1, "l2r": l2r, "b2f": b2f} )
      
      #Portrait Mode 
      else window.orientation is 0 or window.orientation is 180
        console.log "turn your phone in langscape mode"

    alpha = undefined
    beta = undefined
    gamma = undefined

    window.addEventListener "deviceorientation", lagebestimmung, false

    window.connection = conn

  # send post request to shut the connection down immediatly
  $(".kill").click ->
    console.log IP+":"+PORT_SERVER
    post_to_url "http://" + IP+":"+PORT_SERVER, {'passphrase': $("#passphrase").val()}, 'post'

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


$(window).resize (->
    height = $(".imgContainer").width()
    width =  $(".imgContainer").height()

    $("#imgStream").css {
      width: width,
      height: height,
      top: (width-height)/2
      left: (height-width)/2
    }
)
