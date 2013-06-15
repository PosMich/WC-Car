###
    Requires
###

coffee    = require "coffee-script"

config    = require "./config"
debug     = require "./modules/debug"
sty       = require "sty"

path      = require "path"
http      = require "http"

express   = require "express"
assets    = require "connect-assets"
flash     = require "connect-flash"
device    = require "express-device"

crypto    = require "crypto"
sha       = crypto.createHash("sha1")
tinyUrl   = require("nj-tinyurl").shorten

MongoStore = require("connect-mongo")(express)
mongoose  = require "mongoose"
ObjectID  = require("mongodb").ObjectID

passport         = require "passport"
FacebookStrategy = require("passport-facebook").Strategy
LocalStrategy    = require("passport-local").Strategy
hash             = require("./modules/pass").hash

routes    = require "./modules/routes"
signaler  = require "./modules/signaling"

###
    DB Stuff
###
debug.info "Connect to: "+config.mongo.url+":"+config.mongo.port+" database: "+config.mongo.database+" user: "+config.mongo.user+" and pw "+config.mongo.pwd

# mongoose.connect "mongodb://"+config.mongo.url+":"+config.mongo.port+"/"+config.mongo.database,
mongoose.connect config.mongo.url+"/"+config.mongo.database, config.mongo.port, config.mongo.database,
    user: config.mongo.user
    pass: config.mongo.pwd
, (err) ->
    if err then debug.error err
    else debug.infoSuccess "Connected to MongoDB"


# Validators
validateLength = ( val ) ->
    debug.info "validate length"
    return ( val.length > config.mongo.validate.pwlength )

validateEmail = ( val ) ->
    debug.info "validate e-mail"
    return /[a-z0-9!#$%&'*+\/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+\/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?/i.test val

validateUrl = ( val ) ->
    debug.info "validate url"
    return 1 if val.length is 0
    return /\b((?:[a-z][\w-]+:(?:\/{1,3}|[a-z0-9%])|www\d{0,3}[.]|[a-z0-9.\-]+[.][a-z]{2,4}\/)(?:[^\s()<>]+|\(([^\s()<>]+|(\([^\s()<>]+\)))*\))+(?:\(([^\s()<>]+|(\([^\s()<>]+\)))*\)|[^\s`!()\[\]{};:'".,<>?«»“”‘’]))/i.test val


# Local Users Schema
LocalUserSchema = new mongoose.Schema
    name:
        type:       String
        validate:   [validateLength, 'Username is too short']
        required:   true
    email:
        type:       String
        lowercase:  true
        validate:   [validateEmail, "Email is invalid."]
        required:   true
    avatar:
        type:       String
        validate:   [validateUrl, "Not a valid URL."]
    salt:           String
    hash:           String

Users = mongoose.model "userauths", LocalUserSchema

# Facebook Users Schema
FacebookUserSchema = new mongoose.Schema
    fbId:           String
    email:
        type:       String
        lowercase:  true
    name:
        type:       String
        required:   true
        validate:   [validateLength, 'Username is too short']
    avatar:
        type:       String
        validate:   [validateUrl, "Not a valid URL."]

FbUsers = mongoose.model "fbauths", FacebookUserSchema

CarSchema = new mongoose.Schema
    user:           String
    hash:           String
    salt:           String
    urlHash:        String
    isDriven:       Boolean

Cars = mongoose.model "cars", CarSchema


###
    passport stuff
###

validatePassword = (username, password, done) ->
    Users.findOne
        name: username
    , (err, user) ->
        if err
            debug.error "Passport: error, was not able to find user "+user
            return done(err)
        unless user
            debug.infoFail "Passport: incorrect username "+username
            return done(null, false,
                message: "Incorrect username."
            )
        hash password, user.salt, (err, hash) ->
            if err
                debug.error "Passport: error while hashing"
                return done(err)
            if hash is user.hash
                debug.info "Passport: same password"
                return done(null, user)
            debug.infoFail "Passport: incorrect password"
            done null, false,
                message: "Incorrect password."


passport.use new LocalStrategy(
    usernameField: "name"
    validatePassword
)

passport.use new FacebookStrategy(
    clientID:      config.fb.appId
    clientSecret:  config.fb.appSecret
    callbackURL:   config.siteUrl+":"+config.port+"/auth/facebook/callback"
    profileFields: ["id", "displayName", "photos", "emails"]
, (accessToken, refreshToken, profile, done) ->
    FbUsers.findOne
        fbId: profile.id
    , (err, oldUser) ->
        if oldUser
            debug.infoSuccess "Passport: fb user exists, return "+oldUser
            done null, oldUser
        else
            newUser = new FbUsers(
                fbId: profile.id
                email: profile.emails[0].value
                name: profile.displayName
                avatar: profile.photos[0].value
            ).save((err, newUser) ->
                if err
                    debug.error "Passport: error while save fb user to db"
                    done err
                else
                    debug.infoSuccess "Passport: saved new fb user to db "+newUser
                    done null, newUser
            )
)

passport.serializeUser (user, done) ->
    debug.info "serialize user"
    done null, user.id

passport.deserializeUser (id, done) ->
    debug.info "deserialize user"
    FbUsers.findById id, (err, user) ->
        done err if err
        if user
            debug.infoSuccess "fbUser found"+user
            done null, user
        else
            Users.findById id, (err, user) ->
                if err
                    debug.infoFail "no user found!"
                    done err
                debug.infoSuccess "user found"+user
                done null, user


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
    app.use express.methodOverride()
    app.use express.cookieParser(config.cookieSecret)
    app.use express.session(
        secret:config.secret
        maxAge: new Date(Date.now() + 3600000)
        originalMaxAge: new Date(Date.now() + 3600000)
        expires: new Date(Date.now() + 3600000)
        store: new MongoStore(
            db: mongoose.connection.db
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

###
,
        store: new MongoStore(
            {db:mongoose.connection.db}, (err) ->
                if err
                    debug.error err
                else
                    debug.info 'mongodb session connection ok'
        )

###

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
http://www.jmanzano.es/blog/?p=603
###


###
    Routes
###

app.get "/", routes.home        # home path

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
