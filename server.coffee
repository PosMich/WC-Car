coffee    = require "coffee-script"

config    = require "./config"
debug     = require "./modules/debug"

path      = require "path"
http      = require "http"

express   = require "express"
assets    = require "connect-assets"
flash     = require "connect-flash"
device    = require "express-device"

MongoStore = require("connect-mongo")(express)
db         = require "./modules/db"

routes     = require "./modules/routes"
signaler   = require "./modules/signaling"

auth       = require "./modules/auth"

passport   = require "passport"

i18n       = require "i18next"

i18n.init
    saveMissing: true
    debug: true
    lng: "de"

###
    Declare & Configure the Server
###
app  = express()

app.configure ->
    app.set "port", process.env.PORT or config.port
    app.set "views", __dirname + "/views"
    app.set "view engine", "jade"
    app.set "view options",
        layout: false
    app.use express.favicon('public/images/favicon.ico')
    app.use express.logger("dev")
    app.use express.bodyParser()
    app.use i18n.handle
    app.use express.methodOverride()
    app.use express.cookieParser(config.cookieSecret)
    app.use express.session(
        secret:config.secret
        maxAge: new Date(Date.now() + 3600000)
        originalMaxAge: new Date(Date.now() + 3600000)
        expires: new Date(Date.now() + 3600000)
        store: new MongoStore(
            db: db.connection
        , (err) ->
            console.log err or "session to mongo connection established"
        )
    )
    app.use assets()
    app.use flash()
    app.use passport.initialize()
    app.use passport.session()
    app.use express.static(path.join(__dirname, "public"))
    app.use express.methodOverride()
    app.use device.capture()
    app.enableDeviceHelpers()
    app.use app.router

    app.use express.errorHandler
        dumpExceptions: true
        showStack: true

i18n.registerAppHelper app

###
    Error routes
###
# Error Handling
app.use (req, res, next) ->
    res.status 404
    if req.accepts("html")
        debug.error "File not found, render '404'"
        res.render "404",
            url: req.url
        return
    if req.accepts("json")
        debug.error "File not found, render '404 json'"
        res.send error: "Not found"
        return
    res.type("txt").send "Not found"

app.use (err, req, res, next) ->
    res.status err.status or 500
    debug.error "Internal Server Error, render '500'"
    res.render "500",
        error: err

# Helpers

authenticatedOrNot = (req, res, next) ->
    if req.isAuthenticated()
        debug.infoSuccess "user is authenticated "+req.user
        next()
    else
        debug.infoFail "user is not  authenticated "+req.user
        debug.info "redirecting to '/login'"
        res.redirect "/login"

userExist = (req, res, next) ->
    Users.count
        name: req.body.name
    , (err, count) ->
        if count is 0
            debug.infoSuccess "no User found!"
            next()
        else
            debug.infoFail "User exists!"
            res.redirect "/signup"

###
there's a particular need for random links in random files, here's our random link
    http://www.jmanzano.es/blog/?p=603
###


###
    Routes
###
# home path
app.get "/", routes.home

app.post "/login", passport.authenticate("local",
    successRedirect: "/choose"
    failureRedirect: "/login"
), routes.login

app.post "/signup", userExist, routes.signup

# facebook auth and callback
app.get "/auth/facebook", passport.authenticate("facebook",
    scope: "email"
), routes.facebook
app.get "/auth/facebook/callback", passport.authenticate("facebook",
    failureRedirect: "/login"
), routes.facebookcb

# settings -> post update, -> get /get
app.post "/settings", authenticatedOrNot, routes.settings.post
app.get "/settings", authenticatedOrNot, routes.settings.get

# logout
app.get "/logout", routes.logout.get
app.post "/logout", routes.logout.post

# All partials. This is used by Angular.
app.get "/partials/:name", routes.partials

# controls
app.get "/control/key", routes.control.key
app.get "/control/key2", routes.control.key2
app.get "/control/gyro", routes.control.gyro
app.get "/control/joystick", routes.control.joystick

app.get "/release", authenticatedOrNot, routes.release
app.get "/release2", authenticatedOrNot, routes.release2
app.get "/choose", authenticatedOrNot, routes.choose

# register Car, create Url ....
app.post "/registerCar", authenticatedOrNot, routes.registerCar
app.get "/drive/:id", routes.drive

app.post "/kill", authenticatedOrNot, routes.kill.post
app.get "/kill", authenticatedOrNot, routes.kill.get

app.get "*", routes.default

###
    Startup and log.
###
server = http.createServer(app).listen app.get("port"), ->
    debug.info "Express server is listening on port "+app.get("port")

signaler.signaling server
