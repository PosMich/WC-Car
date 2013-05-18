"use strict"

# Controllers 
@AppCtrl = ($scope, $http) ->

  # $http(
  #   method: "GET"
  #   url: "/api/name"
  # ).success((data, status, headers, config) ->
  #   $scope.name = data.name
  # ).error (data, status, headers, config) ->
  #   $scope.name = "Error!"
##

@SettingsCtrl = ($scope) ->

  # request to server for available data

  conn = new WebSocket "wss://localhost:8000";
  console.log "request to server for available data"

  conn.onopen = ->
    $scope.user = conn.send JSON.stringify( {"got data from user xyz?"} )
    $scope.master = $scope.user

  $scope.update = (user) ->
    if $scope.settings.valid && $scope.isUnchanged user
      $scope.master = user
      conn.send JSON.stringify( {"type": 3, "name": user.name, "mail": user.mail, "password": user.password} )

  $scope.reset = ->
    $scope.user = $scope.master

  $scope.isUnchanged = (user) ->
    return angular.equals user, $scope.master


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

    if $scope.login.$valid
      conn = new WebSocket( "wss://localhost:8000" )

      console.log "trying to establish connection."

      conn.onopen = ->
        console.log "connection established"
        conn.send JSON.stringify( {"type": 0, "username": user.name, "password": user.password} )
        console.log "login data sent to server"
        conn.onmessage = (e) ->
          if e.authenticated
            dialog.close

  $scope.close = (user) ->
    dialog.close()
    $scope.user = {}

  # $scope.close

@SignUpCtrl = ($scope, dialog) ->

  $scope.user;

  $scope.update = (user) ->

    if $scope.signup.$valid
      conn = new WebSocket( "wss://localhost:8000" )
      conn.onopen = ->
        console.log "connection established"

        conn.send JSON.stringify( {"type": 1, "username": user.username, "password": user.pwd, "email": user.mail} )
        console.log "login data sent to server"
        conn.onmessage = (e) ->
          if e.authenticated
            dialog.close

  $scope.close = (user) ->
    dialog.close()
    $scope.user = {}

  # $scope.close