###
    Requires
###

coffee    = require "coffee-script"

config    = require "./config"
debug     = require "./debug"
sty       = require "sty"

path      = require "path"
http      = require "http"
WebSocketServer = require("ws").Server

express   = require "express"
assets    = require "connect-assets"
flash     = require "connect-flash"
device    = require "express-device"

crypto    = require "crypto"
sha       = crypto.createHash("sha1")
tinyUrl   = require("nj-tinyurl").shorten

mongoose  = require "mongoose"
ObjectID  = require("mongodb").ObjectID

passport         = require "passport"
FacebookStrategy = require("passport-facebook").Strategy
LocalStrategy    = require("passport-local").Strategy
hash             = require("./pass").hash

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
    Hash:         String
    Salt:         String
    urlHash:        String

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
        cookie:
            maxAge: 60000
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

# std path
app.get "/", (req, res) ->
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
app.post "/login", passport.authenticate("local",
    successRedirect: "/choose"
    failureRedirect: "/login"
), (req, res, next) ->
    debug.info ".post #{sty.magenta '/login'}"
    next()


# signup --> post check if user exist
app.post "/signup", userExist, (req, res, next) ->
    debug.info ".post #{sty.magenta '/signup'} from "+req.user
    debug.info "post body: "
    console.log req.body
    user = new Users()

    if req.body.password.length > config.mongo.validate.pwlength
        debug.info "password length > "+config.mongo.validate.pwlength
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
                    return next(err) if err
                    debug.info "user created, redirecting to '/'"
                    res.redirect "/"
            )
    else
        debug.error "password too short"
        # error handling

# settings -> post update
app.post "/settings", (req, res) ->
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
        Users.findOne
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



# facebook auth paths
app.get "/auth/facebook", passport.authenticate("facebook",
    scope: "email"
), (req, res) ->
    debug.info ".get #{sty.magenta '/auth/facebook'} from "+req.user
    debug.info "render layout"
    res.render "layout",
        user: null
#        message: req.flash("info")


app.get "/auth/facebook/callback", passport.authenticate("facebook",
    failureRedirect: "/login"
), (req, res) ->
    debug.info ".get #{sty.magenta '/auth/facebook/callback'} from "+req.user
    debug.info "redirecting to '/'"
    res.redirect "/"

# settings path
app.get "/settings", authenticatedOrNot, (req, res) ->
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

# logout
app.get "/logout", (req, res) ->
    debug.info ".get #{sty.magenta '/logout'} from "+req.user
    req.logout()
    debug.info "logged out, redirect to '/'"
    res.redirect "/"

app.post "/logout", (req, res) ->
    debug.info ".post #{sty.magenta '/logout'} from "+req.user
    req.logout()
    debug.info "logged out, redirect to '/'"
    res.redirect "/"

# All partials. This is used by Angular.
app.get "/partials/:name", (req, res) ->
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


# controls
app.get "/control/key", (req, res) ->
    debug.info ".get #{sty.magenta '/control/key'} from "+req.user
    debug.info "render controls/key"
    res.render "controls/key",
        control: "keyboard"
        user: req.user

app.get "/control/key2", (req, res) ->
    debug.info ".get #{sty.magenta '/control/key2'} from "+req.user
    debug.info "render controls/key2"
    res.render "controls/key2",
        control: "keyboard2"
        user: req.user

app.get "/control/gyro", (req, res) ->
    debug.info ".get #{sty.magenta '/control/gyro'} from "+req.user
    debug.info "render controls/gyro"
    res.render "controls/gyro",
        control: "gyro"
        user: req.user

app.get "/control/joystick", (req, res) ->
    debug.info ".get #{sty.magenta '/control/joystick'} from "+req.user
    debug.info "render controls/joystick"
    res.render "controls/joystick",
        control: "joystick"
        user: req.user

app.get "/release", authenticatedOrNot, (req, res) ->
    debug.info ".get #{sty.magenta '/release'} from "+req.user
    debug.info "render release/index"
    res.render "release/index",
        user: req.user

app.get "/choose", authenticatedOrNot,(req, res) ->
    debug.info ".get #{sty.magenta '/choose'} from "+req.user
    debug.info "render layout"
    res.render "layout",
        user: req.user

# register Car, create Url ....
app.post "/registerCar", authenticatedOrNot, (req, res) ->
    debug.info ".post #{sty.magenta '/registerCar'} from "+req.user
    # register Car to available Cars
    if req.body.password.length > config.mongo.validate.pwlength
        debug.info "password length > "+config.mongo.validate.pwlength
        hash req.body.password, (err, salt, hash) ->
            if err
                debug.error "error creating hash"
            urlHash = crypto.createHmac("sha1", req.user._id.toString("base64")).update(config.secret).digest("hex")

            debug.info "try to find car"
            Cars.findOne
                user: req.user._id
            , (err, car) ->
                if err
                    debug.error "Error occured while searching for Car"
                    res.jsonp null
                #if no car insert car into db
                unless car
                    debug.info "no car found, creating new one"

                    hash req.body.password, (err, salt, hash) ->
                        if err
                            debug.error "problem during hash/salt creation"
                        else
                            car = new Cars(
                                user: req.user._id
                                salt: salt
                                hash: hash
                                urlHash: urlHash
                                _id: new ObjectID
                            ).save( (err, newCar) ->
                                if err
                                    debug.error "wasn't able to save car!"
                                    debug.error err
                                    res.format
                                        "application/json": ->
                                            res.jsonp null
                                debug.info "try to get tinyUrl"
                                tinyUrl config.siteUrl+":"+config.port+"/drive/"+newCar.urlHash, (err, url)->
                                    debug.error err if err
                                    debug.info "tinyUrl: "+url
                                    res.format
                                        "application/json": ->
                                            debug.info "send jsonp"
                                            res.jsonp { tinyUrl: url }
                            )
                else
                    debug.info "car found "+car
                    res.jsonp null
    else
        debug.info "pw too short"
        res.jsonp null

app.get "/drive/:id", (req, res) ->
    carId = req.params.id
    debug.info ".get #{sty.magenta '/drive/'}"+carId
    switch req.device
        when "tablet"
            res.render "tablet.jade",
                carId: carId
        when "phone"
            res.render "phone.jade",
                carId: carId
        else
            res.render "default.jade",
                carId: carId

app.post "/kill", authenticatedOrNot, (req, res) ->
    debug.info ".post #{sty.magenta '/kill'} pw:"+req.body.password
    console.log req.body
    Cars.findOne
        user: req.user._id
    , (err, car) ->
        debug.error "Error occured while searching for Car" if err
        unless car
            res.jsonp null
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

app.get "/kill", authenticatedOrNot, (req, res) ->
    debug.info ".get #{sty.magenta '/kill'}"
    Cars.findOne
        user: req.user._id
    , (err, car) ->
        debug.error "Error occured while searching for Car" if err
        unless car
            debug.infoFail "no car found"
            res.redirect "/release"
        else
            debug.infoSuccess "car found"
            res.render "release/kill.jade"

app.get "*", (req, res) ->
    debug.info ".get #{sty.magenta '*'} from "+req.user
    if req.isAuthenticated()
        debug.info "user is logged in, redirect to '/choose'"
        res.redirect "/choose"
    else
        debug.info "user is not logged in, render 'layout'"
        res.render "layout",
            user:  res.user

###
    Startup and log.
###
server = http.createServer(app).listen app.get("port"), ->
    debug.info "Express server is listening on port "+app.get("port")

###
    WebSocket stuff
###

wss = new WebSocketServer(server: server)
console.log(wss);
wss.on "connection", (ws) ->
    console.log wss.clients
    debug.info "new ws connection"
    ws.on "close", ->
        debug.info "ws connection closed"
    ws.on "message", (msg) ->
        debug.info 'ws received: '+msg
