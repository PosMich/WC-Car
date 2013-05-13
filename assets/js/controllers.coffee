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

  $scope.close