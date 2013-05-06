"use strict"

# Controllers 
@AppCtrl = ($scope, $http) ->
  $http(
    method: "GET"
    url: "/api/name"
  ).success((data, status, headers, config) ->
    $scope.name = data.name
  ).error (data, status, headers, config) ->
    $scope.name = "Error!"
##
@MyCtrl1 = ($scope, $http) ->
  $scope.name = "World"
MyCtrl1.$inject = ['$scope','$http']


@MyCtrl2 = ($scope, $http) ->
  $scope.name = "Bear"
MyCtrl2.$inject = ['$scope','$http']

@DialogDemoCtrl = ($scope, $dialog) ->
         
  $scope.opts =
      backdrop: true,
      keyboard: true,
      backdropClick: true,
      dialogFade: true,
      dialogClass: "modal dialogWidthFixed",
      templateUrl: "partials/login",
      controller: "TestDialogController"

    $scope.openDialog = -> 
      d = $dialog.dialog $scope.opts
      d.open().then (result) ->
        if result
          alert "dialog closed with result: " + result

    $scope.openMessageBox = -> 
      @title = "This is a message box"
      @msg = "This is the content of the message box"
      @btns = [
        result: "cancel"
        label: "Cancel"
      ,
        result: "ok"
        label: "OK"
        cssClass: "btn-primary"
      ]

      $dialog.messageBox(title, msg, btns).open().then() -> 
          alert "dialog closed with result: " + result

  # the dialog is injected in the specified controller
@TestDialogController = ($scope, dialog) ->
  $scope.close = (result) -> 
    dialog.close result
    ###
    d = $dialog.dialog(
      modalFade: false
      
      resolve:
        item: ->
          angular.copy item
      
    )
   d.open "views/partials/login", "EditItemController"
   


# note that the resolved item as well as the dialog are injected in the dialog's controller
app.controller "EditItemController", ["$scope", "dialog", "item", ($scope, dialog, item) ->
  $scope.item = item
  $scope.submit = ->
    dialog.close "ok"
]

@DialogDemoCtrl = ($scope, $dialog) ->
    # Inlined template for demo

    DialogDemoCtrl = ($scope, $dialog) ->
      

###