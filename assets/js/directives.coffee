"use strict"

# Directives 


# Register the 'myCurrentTime' directive factory method.
# We inject $timeout and dateFilter service since the factory method is DI.
angular.module("WebCar.directives", []).directive "sameAs", ->
  require: "ngModel"
  link: (scope, elm, attrs, ctrl) ->
    ctrl.$parsers.unshift (viewValue) ->

      if viewValue is scope.user.password
        ctrl.$setValidity "sameAs", true
        viewValue
      else
        ctrl.$setValidity "sameAs", false
        'undefined'