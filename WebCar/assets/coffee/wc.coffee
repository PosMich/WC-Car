$ ->
	$(".connect").click (e)->
		#console.log "click"
		e.preventDefault()
		$(".connect").after("<img />");

		$img = $("#imgStream");
		# $img.attr "src", "./img/settings.png"


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

		match = /[0-9]+.[0-9]+.[0-9]+.[0-9]+/i.exec document.URL

		conn = new WebSocket("ws://"+match+":8081");

		conn.onmessage = (e)->
			#console.log e
			$("#imgStream").attr "src", "data:image/jpg;base64,"+e.data

		window.connection = conn

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
