"use strict"

# Controllers
@AppCtrl = ($scope, $http) ->

  console.log($scope)

  $http(
    method: "GET"
    url: "/api/name"
  ).success((data, status, headers, config) ->
    $scope.name = data.name
  ).error (data, status, headers, config) ->
    $scope.name = "Error!"
##

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

@LogInCtrl = ($scope, dialog) ->

  $scope.update = (user) ->
    console.log dialog.close()
    console.log user
    dialog.close

  $scope.close = (user) ->
    dialog.close()

  $scope.close

@SignUpCtrl = ($scope, dialog) ->

  $scope.update = (user) ->
    console.log dialog.close()
    console.log user
    dialog.close

  $scope.close = (user) ->
    dialog.close()

  $scope.close

@SettingsCtrl = ($scope, dialog) ->

  $scope.update = (user) ->
    console.log dialog.close()
    console.log user
    dialog.close

  $scope.close = (user) ->
    dialog.close()

@ReleaseCtrl = ($scope) ->
  console.log "release here."

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
      peerConn = new webkitDeprecatedPeerConnection("STUN stun.l.google.com:19302", onSignal)
    catch e
      try
        peerConn = new webkitPeerConnection("STUN stun.l.google.com:19302", onSignal)
      catch e
        console.log "Failed to create PeerConnection, exception: " + e.message
    peerConn.addEventListener "addstream", onRemoteStreamAdded, false
    peerConn.addEventListener "removestream", onRemoteStreamRemoved, false

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
  startVideo = ->

    # Replace the source of the video element with the stream from the camera
    #try it with spec syntax
    successCallback = (stream) ->
      sourcevid.src = window.webkitURL.createObjectURL(stream)
      localStream = stream
    errorCallback = (error) ->
      console.error "An error occurred: [CODE " + error.code + "]"
    try
      navigator.webkitGetUserMedia
        audio: true
        video: true
      , successCallback, errorCallback
    catch e
      navigator.webkitGetUserMedia "video,audio", successCallback, errorCallback
  stopVideo = ->
    sourcevid.src = ""

  socket = new WebSocket("ws://localhost:1337/")

  console.log "socket created."

  sourcevid = document.getElementById("sourcevid")
  remotevid = document.getElementById("remotevid")
  localStream = null
  peerConn = null
  started = false

  socket.addEventListener "message", onMessage, false

  connect()

  ###
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

