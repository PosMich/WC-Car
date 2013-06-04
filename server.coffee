###
    Requires
###

config    = require "./config"

coffee    = require "coffee-script"

path      = require "path"
http      = require "http"
WebSocketServer = require("ws").Server

express   = require "express"
assets    = require "connect-assets"
flash     = require "connect-flash"

mongoose = require "mongoose"
ObjectID = require("mongodb").ObjectID

passport         = require "passport"
FacebookStrategy = require("passport-facebook").Strategy
LocalStrategy    = require("passport-local").Strategy
hash             = require("./pass").hash


###
    DB Stuff
###
console.log "Connect to: " + config.mongo.url + " database " + config.mongo.database + " with user " + config.mongo.user + " and pw " + config.mongo.user
mongoose.connect config.mongo.url, config.mongo.database,
    user: config.mongo.user
    pass: config.mongo.pwd


# Validators

validateLength = ( val ) ->
    return true
    # return (val.length > 5)

validateEmail = ( val ) ->
    return /[a-z0-9!#$%&'*+\/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+\/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?/i.test val

validateUrl = ( val ) ->
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


###
    passport stuff
###
passport.use new LocalStrategy(
    usernameField: "name"
    (username, password, done) ->
        Users.findOne
            name: username
        , (err, user) ->
            return done(err) if err
            unless user
                return done(null, false,
                    message: "Incorrect username."
                )
            hash password, user.salt, (err, hash) ->
                return done(err) if err
                return done(null, user) if hash is user.hash
                done null, false,
                    message: "Incorrect password."
)

passport.use new FacebookStrategy(
    clientID: config.fb.appId
    clientSecret: config.fb.appSecret
    callbackURL: config.siteUrl+":"+config.port+"/auth/facebook/callback"
    profileFields: ["id", "displayName", "photos", "emails"]
, (accessToken, refreshToken, profile, done) ->
    FbUsers.findOne
        fbId: profile.id
    , (err, oldUser) ->
        if oldUser
            done null, oldUser
        else
            newUser = new FbUsers(
                fbId: profile.id
                email: profile.emails[0].value
                name: profile.displayName
                avatar: profile.photos[0].value
            ).save((err, newUser) ->
                done err if err
                done null, newUser
            )
)

passport.serializeUser (user, done) ->
    done null, user.id

passport.deserializeUser (id, done) ->
    FbUsers.findById id, (err, user) ->
        done err if err
        if user
            done null, user
        else
            Users.findById id, (err, user) ->
                done err if err
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
        cookie:
            maxAge: 60000
    )
    app.use assets()
    app.use flash()
    app.use passport.initialize()
    app.use passport.session()
    app.use app.router
    app.use express.static(path.join(__dirname, "public"))


###
    Define routes
###
# Error Handling
app.use (req, res, next) ->
    res.status 404
    if req.accepts("html")
        res.render "404",
            url: req.url
        return
    if req.accepts("json")
        res.send error: "Not found"
        return
    res.type("txt").send "Not found"

app.use (err, req, res, next) ->
    res.status err.status or 500
    res.render "500",
        error: err

# Helpers

authenticatedOrNot = (req, res, next) ->
    if req.isAuthenticated()
        console.log "isAuthenticated"
        next()
    else
        console.log "isNotAuthenticated"
        console.log "*"+req.isAuthenticated()+"*"
        res.redirect "/login"

userExist = (req, res, next) ->
    Users.count
        name: req.body.name
    , (err, count) ->
        if count is 0
            next()
        else
            res.redirect "/signup"

###
http://www.jmanzano.es/blog/?p=603
###


###
Type of Messages:
    Alert
    Error
    Success
    Information
###


###
    Routes
###

# std path
app.get "/", (req, res) ->
    if req.isAuthenticated()
        req.flash("info", "Logged in!")
        res.render "layout",
            user: req.user
            message: req.flash("info")
    else
        req.flash("info", "You have to login!")
        res.render "layout",
            user: null
            message: req.flash("info")

# login -> post, perform authentication
app.post "/login", passport.authenticate("local",
    successRedirect: "/"
    failureRedirect: "/login"
)

# signup --> post check if user exist
app.post "/signup", userExist, (req, res, next) ->
    user = new Users()
    hash req.body.password, (err, salt, hash) ->
        throw err  if err
        user = new Users(
            name: req.body.name
            email: req.body.email
            avatar: req.body.avatar
            salt: salt
            hash: hash
            _id: new ObjectID
        ).save((err, newUser) ->
            throw err if err
            req.login newUser, (err) ->
                return next(err)  if err
                res.redirect "/"
        )

# facebook auth paths
app.get "/auth/facebook", passport.authenticate("facebook",
    scope: "email"
), (req, res) ->
    req.flas("info", "asdfasdf")
    res.render "layout",
        user: null
        message: req.flash("info")


app.get "/auth/facebook/callback", passport.authenticate("facebook",
    failureRedirect: "/login"
), (req, res) ->
    res.render "layout",
        user: req.user

# settings path
app.get "/settings", authenticatedOrNot, (req, res) ->
    res.format
        "application/json": ->
            console.log "json"
            res.send req.user
        "*/*": ->
            console.log "AAAA"

# logout
app.get "/logout", (req, res) ->
    req.logout()
    res.redirect "/"

app.post "/logout", (req, res) ->
    req.logout()
    res.redirect "/"

# All partials. This is used by Angular.
app.get "/partials/:name", (req, res) ->
    name = req.params.name
    res.render "partials/" + name


# controls
app.get "/control/key", (req, res) ->
    res.render "controls/key",
        control: "keyboard"

app.get "/control/key2", (req, res) ->
    res.render "controls/key2",
        control: "keyboard2"

app.get "/control/gyro", (req, res) ->
    res.render "controls/gyro",
        control: "gyro"


app.get "*", (req, res) ->
    res.render "layout",
        user: res.user

###
    Startup and log.
###
server = http.createServer(app).listen app.get("port"), ->
    console.log "Express server listening on port " + app.get("port")


###
    WebSocket stuff
###

wss = new WebSocketServer(server: server)
wss.on "connection", (ws) ->
  console.log "new connection"
  ws.on "close", ->
    console.log "connection closed"
  ws.on "message", (msg) ->
    console.log 'received: %s', msg
