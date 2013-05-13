"use strict"

# Declare app level module which depends on filters, and services

@app = angular.module("WebCar", ["WebCar.filters", "WebCar.services", "WebCar.directives", "ui.bootstrap.dialog"])
	.config ["$routeProvider", "$locationProvider", "$dialogProvider", ($routeProvider, $locationProvider, $dialogProvider) ->
		
    $routeProvider.when "/",
      templateUrl: "/partials/index"
      controller: AppCtrl      

    $routeProvider.when "/settings",
      templateUrl: "/partials/settings"
      controller: AppCtrl

    $routeProvider.when "partials/login"
    	templateUrl: "partials/login"
    	# controller: DialogCtrl

    $routeProvider.when "partials/signup"
      templateUrl: "partials/signup"

    $routeProvider.otherwise redirectTo: "/"
    $locationProvider.html5Mode true
    
]
