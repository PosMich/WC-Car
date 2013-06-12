$(document).ready ->

    $("#passphrase_kill").bind "input", ->
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
            $("#kill").attr("disabled", true)
            $("#passphrase_error").html(msg);
        else
            $("#kill").attr("disabled", false)
            $("#passphrase_error").html("");

    $("#kill").click (e) ->
        if !$("#kill").attr("disabled")
            console.log "trying to kill the connection"
            $.post("/kill",
                password:  $("#passphrase_kill").val()
            , (data) ->
                if data.success
                    window.location.href "/choose"
                else
                    console.log "wasn't able to kill the connection. user? password?"
        )