$(document).ready ->	
	$("a.btn").click (e) ->
		console.log "aha"
		e.preventDefault()
		$("html, body").animate
			scrollTop: $(@hash).offset().top
		, 600