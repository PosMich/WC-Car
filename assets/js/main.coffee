$(document).ready ->	
  $("#main-menu a:not(.linkit)").click (e) ->
    e.preventDefault()
    $.scrollTo @hash or 0, 400,
      offset:
        top: -60

  $("#main-menu-left li a").on "click", ->
    $("#main-menu").toggleClass "height"

# Remove the ugly Facebook appended hash
# <https://github.com/jaredhanson/passport-facebook/issues/12>
if window.location.hash and window.location.hash is "#_=_"
  
  # If you are not using Modernizr, then the alternative is:
  #   `if (window.history && history.pushState) {`
  if window.history and window.history.pushState
    window.history.pushState "", document.title, window.location.pathname
  else
    
    # Prevent scrolling by storing the page's current scroll offset
    scroll =
      top: document.body.scrollTop
      left: document.body.scrollLeft

    window.location.hash = ""
    
    # Restore the scroll offset, should be flicker free
    document.body.scrollTop = scroll.top
    document.body.scrollLeft = scroll.left