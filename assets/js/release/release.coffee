$(document).ready ->

    localStream = null
    localVideo = $("#car")[0]
    peerConnection = null
    socket = null
    serverUri = "10.0.0.8:8000"
    controlChannel = null
    authDone = false

    pcConfig = iceServers: [url: "stun:stun.l.google.com:19302"]
    connection = optional: [
        DtlsSrtpKeyAgreement: true
    ,
        RtpDataChannels: true
    ]

    mediaConstraints =
        audio: false
        video: true

    sdpConstraints = mandatory:
        OfferToReceiveAudio: false
        OfferToReceiveVideo: true

    $("#ready").click (e) ->

        if !$(this).attr("disabled")

            # trying to register car
            console.log "trying to register car."
            pw = $("#passphrase_input").val();
            url = ""

            #send PW to Server
            $.post("/registerCar",
                password: pw
            , (data) ->
                if data != null
                    url = data.tinyUrl
                    carId = data.carId

                    # Start WebRTC
                    console.log "trying to start WebRTC."

                    ###
                    STEP 1: create ws for signaling
                    ###
                    console.log "trying to create WebSocket connection to " + serverUri
                    socket = new WebSocket "ws://" + serverUri

                    socket.onopen = ->

                        # send first message
                        sendMessage
                            type: "login"
                            user: "car"
                            carId: carId
                            pw: pw

                        console.log "socket connection established"

                    socket.onmessage = (data) ->
                        console.log "S->C: " + data
                        msg = JSON.parse(data)

                        if !authDone
                            if msg.type is "success"

                                ### 
                                STEP 3: obtaining local media
                                ###
                                try
                                    getUserMedia mediaConstraints, onUserMediaSuccess, onUserMediaError
                                    console.log "Requested access to local media with mediaConstraints:\n\\" + JSON.stringify(mediaConstraints) + "'"
                                catch e
                                    alert "getUserMedia() failed. Is this a WebRTC capable browser?"
                                    console.log "getUserMedia failed with exception: " + e.message

                                onIceCandidate = (event) ->
                                    if event.candidate
                                        sendMessage
                                            type: "candidate"
                                            label: event.candidate.sdpMLineIndex
                                            id: event.candidate.sdpMid
                                            candidate: event.candidate.candidate
                                    else
                                        console.log "End of candidates."

                                onUserMediaSuccess = (stream) ->
                                    console.log "User has granted access to local media."
                                    attachMediaStream(localVideo, stream)

                                    localVideo.style.display = "none"
                                    localStream = stream

                                    console.log "adding local stream and trying to create PeerConnection."

                                    ###
                                    STEP 2: create PeerConnection
                                    ###
                                    try
                                        peerConnection = new RTCPeerConnection(pcConfig, connection)
                                        peerConnection.onicecandidate = onIceCandidate
                                        peerConnection.onclose =
                                        console.log "Created RTCPeerConnnection with:\n  config: '" + JSON.stringify(pcConfig)
                                    catch e
                                        console.log "Failed to create PeerConnection, exception: " + e.message
                                        alert "Cannot create RTCPeerConnection object; WebRTC is not supported by this browser."

                                    controlChannel = peerConnection.createDataChannel("control",
                                        reliable: false
                                    )

                                    controlChannel.onopen = ->
                                        console.log "controlChannel opened"

                                    controlChannel.onclose = ->
                                        console.log "controlChannel closed"

                                    controlChannel.onmessage = control
                                    peerConnection.addStream localStream

                                onUserMediaError = (error) ->
                                    console.log "Failed to get access to local media. Error code was " + error.code
                                    alert "Failed to get access to local media. Error code was " + error.code + "."

                                control = (event) ->
                                    console.log "controlChannel message received: " + event.data
                                    msg = event.data
                                    console.log msg

                                setLocalAndSendMessage = (sessionDescription) ->

                                    # Set Opus as the preferred codec in SDP if Opus is present.
                                    # sessionDescription.sdp = preferOpus(sessionDescription.sdp);
                                    peerConnection.setLocalDescription sessionDescription
                                    sendMessage
                                        type: "answer"
                                        sdp: sessionDescription

                                doAnswer = ->
                                        pc.createAnswer setLocalAndSendMessage, null, sdpConstraints
                            else if msg.type is "error"
                                console.log "error"
                        else
                            console.log "Processing:"
                            console.log msg
                            if msg.data.type is "offer"

                                # Set Opus in Stereo, if stereo enabled.
                                # if (stereo)
                                #  message.sdp = addStereo(message.sdp);
                                peerConnection.setRemoteDescription new RTCSessionDescription(msg.sdp)
                                doAnswer()
                            else if msg.data.type is "candidate"
                                candidate = new RTCIceCandidate(
                                    sdpMLineIndex: msg.label
                                    candidate: msg.candidate
                                )
                                peerConnection.addIceCandidate candidate
                            else console.log "bye"  if msg.data.type is "bye"


                    socket.onerror = ->
                        console.log "Channel error."

                    socket.onclose = ->
                        $.post("/kill",
                            password: pw
                        , (data) ->
                            if data != null
                                window.location.href "/kill"
                        )

                        console.log "Channel closed."

                    sendMessage = (message) ->
                        msgString = JSON.stringify(message)
                        console.log "C->S: " + msgString
                        socket.send msgString

                    # set url/error and scroll to last point
                    console.log "url: "+url
                    $("#webrtcUrl").html url
                    $("#webrtcUrl").animate
                        opacity: 1
                    , 750

                    $("html, body").animate
                        scrollTop: $("#ready").offset().top
                    , 600

                else
                    console.log "no url received"

            ).fail ->
                console.log "register failed."
                url = "Uops. Da ist wohl was schief gelaufen. Bitte versuche es erneut."


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

    $("a.btn:not(#control_kill)").click (e) ->
        e.preventDefault()
        if !$(this).attr("id")
            $("html, body").animate
                scrollTop: $(@hash).offset().top
            , 600