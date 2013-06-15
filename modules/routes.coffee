sty       = require "sty"
debug     = require "./debug"
config    = require "../config"
hash      = require("./pass").hash

tinyUrl   = require("nj-tinyurl").shorten
db        = require "./db"

crypto    = require "crypto"
sha       = crypto.createHash("sha1")
###
    Routes
###

# index
exports.home = (req, res) ->
    debug.info ".get #{sty.magenta '/'} from "+req.user
    debug.info " User isauth: "+req.isAuthenticated()
    if req.isAuthenticated()
        debug.info "redirect to /choose"
        res.redirect "/choose"
    else
        debug.info "not authenticated, render layout - index"
        res.render "layout",
            user: null

# login -> post, perform authentication
exports.login = (req, res, next) ->
    debug.info ".post #{sty.magenta '/login'}"
    next()

# signup --> post check if user exist
exports.signup = (req, res, next) ->
    debug.info ".post #{sty.magenta '/signup'} from "+req.user
    debug.info "post body: "
    console.log req.body
    user = new Users()

    if req.body.password.length > config.mongo.validate.pwlength
        debug.info "password length > "+config.mongo.validate.pwlength
        hash req.body.password, (err, salt, hash) ->
            throw err  if err
            user = new db.Users(
                name: req.body.name
                email: req.body.email
                avatar: req.body.avatar
                salt: salt
                hash: hash
                _id: new db.ObjectID
            ).save((err, newUser) ->
                throw err if err
                req.login newUser, (err) ->
                    return next(err) if err
                    debug.info "user created, redirecting to '/'"
                    res.redirect "/"
            )
    else
        debug.error "password too short"
        # error handling

# facebook auth paths
exports.facebook = (req, res) ->
    debug.info ".get #{sty.magenta '/auth/facebook'} from "+req.user
    debug.info "render layout"
    res.render "layout",
        user: null
#        message: req.flash("info")


exports.facebookcb = (req, res) ->
    debug.info ".get #{sty.magenta '/auth/facebook/callback'} from "+req.user
    debug.info "redirecting to '/'"
    res.redirect "/"

exports.settings = {}
# settings -> post update
exports.settings.post = (req, res) ->
    debug.info ".post #{sty.magenta '/settings'} from "+req.user
    debug.info "post body: "
    console.log req.body

    if req.user.fbId
        debug.warn "FbUser tried to change settings! He/she is a bad boy/girl: "+req.user
        return res.redirect "/"

    if req.body.old_password != "" and req.body.password != ""
        debug.info "passwords are not empty"
        validatePassword( req.body.name, req.body.old_password, ( err, user ) ->
            if req.body.password.length > config.mongo.validate.pwlength
                hash req.body.password, (err, salt, hash) ->
                    user.name   = req.body.name
                    user.email  = req.body.email
                    user.avatar = req.body.avatar
                    user.salt   = salt
                    user.hash   = hash
                    user.save (err) ->
                        # Error handling
                        debug.error "Error during user.save: "+err
            else
                debug.error "new password too short"
        )
    else
        debug.info "update settings except password"
        db.Users.findOne
            name: req.body.name
        , (err, user) ->
            throw err if err
            user.name = req.body.name
            user.email = req.body.email
            user.avatar = req.body.avatar
            user.save (err) ->
                debug.error "Error while updating user: "+err
    debug.info "redirecting to '/'"
    res.redirect "/"


# settings path
exports.settings.get = (req, res) ->
    debug.info ".get #{sty.magenta '/settings'} from "+req.user
    if req.user.fbId is null or req.user.fbId is undefined
        res.format
            "application/json": ->
                debug.info "send jsonp"
                res.jsonp req.user
            "text/html": ->
                debug.info "render layout"
                res.render "layout",
                    user: req.user
    else
        res.redirect "/"

exports.logout = {}
# logout
exports.logout.get = (req, res) ->
    debug.info ".get #{sty.magenta '/logout'} from "+req.user
    req.logout()
    debug.info "logged out, redirect to '/'"
    res.redirect "/"

exports.logout.post = (req, res) ->
    debug.info ".post #{sty.magenta '/logout'} from "+req.user
    req.logout()
    debug.info "logged out, redirect to '/'"
    res.redirect "/"

# All partials. This is used by Angular.
exports.partials = (req, res) ->
    debug.info ".get #{sty.magenta '/partials/:name'} from "+req.user
    name = req.params.name
    debug.info "partial: "+name
    if name is "choose"
        if req.isAuthenticated()
            debug.info "user is logged in, render partial 'choose'"
            res.render "partials/choose",
                user: req.user
        else
            debug.info "user is not logged in, render partial 'index'"
            res.render "partials/index",
    else
        debug.info "render partial "+name
        res.render "partials/" + name

exports.control = {}
# controls
exports.control.key = (req, res) ->
    debug.info ".get #{sty.magenta '/control/key'} from "+req.user
    debug.info "render controls/key"
    res.render "controls/key",
        control: "keyboard"
        user: req.user

exports.control.key2 = (req, res) ->
    debug.info ".get #{sty.magenta '/control/key2'} from "+req.user
    debug.info "render controls/key2"
    res.render "controls/key2",
        control: "keyboard2"
        user: req.user

exports.control.gyro = (req, res) ->
    debug.info ".get #{sty.magenta '/control/gyro'} from "+req.user
    debug.info "render controls/gyro"
    res.render "controls/gyro",
        control: "gyro"
        user: req.user

exports.control.joystick = (req, res) ->
    debug.info ".get #{sty.magenta '/control/joystick'} from "+req.user
    debug.info "render controls/joystick"
    res.render "controls/joystick",
        control: "joystick"
        user: req.user

exports.release = (req, res) ->
    debug.info ".get #{sty.magenta '/release'} from "+req.user
    debug.info "render release/index"
    res.render "release/index",
        user: req.user

exports.choose = (req, res) ->
    debug.info ".get #{sty.magenta '/choose'} from "+req.user
    debug.info "render release/index"
    res.render "layout",
        user: req.user

# register Car, create Url ....
exports.registerCar = (req, res) ->
    debug.info ".post #{sty.magenta '/registerCar'} from "+req.user
    # register Car to available Cars
    if req.body.password.length > config.mongo.validate.pwlength
        debug.info "password length > "+config.mongo.validate.pwlength
        try
            db.Cars.findOne
                user: req.user._id
            , (err, car) ->
                if err
                    debug.error "Error occured while searching for Car"
                    res.jsonp {tinyUrl: false, msg: "Error occured while searching for Car"}
                #if no car insert car into db
                unless car
                    debug.info "no car found, creating new one"

                    hash req.body.password, (err, salt, hash) ->
                        if err
                            debug.error "problem during hash/salt creation"
                        else
                            debug.info "tryin to create new car"
                            urlHash = crypto.createHmac("sha1", req.user._id.toString("base64")).update(config.secret).digest("hex")
                            debug.info "try to get tinyUrl"
                            try
                                tinyUrl config.siteUrl+":"+config.port+"/drive/"+urlHash, (err, url)->
                                    debug.error err if err
                                    debug.info "tinyUrl: "+url

                                    debug.info "tryin to create new car"
                                    car = new db.Cars(
                                        user: req.user._id
                                        salt: salt
                                        hash: hash
                                        urlHash: urlHash
                                        isDriven: false
                                        _id: new db.ObjectID
                                    ).save( (err, newCar) ->
                                        if err
                                            debug.error "wasn't able to save car!"
                                            debug.error err
                                            res.format
                                                "application/json": ->
                                                    res.jsonp {tinyUrl: false, "Konnte Auto nicht in die Datenbank speichern."}
                                        else
                                            res.format
                                                "application/json": ->
                                                    debug.info "send jsonp"
                                                    res.jsonp { tinyUrl: url , carId: newCar.urlHash }
                                    )


                            catch err
                                debug.error "while getting tinyUrl: "+err

                else
                    debug.info "car found "+car
                    res.jsonp {tinyUrl: false, msg: "Das Auto wurde bereits ein mal freigegeben!"}
        catch e
            console.log e
    else
        debug.info "pw too short"
        res.jsonp {tinyUrl: false, msg: "Das Passwort ist zu kurz!"}

exports.drive = (req, res) ->
    carId = req.params.id
    debug.info ".get #{sty.magenta '/drive/'}"+carId
    res.render "controls/index.jade",
        carId: carId

exports.kill = {}
exports.kill.post = (req, res) ->
    debug.info ".post #{sty.magenta '/kill'} pw:"+req.body.password
    console.log req.body
    db.Cars.findOne
        user: req.user._id
    , (err, car) ->
        debug.error "Error occured while searching for Car" if err
        unless car
            res.jsonp {sucess: false}
        else
            console.log car
            hash req.body.password, car.salt, (err, hash) ->
                if err
                    debug.error "Kill: error while hashing"
                    res.jsonp {success: false}
                else if hash is car.hash
                    debug.info "Kill: same password"
                    car.remove()
                    res.jsonp {success: true}
                else
                    debug.infoFail "Kill: incorrect password"
                    res.jsonp {success: false}

exports.kill.get = (req, res) ->
    debug.info ".get #{sty.magenta '/kill'}"
    db.Cars.findOne
        user: req.user._id
    , (err, car) ->
        debug.error "Error occured while searching for Car" if err
        unless car
            debug.infoFail "no car found"
            res.redirect "/release"
        else
            debug.infoSuccess "car found"
            res.render "release/kill.jade"

exports.default = (req, res) ->
    debug.info ".get #{sty.magenta '*'} from "+req.user
    if req.isAuthenticated()
        debug.info "user is logged in, redirect to '/choose'"
        res.redirect "/choose"
    else
        debug.info "user is not logged in, render 'layout'"
        res.render "layout",
            user:  res.user
