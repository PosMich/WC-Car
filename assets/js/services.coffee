"use strict"
angular.module("WebCar.services", []).factory "ConnectionService", ->
  isConnected = false
  connection = undefined
  handle: ->
    unless isConnected
      connection = new WebSocket("ws://localhost:8000")
      isConnected = true
    connection
