debug   = require "./debug"
db      = require "./db"
hash    = require("./pass").hash

WebSocketServer = require("ws").Server

###
    WebSocket stuff

    type of messages:
        --> "login": from driver/car to server
            --> if msg.user is car
                --> check Cars for id, validate password
                    --> password correct: add to driver, enable signalling
            --> if msg.user is driver
        --> "offer": from driver to car
            --> if signalling enabled
                --> sent offer to car
            --> else
                --> kill connection
        --> "answer": from car to driver
            --> if signalling enabled
                --> send answer to driver
            --> else
                --> kill connection
        --> "candidate": from car to driver vice versa
            --> if signalling enabled
                --> exchange canditates
            --> else
                --> kill connection
        --> "bye": from car to driver vice versa
            --> don't know
###

exports.signaling = (server) ->
    wss = new WebSocketServer(server: server)
    wss.on "connection", (ws) ->

        debug.info "new ws connection"

        ws.on "message", (msg) ->
            debug.info 'ws received: '
            console.log msg

            try
                msg = JSON.parse msg

                switch msg.type
                    when "login"
                        throw "msg.user not defined!!!" if msg.user isnt "car" and msg.user isnt "driver"
                        db.Cars.findOne
                            urlHash: msg.carId
                        , (err, car) ->
                            debug.error "Error occured while searching for car: "+err if err
                            unless car
                                debug.error "car not in list!!!"
                                ws.send JSON.stringify(
                                    type: "error"
                                    msg: "Das Auto ist nicht freigegeben!"
                                )
                            else
                                #validate pw
                                hash msg.pw, car.salt, (err, hash) ->
                                    if err
                                        throw "error while hashing"
                                    else if hash is car.hash
                                        debug.info "same password"
                                        if msg.user is "car"
                                            debug.info "identified as car"
                                            ws.type = "car"
                                            ws.other = ""
                                            ws.carId = msg.carId
                                            ws.isDriven = false
                                            ws.send JSON.stringify(
                                                type: "success"
                                            )
                                        else
                                            debug.info "identified as driver"
                                            #driver
                                            ###
                                                search all ws.clients for ws.carId == urlHash
                                            ###
                                            for client of wss.clients
                                                client = wss.clients[client]
                                                if client.type is "car" and client.carId is msg.carId
                                                    debug.info "found car"
                                                    if client.isDriven
                                                        debug.error "car is occupied"
                                                        ws.send JSON.stringify(
                                                            type: "error"
                                                            msg: "Das Auto wird bereits gesteuert!"
                                                        )
                                                    else
                                                        debug.info "add driver to car"
                                                        client.isDriven = true
                                                        ws.other = client
                                                        ws.type = "driver"
                                                        client.other = ws
                                                        ws.send JSON.stringify(
                                                            type: "success"
                                                        )
                                            if ws.other is undefined
                                                debug.error "something went horribly wrong, car not found in socket clients"
                                                debug.error "clients:"
                                                #for client of wss.clients
                                                #    client = wss.clients[client]
                                                #    console.log client
                                                ws.send JSON.stringify(
                                                    type: "error"
                                                    msg: "Etwas sehr komisches ist passiert. Das Auto wurde nicht gefunden :("
                                                )
                                    else
                                        ws.send JSON.stringify({type: "error", msg: "Falsches Passwort"})
                    when "offer"
                        throw "wrong type!!! "+ws.type if ws.type isnt "driver"
                        ws.other.send JSON.stringify(msg)
                        debug.info "offer sent to car"
                    when "answer"
                        throw "wrong type!!! "+ws.type if ws.type isnt "car"
                        ws.other.send JSON.stringify(msg)
                    when "candidate"
                        throw "not logged in?" if ws.type isnt "car" and ws.type isnt "driver"
                        ws.other.send JSON.stringify(msg)
                    when "bye"
                        ws.close()
                    else
                        throw "wrong msg type: "+msg.type
            catch e
                debug.error e
                ws.close()

        ws.on "close", ->
            debug.info "ws connection closed: "+ws.type
            switch ws.type
                when "driver"
                    ws.other.send JSON.stringify({type:"bye"})
                    ws.other.isDriven = false
                    ws.other.other = undefined
                    debug.info "removed driver"
                when "car"
                    debug.info "car remove"
                    db.Cars.findOne
                        urlHash: ws.carId
                    , (err, car) ->
                        debug.error "Error occured while searching for car: "+err if err
                        unless car
                            debug.error "car not in list!!!"
                        else
                            debug.info "car found - removing it"
                            car.remove()
                            console.log "ws.other"
                            console.log ws.other
                            if ws.other != "" and ws.other != undefined
                                ws.other.close()
                                debug.info "driver closed"
                else
                    debug.error "unknown ws.type removed"