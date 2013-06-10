$(document).ready(function() {

	IP = /[0-9]+.[0-9]+.[0-9]+.[0-9]+/i.exec(document.URL);
	PORT_SERVER = "8080";

	$("#kill").click(function() {
		post_to_url( "http://" + IP + ":" + PORT_SERVER, {'passphrase': $("#passphrase").val()}, 'post' );
	});

	post_to_url = function( path, params, method ) {
    	method = method || "post"; // Set method to post by default if not specified..
    
    	form = document.createElement("form");
	    form.setAttribute("method", method);
	    form.setAttribute("action", path);

	    for (key in params) {
	      if (params.hasOwnProperty(key)) {
	        hiddenField = document.createElement("input");
	        hiddenField.setAttribute("type", "hidden");
	        hiddenField.setAttribute("name", key);
	        hiddenField.setAttribute("value", params[key]);
	        form.appendChild(hiddenField);
	      }
	    }

	    document.body.appendChild(form);

	    form.submit();
	}
});