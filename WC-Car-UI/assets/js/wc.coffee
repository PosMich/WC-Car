$ ->
	$(".connect").click (e)->
		console.log "click"
		e.preventDefault()
		$(".connect").after("<img />");

		conn = new WebSocket("ws://"+$(".ip").val());

		#window.lock = true;
		#setInterval (->window.lock = false), 100

		# $("#imgContainer").width("100%");
		# $("#imgContainer").height("100%");

		# width = $("#imgContainer").width();
		# height = $("#imgContainer").height();

		# console.log width
		# console.log height

		# $("#imgContainer").width(height+"px");
		# $("#imgContainer").height(width+"px");		


		conn.onmessage = (e)->
			#if window.lock is false
			#console.log e
			$("#imgContainer").attr "src", "data:image/jpg;base64,"+e.data
			#$(".imageContainer").css {backgroundImage: "url(data:image/jpg;base64,"+e.data+")"}

		window.connection = conn
