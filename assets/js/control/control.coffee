$(document).ready ->

    serverUri = "webcar.multimediatechnology.at:8000"


    remoteStream = null
    remoteVideo = document.getElementById "remote"
    controlChannel = null
    peerConnection = null
    signalingDone = false
    displayStream = false

    pcConfig = iceServers: [url: "stun:stun.l.google.com:19302"]
    connection = optional: [
      DtlsSrtpKeyAgreement: true
    ,
      RtpDataChannels: true
    ]

    offerConstraints =
      optional: []
      mandatory:
        OfferToReceiveAudio: false
        OfferToReceiveVideo: true

    socket = null

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
            $("#connect").attr("disabled", true)
            $("#passphrase_error").html(msg);
        else
            $("#connect").attr("disabled", false)
            $("#passphrase_error").html("");

    $("#connect").click (e) ->
        if !$("#connect").attr("disabled")
            socket = new WebSocket("ws://" + serverUri)
            socket.onopen = ->
                socket.send(JSON.stringify {"type": "login", "user": "driver", "carId": carId, "pw": $("#passphrase_input").val()} )
                console.log "sent data to server"

            socket.onmessage = (msg) ->
                console.log "message received."
                msg  = JSON.parse msg.data

                if !signalingDone
                    if msg.type is "success"
                        #start webrtc
                        $("login_error").html ""

                        onIceCandidate = (event) ->
                            if event.candidate
                                sendMessage
                                    type: "candidate"
                                    label: event.candidate.sdpMLineIndex
                                    id: event.candidate.sdpMid
                                    candidate: event.candidate.candidate
                            else
                                console.log "End of candidates."

                        onRemoteStreamAdded = (event) ->
                            console.log "Remote stream added."
                            console.log remoteVideo
                            console.log event.stream
                            attachMediaStream remoteVideo, event.stream
                            remoteStream = event.stream
                            waitForRemoteVideo()

                        waitForRemoteVideo = ->
                            console.log "wait for remote video"

                            # Call the getVideoTracks method via adapter.js.
                            videoTracks = remoteStream.getVideoTracks()
                            if videoTracks.length is 0 or remoteVideo.currentTime > 0
                                console.log "got remote video"
                                if !displayStream
                                    display()
                                    displayStream = true
                            else
                                setTimeout waitForRemoteVideo, 100

                        onRemoteStreamRemoved = (event) ->
                            console.log "Remote stream removed."

                        doCall = ->
                            console.log "Sending offer to peer, with constraints: \n"
                            peerConnection.createOffer setLocalAndSendMessage, null, offerConstraints

                        setLocalAndSendMessage = (sessionDescription) ->

                            # Set Opus as the preferred codec in SDP if Opus is present.
                            # sessionDescription.sdp = preferOpus(sessionDescription.sdp);
                            peerConnection.setLocalDescription sessionDescription
                            sendMessage
                                type: "offer"
                                sdp: sessionDescription
                        ###
                        STEP 2: create PeerConnection      ***
                        ###
                        try

                            # Create an RTCPeerConnection via the polyfill (adapter.js).
                            peerConnection = new RTCPeerConnection(pcConfig, connection)
                            peerConnection.onicecandidate = onIceCandidate
                            console.log "Created RTCPeerConnnection with:\n  config: '" + JSON.stringify(pcConfig) + "';\n"
                        catch e
                            console.log "Failed to create PeerConnection, exception: " + e.message
                            alert "Cannot create RTCPeerConnection object; WebRTC is not supported by this browser."


                        peerConnection.onaddstream = onRemoteStreamAdded
                        peerConnection.onremovestream = onRemoteStreamRemoved
                        controlChannel = peerConnection.createDataChannel("control",
                            reliable: false
                        )
                        left2right = -1
                        bwd2fwd = -1
                        controlChannel.onopen = ->
                            window.controlChannel = controlChannel
                            console.log "controlChannel opened"
                            ###
                            setInterval (->
                                controlChannel.send JSON.stringify({l2r:left2right,b2f:bwd2fwd})
                                left2right += 0.1
                                bwd2fwd += 0.1
                                if left2right > 1
                                    left2right = -1
                                if bwd2fwd > 1
                                    bwd2fwd = -1
                            ), 500
                            ###

                        controlChannel.onclose = ->
                            window.controlChannel = null
                            console.log "controlChannel closed"

                        signalingDone = true
                        doCall()

                    else if msg.type is "error"
                        console.log msg.msg
                        $("#login_error").html msg.msg
                else
                    if msg.type is "answer"
                        console.log "setRemoteDescription"
                        peerConnection.setRemoteDescription new RTCSessionDescription(msg.sdp)
                    else if msg.type is "candidate"
                        candidate = new RTCIceCandidate(
                            sdpMLineIndex: msg.label
                            candidate: msg.candidate
                        )
                        peerConnection.addIceCandidate candidate
                    else console.log "bye"  if msg.type is "bye"

            socket.onerror = ->
                console.log 'Channel error.'

            socket.onclose = ->
                console.log 'Channel closed.'

            sendMessage = (message) ->
                msgString = JSON.stringify(message)
                console.log "C->S: " + msgString
                socket.send msgString

            display = ->
                console.log "display stream"
                $("#password").css display: "none"
                $("body").css "background-image", "none"
                $("#remote").css display: "block"
                width = $("#videoContainer").width()
                height = $("#videoContainer").height()
                $("#remote").css
                    display: "block"
                $("#controls").css display: "block"

            # $(window).onresize = (e) ->
            #     width = $("#videoContainer").width()
            #     height = $("#videoContainer").height()
            #     $("#remote").css
            #         width: width
            #         height: height


