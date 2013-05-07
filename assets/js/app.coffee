"use strict"

# Declare app level module which depends on filters, and services

@app = angular.module("WebCar", ["WebCar.filters", "WebCar.services", "WebCar.directives", "ui.bootstrap.dialog"])
	.config ["$routeProvider", "$locationProvider", "$dialogProvider", ($routeProvider, $locationProvider, $dialogProvider) ->
		
    $routeProvider.when "/",
        templateUrl: "/index"
        controller: AppCtrl

    $routeProvider.when "partials/login"
    	templateUrl: "partials/login"
    	# controller: DialogCtrl

    $routeProvider.otherwise redirectTo: "/"
    $locationProvider.html5Mode true
    
]
