$(document).ready ->	
	$("a.btn").click (e) ->
		e.preventDefault()
		if !$(this).attr("id")
			$("html, body").animate
				scrollTop: $(@hash).offset().top
			, 600

	$("#ready").click (e) ->

		if !$(this).attr("disabled")
			#send PW to Server

			# Generate and display tiny URL
			console.log "generating tiny url."


			# Start WebRTC
			console.log "trying to start WebRTC."
			startWebRTC()

			$("html, body").animate
				scrollTop: $(@hash).offset().top
			, 600
		else
			

	$("#passphrase_input").bind "input", ->
	  
	  pw = $(this).val()
	  error = false
	  msg = "";

	  if pw.length is 0
	  	error = true
	  	msg = "Passwort benötigt."

	  if pw.length < 5
	  	error = true
	  	msg = "Passwort ist zu kurz.";

	  if error
	  	$("#ready").attr("disabled", true)
	  	$("#passphrase_error").html(msg);
	  else
	  	$("#ready").attr("disabled", false)
	  	$("#passphrase_error").html("");


