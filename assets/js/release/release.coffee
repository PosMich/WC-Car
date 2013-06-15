$(document).ready ->

    serverUri = "localhost:8000"
    class Motion2Sound
        constructor: ->
            @debug = true
            @TAG = "Motion2Sound"

            # boundaries --> drive left */
            @minFreqLeft = 1000
            @maxFreqLeft = 9000

            # boundaries --> drive right */
            @minFreqRight = 11000
            @maxFreqRight = 20000

            # boundaries --> drive backward */
            @minFreqBwd = 100
            @maxFreqBwd = 490

            # boundaries --> drive forward */
            @minFreqFwd = 510
            @maxFreqFwd = 900

            # drive straight Frequency */
            @straightFreq = 10000

            # stop Frequency */
            @stopFreq = 500

            # init AudioContext

            @context = new webkitAudioContext()
            @oscillator = @context.createOscillator()
            @oscillator.type = 0
            @setFreq 0
            @playSound()

        setFreq: (val) ->
            @oscillator.frequency.value = val

        stopSound: ->
            @oscillator.disconnect()

        playSound: ->
            @oscillator.connect @context.destination
            @oscillator.noteOn && @oscillator.noteOn(0)


        debugOut: (txt) ->
            console.log(@TAG+": "+txt) if @debug

        drive: (left2right, bwd2fwd) ->
            @debugOut "l2r: "+left2right+" |b2f: "+bwd2fwd

            b2f = @getFreqbwd2fwd bwd2fwd
            l2r = @getFreqlft2rght left2right

            @debugOut "bwd2fwd: "+b2f
            @debugOut "left2right: "+l2r

            @setFreq l2r+b2f

        getFreqlft2rght: (l2r) ->
            if l2r>0
                # keep in boundaries */
                l2r = 1 if l2r>1

                # drive right */
                return @minFreqRight + parseInt(l2r * (@maxFreqRight - @minFreqRight) / 1000) * 1000

            else if l2r<0
                # keep in boundaries */
                l2r = -1 if l2r<-1

                # drive left */
                return @maxFreqLeft + parseInt(l2r * (@maxFreqLeft - @minFreqLeft) / 1000) * 1000
            else
                # drive straight */
                return @straightFreq;

        getFreqbwd2fwd: (b2f) ->
            if (b2f > 0)
                # keep in boundaries */
                b2f = 1 if b2f>1

                # drive forward */
                return parseInt((@minFreqFwd+b2f*(@maxFreqFwd-@minFreqFwd)));

            else if b2f<0
                # keep in boundaries */
                b2f = -1 if b2f<-1

                # drive backward */
                return parseInt((@maxFreqBwd+b2f*(@maxFreqBwd-@minFreqBwd)));
            else
                # stop */
                return @stopFreq

        stop: ->
            @stopSound()



    debug = true
    localStream = null
    localVideo = $("#car")[0]
    peerConnection = null
    socket = null
    controlChannel = null
    authDone = false
    Driver = null

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


    control = (event) ->
        console.log event
        console.log "controlChannel message received: " + event.data
        msg = JSON.parse(event.data)
        console.log msg
        Driver.drive msg.l2r, msg.b2f

    setLocalAndSendMessage = (sessionDescription) ->

        # Set Opus as the preferred codec in SDP if Opus is present.
        # sessionDescription.sdp = preferOpus(sessionDescription.sdp);
        peerConnection.setLocalDescription sessionDescription
        sendMessage
            type: "answer"
            sdp: sessionDescription

    doAnswer = ->
        peerConnection.createAnswer setLocalAndSendMessage, null, sdpConstraints
    sendMessage = (message) ->
        msgString = JSON.stringify(message)
        console.log "C->S: " + msgString
        socket.send msgString

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
                if data.tinyUrl != false
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

                    socket.onmessage = (msg) ->
                        console.log "S->C: "
                        console.log msg
                        msg = JSON.parse(msg.data)

                        if !authDone
                            if msg.type is "success"
                                $("#connection_error").html ""
                                authDone = true;
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
                                    #attachMediaStream(localVideo, stream)

                                    #localVideo.style.display = "none"
                                    #localStream = stream

                                    console.log "adding local stream and trying to create PeerConnection."

                                    ###
                                    STEP 2: create PeerConnection
                                    ###
                                    try
                                        peerConnection = new RTCPeerConnection(pcConfig, connection)
                                        peerConnection.onicecandidate = onIceCandidate
                                        #peerConnection.onclose =
                                        console.log "Created RTCPeerConnnection with:\n  config: '" + JSON.stringify(pcConfig)
                                    catch e
                                        console.log "Failed to create PeerConnection, exception: " + e.message
                                        alert "Cannot create RTCPeerConnection object; WebRTC is not supported by this browser."

                                    controlChannel = peerConnection.createDataChannel("control",
                                        reliable: false
                                    )

                                    controlChannel.onopen = ->
                                        console.log "controlChannel opened"
                                        Driver = new Motion2Sound()

                                    controlChannel.onclose = ->
                                        console.log "controlChannel closed"
                                        Driver.stop()

                                    controlChannel.onmessage = control
                                    peerConnection.addStream stream


                                onUserMediaError = (error) ->
                                    console.log "Failed to get access to local media. Error code was " + error.code
                                    alert "Failed to get access to local media. Error code was " + error.code + "."

                                ###
                                STEP 3: obtaining local media
                                ###
                                try
                                    console.log "Requested access to local media with mediaConstraints:\n"
                                    console.log mediaConstraints
                                    getUserMedia mediaConstraints, onUserMediaSuccess, onUserMediaError

                                catch e
                                    alert "getUserMedia() failed. Is this a WebRTC capable browser?"
                                    console.log "getUserMedia failed with exception: " + e.message

                                return
                            else if msg.type is "error"
                                $("#connection_error").html msg.msg

                        else
                            console.log "Processing:"
                            console.log msg
                            if msg.type is "offer"

                                # Set Opus in Stereo, if stereo enabled.
                                # if (stereo)
                                #  message.sdp = addStereo(message.sdp);
                                peerConnection.setRemoteDescription new RTCSessionDescription(msg.sdp)
                                doAnswer()
                                return
                            else if msg.type is "candidate"
                                candidate = new RTCIceCandidate(
                                    sdpMLineIndex: msg.label
                                    candidate: msg.candidate
                                )
                                peerConnection.addIceCandidate candidate
                            else if msg.type is "bye"
                                Driver.stop()



                    socket.onerror = ->
                        console.log "Channel error."

                    socket.onclose = ->
                        $.post("/kill",
                            password: pw
                        , (data) ->
                            if data != null
                                window.location "/kill"
                        )

                        console.log "Channel closed."

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
                    $("#connection_error").html data.msg

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