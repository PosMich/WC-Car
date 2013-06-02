$(document).ready ->	
  $("#main-menu a:not(.linkit)").click (e) ->
    e.preventDefault()
    $.scrollTo @hash or 0, 400,
      offset:
        top: -60

  $("#main-menu-left li a").on "click", ->
    $("#main-menu").toggleClass "height"