"use strict"

# Controllers
@AppCtrl = ($scope, $http) ->

###
  console.log($scope)

  $http(
    method: "GET"
    url: "/api/name"
  ).success((data, status, headers, config) ->
    $scope.name = data.name
  ).error (data, status, headers, config) ->
    $scope.name = "Error!"
###

@DialogCtrl = ($scope, $dialog) ->

    $scope.openDialog = (pathToView, controller, additionalclass = "") ->
      $scope.opts =
      backdrop: true,
      keyboard: true,
      backdropClick: true,
      dialogFade: true,
      scroll: true,
      dialogClass: "modal " + additionalclass,
      templateUrl: "partials/" + pathToView,
      controller: controller

      d = $dialog.dialog $scope.opts

      d.open()

@LogInCtrl = ($scope, dialog, ConnectionService) ->
  $scope.update = (user, method = 'webcar') ->
    if $scope.login.$valid
      $scope.conn = ConnectionService.handle()
      console.log $scope.conn
      $scope.conn.onopen = ->
        $scope.conn.send JSON.stringify({
          "type": "login_data",
          "method": method,
          "username": user.name, 
          "password": user.password
          })

      $scope.conn.onmessage = (data) ->
        if data.authenticated
          dialog.close
        
        else
          # set error message in dialog

  $scope.close = (user) ->
    dialog.close()

  $scope.close

@SignUpCtrl = ($scope, dialog, ConnectionService) ->

  $scope.update = (user) ->
    if $scope.signup.$valid

      $scope.conn = ConnectionService.handle()
      $scope.conn.onopen = ->
        $scope.conn.send JSON.stringify({
          "type": "signup_data",
          "email": user.email,
          "username": user.name,
          "password": user.password
          })

      $scope.conn.onmessage = (data) ->
        if data.authenticated
          dialog.close

        else
          # set error message in dialog

  $scope.close = (user) ->
    dialog.close()

  $scope.close

@SettingsCtrl = ($scope, ConnectionService) ->

  $scope.conn = ConnectionService.handle()

  console.log $scope.conn

  # send request for available data
  $scope.conn.send JSON.stringify({ 
    "type": "settings_available"
    })

  $scope.conn.onmessage = (data) ->
    $scope.user.name = data.user.name
    $scope.user.email = data.user.email
    $scope.user.avatar = data.user.avatar

    $scope.master = $scope.user

  $scope.update = (user) ->
    if $scope.settings.valid && !$scope.isUnchanged user
      password_string = ($scope.user.old_password) ? '"password": ' + user.new_password
      console.log password_string
      $scope.master = user
      $scope.conn.send {
        "type": "settings_data",
        "username": user.name,
        "email": user.email
      }

  $scope.close = (user) ->
    dialog.close()

  $scope.isUnchanged = (user) ->
    return angular.equals user, $scope.master


# WebRTC stuff here.

@ReleaseCtrl = ($scope) ->
  console.log "release here."

  selfView = document.getElementById("sourcevid")
  remoteView = document.getElementById("remotevid")

  # localStream = null
  peerConn = null
  # started = false
  signalingChannel = new WebSocket("ws://localhost:8000")

  # socket = new WebSocket("ws://localhost:8000")

  # socket.addEventListener "message", onMessage, false

  start = (isCaller) ->

    peerConn = new webkitRTCPeerConnection( iceServers: [url: "stun:stun.l.google.com:19302"] )

    console.log peerConn

    peerConn.onicecandidate = (event) ->
      # console.log "new ice candidate: "
      # console.log event.candidate
      signalingChannel.send JSON.stringify( {"candidate": event.candidate} )

    peerConn.onaddstream = (event) ->
      console.log "stream added"
      console.log event
      remoteView.src = URL.createObjectURL event.stream

    navigator.webkitGetUserMedia
      audio: true
      video: true
    , (stream) ->
      gotDescription = (desc) ->
        peerConn.setLocalDescription desc
        signalingChannel.send JSON.stringify(sdp: desc)
      selfView.autoplay = true
      selfView.src = URL.createObjectURL(stream)
      
      peerConn.addStream stream

      if isCaller
        peerConn.createOffer gotDescription
      else
        peerConn.createAnswer peerConn.remoteDescription, gotDescription

  signalingChannel.onmessage = ( event ) ->
    console.log event
    if !peerConn
      start false
    
    signal = JSON.parse event.data
    if signal.sdp
      peerConn.setRemoteDescription new RTCSessionDescription(signal.sdp)
    else
      peerConn.addIceCandidate new RTCIceCandidate(signal.candidate)

  $scope.release = ->
    start( true )

###
  startVideo()



  startVideo = ->
    # Replace the source of the video element with the stream from the camera
    #try it with spec syntax
    onSuccess = (stream) ->
      video = document.getElementById("sourcevid")
      videoSource = undefined
      if window.webkitURL
        videoSource = window.webkitURL.createObjectURL(stream)
      else
        videoSource = stream
      
      localStream = stream

      console.log localStream

      video.autoplay = true;
      video.src = videoSource;

      console.log localStream

    onError = (error) ->
      console.log "An error occurred: [CODE " + error.code + "]"
    try
      navigator.getUserMedia or (navigator.getUserMedia = navigator.mozGetUserMedia or navigator.webkitGetUserMedia or navigator.msGetUserMedia)
      if navigator.getUserMedia
        navigator.getUserMedia
          video: true
          audio: true
        , onSuccess, onError
      else
        alert "getUserMedia is not supported in this browser."
    catch e
      navigator.webkitGetUserMedia "video,audio", successCallback, errorCallback
  stopVideo = ->
    sourcevid.src = ""








  # when PeerConn is created, send setup data to peer via WebSocket
  onSignal = (message) ->
    console.log "Sending setup signal"
    socket.send message

  # when remote adds a stream, hand it on to the local video element
  onRemoteStreamAdded = (event) ->
    console.log "Added remote stream"
    remotevid.src = window.webkitURL.createObjectURL(event.stream)

  # when remote removes a stream, remove it from the local video element
  onRemoteStreamRemoved = (event) ->
    console.log "Remove remote stream"
    remotevid.src = ""

  createPeerConnection = ->
    
    try
      console.log "Creating peer connection"
      peerConn = new webkitDeprecatedPeerConnection("STUN stun.l.google.com:19302")
    catch e
      try
        peerConn = new RTCPeerConnection(iceServers: [url: "stun:stun.l.google.com:19302"])
      catch e
        console.log "Failed to create PeerConnection, exception: " + e.message
    peerConn.addEventListener "addstream", onRemoteStreamAdded, false
    peerConn.addEventListener "removestream", onRemoteStreamRemoved, false
    
    peerConn = new RTCPeerConnection(iceServers: [url: "stun:stun.1.google.com:19302"])

  # start the connection upon user request
  connect = ->
    if not started and localStream
      createPeerConnection()
      console.log "Adding local stream..."
      peerConn.addStream localStream
      started = true
    else
      alert "Local stream not running yet."

  # accept connection request
  onMessage = (evt) ->
    console.log "RECEIVED: " + evt.data
    unless started
      createPeerConnection()
      console.log "Adding local stream..."
      peerConn.addStream localStream
      started = true

    # Message returned from other side
    console.log "Processing signaling message..."
    peerConn.processSignalingMessage evt.data
  hangUp = ->
    console.log "Hang up."
    peerConn.close()
    peerConn = null
    started = false

  onSuccess = (stream) ->
    video = document.getElementById("webcam")
    videoSource = undefined
    if window.webkitURL
      videoSource = window.webkitURL.createObjectURL(stream)
    else
      videoSource = stream
    # here we have the stream
  onError = ->
    alert "There has been a problem retrieving the streams - did you allow access?"
  navigator.getUserMedia or (navigator.getUserMedia = navigator.mozGetUserMedia or navigator.webkitGetUserMedia or navigator.msGetUserMedia)
  if navigator.getUserMedia
    navigator.getUserMedia
      video: true
      audio: true
    , onSuccess, onError
  else
    alert "getUserMedia is not supported in this browser."
  ###

@ControlCtrl = ($scope) ->
  console.log "coontrol here."

