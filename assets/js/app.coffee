"use strict"

# Declare app level module which depends on filters, and services

@app = angular.module("WebCar", ["WebCar.filters", "WebCar.services", "WebCar.directives", "ui.bootstrap.dialog"])
	.config ["$routeProvider", "$locationProvider", "$dialogProvider", ($routeProvider, $locationProvider, $dialogProvider) ->
    $locationProvider.html5Mode true

    $routeProvider.when "/",
      templateUrl: "partials/index"
      controller: AppCtrl

    $routeProvider.when "/release",
      templateUrl: "partials/release"
      controller: ReleaseCtrl

    $routeProvider.when "/control",
      templateUrl: "partials/control"
      controller: ControlCtrl

    $routeProvider.when "/settings",
      templateUrl: "/partials/settings"
      controller: SettingsCtrl

    $routeProvider.when "partials/login",
      templateUrl: "partials/login"
      # controller: DialogCtrl

    $routeProvider.when "/signup",
      templateUrl: "/partials/signup"
      controller: SignUpCtrl

    $routeProvider.when "/logout",
      controller: LogoutCtrl
      templateUrl: "partials/index"

    $routeProvider.otherwise redirectTo: "/"

]