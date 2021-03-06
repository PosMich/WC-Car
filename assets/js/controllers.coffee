"use strict"

# Controllers
@AppCtrl = ($scope, $http, $window) ->

  $scope.release = ->
    $window.location.href = "/release"

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

@AnchorCtrl = ($scope, $window, $location, $anchorScroll) ->
  #console.log $location.url().substring(1)
  $scope.scrollTo = (id) ->
    if $location.url() is "/" or $location.url().charAt(1) is "#"
      $location.hash(id)
      $.smoothScroll
        scrollTarget: "#"+id
    else
      $window.location.href = "/#"+id

@DialogCtrl = ($scope, $dialog) ->

    $scope.openDialog = (pathToView, controller, additionalclass = "") ->

      if $scope.dialog
        $scope.dialog.close()

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

@LoginCtrl = ($scope, $dialog) ->
  if $scope.dialog
      $scope.dialog.close()
  $scope.opts =
  backdrop: true,
  keyboard: true,
  backdropClick: true,
  dialogFade: true,
  scroll: true,
  dialogClass: "modal ",
  templateUrl: "partials/login",
  controller: "LogInCtrl"

  d = $dialog.dialog $scope.opts

  d.open()


@LogInCtrl = ($scope, $window, dialog, $http) ->
  $scope.facebook = ->
    $window.location.href = "/auth/facebook"
  $scope.update = (user, method = 'webcar') ->
    if $scope.login.$valid
      userdata = $.param(
        name: user.name
        password: user.password
      )

      $http(
        method: "POST"
        url: "/login"
        data: userdata
        headers:
          "Content-Type": "application/x-www-form-urlencoded"
      ).success (response) ->
        console.log response
        dialog.close()
        $window.location.href = "/login"


  $scope.close = (user) ->
    dialog.close()

  $scope.signup = () ->
    dialog.close()
    $window.location.href = "/signup"

  $scope.close

@SignUpCtrl = ($scope, $http, $window) ->

  $scope.update = (user) ->
    if $scope.signup.$valid
      userdata = $.param(
        name: user.name
        password: user.password
        email: user.email
        avatar: user.avatar
      )

      $http(
        method: "POST"
        url: "/signup"
        data: userdata
        headers:
          "Content-Type": "application/x-www-form-urlencoded"
      ).success (response) ->
        $window.location.href = "/"


  $scope.close = () ->
    $window.location.href = "/"

@SettingsCtrl = ($rootScope, $scope, $http, $window) ->

  $scope.master = []
  $scope.user = []

  $http(
    method: "GET"
    url: "/settings"
  ).success (response) ->
    $scope.user.name = response.name
    $scope.user.email = response.email
    $scope.user.avatar = response.avatar
    $scope.master.name = response.name
    $scope.master.email = response.email
    $scope.master.avatar = response.avatar
    $scope.old_password = response.password


  $scope.update = (user) ->

    if $scope.settings.$valid && !$scope.isUnchanged()

      console.log "asdf"

      userdata = $.param(
        name: $scope.user.name
        email: $scope.user.email
        avatar: $scope.user.avatar
        old_password: $scope.old_password
        password: $scope.user.password
      )

      console.log userdata

      $http(
        method: "POST"
        url: "/settings"
        data: userdata
        headers:
          "Content-Type": "application/x-www-form-urlencoded"
      ).success (response) ->
        console.log "success."
        $window.location.href = "/settings"

      # $scope.master = user

  $scope.reset = ->
    $scope.user.name = $scope.master.name
    $scope.user.email = $scope.master.email
    $scope.user.avatar = $scope.master.avatar
    $scope.user.old_password = ""
    $scope.user.password = ""
    $scope.user.password_repeat = ""

  $scope.isUnchanged = () ->

    unchanged = true

    unchanged = false if $scope.user.name != $scope.master.name
    unchanged = false if $scope.user.email != $scope.master.email
    unchanged = false if $scope.user.avatar != $scope.master.avatar

    unchanged = false if $scope.user.old_password != undefined and $scope.user.old_password != ""
    unchanged = false if $scope.user.password != undefined and $scope.user.password != ""
    unchanged = false if $scope.user.password_repeat != undefined and $scope.user.password_repeat != ""

    return unchanged


# WebRTC stuff here.
###
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

@LogoutCtrl = ($scope, $window) ->
  $scope.logout = -> $window.location.href = "/logout"
