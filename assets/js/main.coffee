$(document).ready ->
    $("#main-menu a").click (e) ->
        e.preventDefault()
        $.scrollTo @hash or 0, 400,
            offset:
                top: -60