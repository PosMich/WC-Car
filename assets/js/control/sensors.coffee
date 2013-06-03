$ ->
  
  #Get Device Orientation values
  lagebestimmung = (event) ->
    beta = Math.round(event.beta)
    gamma = Math.round(event.gamma)
    if orientation is -90
      $("#notification").hide()
      $("#blackening").hide()
      $("#gGamma").html Math.round((1 - (1 / 90) * gamma) * 100) / 100
      $("#gBeta").html Math.round(-((1 / 75) * beta) * 100) / 100
      $("#orient").html orientation
      
      #Animating thumb to display the direction
      $("#thumbDirection").css left: (((Math.round(-((1 / 75) * beta) * 100) / 100) + 1) * ($("#direction").width() / 2))
      
      #Animating thumb to display speed
      $("#thumbForward").css top: ((Math.round(((1 / 90) * gamma) * 100) / 100) * ($("#forward").height() / 2))
    
    #$("#wGamma").html(((Math.round(((1/90)*gamma)*100)/100)*($('#forward').height()/2)));
    else if orientation is 90
      $("#notification").hide()
      $("#blackening").hide()
      
      #Getting values and animating thumb to display speed
      #Query because of degree behavior at this orientation 
      if gamma < 0
        $("#gGamma").html Math.round((1 + (1 / 90) * gamma) * 100) / 100
        $("#thumbForward").css top: ((Math.round(-((1 / 90) * gamma) * 100) / 100) * ($("#forward").height() / 2))
      else
        $("#gGamma").html Math.round((1 + (1 / 90) * gamma) * 100 - 400) / 100
        $("#thumbForward").css top: ((Math.round(-((1 / 90) * gamma) * 100 + 400) / 100) * ($("#forward").height() / 2))
      $("#gBeta").html Math.round(((1 / 75) * beta) * 100) / 100
      $("#wBeta").html -beta
      $("#orient").html orientation
      
      #Animating thumb to display the direction
      $("#thumbDirection").css left: (((Math.round(((1 / 75) * beta) * 100) / 100) + 1) * ($("#direction").width() / 2))
    
    #Portrait Mode 
    else if orientation is 0 or orientation is 180
      $("#orient").html orientation
      $("#notification").show()
      $("#blackening").show()
  alpha = undefined
  beta = undefined
  gamma = undefined
  window.addEventListener "deviceorientation", lagebestimmung, false
