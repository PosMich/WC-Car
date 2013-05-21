"use strict"

# Filters

angular.module("WebCar.filters", [])
    .filter "interpolate", ["version", (version) ->
      (text) ->
        String(text).replace /\%VERSION\%/g, version
    ]
