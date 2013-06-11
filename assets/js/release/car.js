var localStream;
var localVideo = document.getElementById("car");
var pc;
var socket;
var serverUri = "localhost:8000";
var controlChannel;

var pcConfig = {"iceServers": [{"url": "stun:stun.l.google.com:19302"}]};
var connection = { 'optional': [{'DtlsSrtpKeyAgreement': true}, {'RtpDataChannels': true }] };

var mediaConstraints = {"audio": false, "video": true};

var sdpConstraints = {'mandatory': {
  'OfferToReceiveAudio' : false,
  'OfferToReceiveVideo' : true
}};

function startWebRTC() {

    /****   STEP 1: create ws for signaling    ****/
    console.log("trying to create WebSocket connection to " + serverUri);
    socket = new WebSocket( 'ws://' + serverUri );

    function onIceCandidate(event) {
        if (event.candidate) {
            sendMessage({type: 'candidate',
            label: event.candidate.sdpMLineIndex,
            id: event.candidate.sdpMid,
            candidate: event.candidate.candidate});
        } else {
            console.log('End of candidates.');
        }
    }

    function onUserMediaSuccess(stream) {
        console.log('User has granted access to local media.');
        // Call the polyfill wrapper to attach the media stream to this element.
        attachMediaStream(localVideo, stream);
        

        localVideo.style.display = "none";

        localStream = stream;

        console.log('Adding local stream.');
        /****   STEP 2: create PeerConnection      ****/
        try {
            // Create an RTCPeerConnection via the polyfill (adapter.js).
            pc = new RTCPeerConnection(pcConfig, connection);
            pc.onicecandidate = onIceCandidate;
            console.log('Created RTCPeerConnnection with:\n  config: \'' + JSON.stringify(pcConfig));
        } catch (e) {
            console.log('Failed to create PeerConnection, exception: ' + e.message);
            alert('Cannot create RTCPeerConnection object; WebRTC is not supported by this browser.');
            return;
        }

        controlChannel = pc.createDataChannel("control", {reliable:false});

        controlChannel.onopen = function() {
            console.log("controlChannel opened");
        };

        controlChannel.onclose = function() {
             console.log("controlChannel closed");
        };

        controlChannel.onmessage = control;
        pc.addStream(localStream);
    }

    function onUserMediaError(error) {
        console.log('Failed to get access to local media. Error code was ' + error.code);
        alert('Failed to get access to local media. Error code was ' + error.code + '.');
    }


    function control(event) {
        console.log("controlChannel message received: "+event.data);
        var msg = event.data;
        var html = $(".data").html();
        $(".data").html(html+"<br>"+msg);
    }



    function setLocalAndSendMessage(sessionDescription) {
        // Set Opus as the preferred codec in SDP if Opus is present.
        // sessionDescription.sdp = preferOpus(sessionDescription.sdp);
        pc.setLocalDescription(sessionDescription);

        sendMessage({type:"answer",sdp:sessionDescription});
    }


    socket.onopen = function() {
        console.log("socket connection established");
        /****   STEP 3: obtaining local media      ****/

        try {
            getUserMedia(mediaConstraints, onUserMediaSuccess, onUserMediaError);

            console.log('Requested access to local media with mediaConstraints:\n\\' + JSON.stringify(mediaConstraints) + '\'');
        } catch (e) {
            alert('getUserMedia() failed. Is this a WebRTC capable browser?');
            console.log('getUserMedia failed with exception: ' + e.message);
        }
    };

    socket.onmessage = function(message) {
        console.log('S->C: ' + message.data);
        var msg = JSON.parse(message.data);
        processSignalingMessage(msg);
    };

    socket.onerror = function() {
        console.log('Channel error.');
    };

    socket.onclose = function() {
        console.log('Channel closed.');
    };



    function processSignalingMessage(message) {
        console.log("Processing:");
        console.log(message);
        if (message.type === 'offer') {
            // Set Opus in Stereo, if stereo enabled.
            // if (stereo)
            //  message.sdp = addStereo(message.sdp);
            pc.setRemoteDescription(new RTCSessionDescription(message.sdp));
            doAnswer();
        } else if (message.type === 'candidate') {
            var candidate = new RTCIceCandidate({sdpMLineIndex: message.label, candidate: message.candidate});
            pc.addIceCandidate(candidate);
        } else if (message.type === 'bye') {
            console.log("bye");
        }
    }

    function doAnswer() {
        pc.createAnswer(setLocalAndSendMessage, null, sdpConstraints);
    }

    function sendMessage(message) {
        var msgString = JSON.stringify( message );
        console.log('C->S: ' + msgString);
        socket.send(msgString);
    }
}
