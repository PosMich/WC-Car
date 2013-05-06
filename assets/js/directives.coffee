"use strict"

# Directives 

angular.module("WebCar.directives", [])
	.directive "appVersion", ["version", (version) ->
	  (scope, elm, attrs) ->
	    elm.text version
	]

