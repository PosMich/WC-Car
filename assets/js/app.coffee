"use strict"

# Declare app level module which depends on filters, and services

@app = angular.module("WebCar", ["WebCar.filters", "WebCar.services", "WebCar.directives", "ui.bootstrap.dialog"])
	.config ["$routeProvider", "$locationProvider", "$dialogProvider", ($routeProvider, $locationProvider, $dialogProvider) ->
		
    $routeProvider.when "/view1",
        templateUrl: "partials/view1"
        controller: MyCtrl1

    $routeProvider.when "/view2",
        templateUrl: "partials/view2"
        controller: MyCtrl2

    $routeProvider.when "partials/login"
    	templateUrl: "partials/login"
    	# controller: DialogCtrl

    $routeProvider.otherwise redirectTo: "/view1"
    $locationProvider.html5Mode true
    
]
