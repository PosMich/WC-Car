###
    Requires
###
config    = require "./config"

coffee    = require "coffee-script"
express   = require "express"
assets    = require "connect-assets"
path      = require "path"
http      = require "http"

passport  = require "passport"
FacebookStrategy = require("passport-facebook").Strategy
LocalStrategy = require("passport-local").Strategy
var pass = require "pwd"

WebSocketServer = require("ws").Server
sqlite3   = require("sqlite3").verbose()


User = (name, fb, slt, h, mail, pic) ->
    username: name || ""
    fbId:     fb   || ""    #fb only
    salt:     slt  || ""    #pw only
    hash:     h    || ""
    email:    mail || ""
    avatar:   pic  || ""

###
    DB STUFF
###

initDatabase = (cb) ->
    console.log "create"
    db.run "
CREATE TABLE IF NOT EXISTS users (
username TEXT,
fbId TEXT,
salt TEXT,
hash TEXT,
email TEXT,
avatar TEXT)
"

insertUser = (user, cb)->
    db.run "INSERT INTO Users(?name, ?fbId, ?salt, ?hash, ?email, ?avatar)",
        $name: user.username
        $fbId: user.fbId
        $salt: user.salt
        $hash: user.hash
        $email: user.email
        $avatar: user.avatar
    , cb()

getUserData = (id, cb) ->
    return if id is undefined
    db.run "SELECT * FROM users WHERE id=?", id, cb()

getUserByEMail = (email, cb) ->
    return if email is undefined
    db.run "SELECT * FROM users WHERE email=?", email, cb()

getUserByName = (name, cb) ->
    return if name is undefined
    db.run "SELECT * FROM users WHERE name=?", name, cb()

getFbUserData = (id, cb) ->
    return if id is undefined
    db.run "SELECT * FROM users WHERE fbId=?", id, cb()


db = new sqlite3.Database "./db/development.sqlite" #, initDatabase

###
    Passport: Local Strategy
###
passport.use new LocalStrategy((username, password, cb) ->
    user = getUserByName(username)

    #can't find user, return
    if user is undefined
        cb null, false,
            message: "Wrong Username"

    #check password
    hash passwort, user.salt, (err, hash) ->
        return cb(err) if err
        return cb(null, user) if hash is user.hash
        cb null, false,
            message: "Wrong Password!"
)

###
    Passport: Facebook Strategy
###
passport.use new FacebookStrategy(
    clientID: config.fb.appId
    clientSecret: config.fb.appSecret
    callbackURL: "http://localhost:8000/auth/facebook/callback"
, (accessToken, refreshToken, profile, cb) ->
    user = getFbUserData profile.id

    #if user exists, return it
    cb( null, user ) if user is not undefined

    #if user doesn't exist, create new one
    user = new User(profile.displayName, profile.id, "", "", profile.emails[0].value, profile.photos[0].value)
    insertUser user, (err) ->
        cb null, false,
            message: "Wasn't able to create User"

    cb null, user
)

passport.serializeUser (user, done) ->
  done null, user.id

passport.deserializeUser (id, done) ->
  User.findById id, (err, user) ->
    done err, user



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
    app.use assets()
    app.use passport.initialize()
    app.use passport.session()
    app.use express.cookieParser(config.cookieSecret)
    app.use express.session(config.secret)
    app.use app.router
    app.use express.static(path.join(__dirname, "public"))

###
    Define routes
###
app.get "/", (req, res) ->
    console.log req.user
    res.render "layout"

app.get "/login", (req, res) ->
    res.render "login"

# All partials. This is used by Angular.
app.get "/partials/:name", (req, res) ->
    name = req.params.name
    res.render "partials/" + name

app.get "/auth/facebook", passport.authenticate("facebook")

app.get "/auth/facebook/callback", passport.authenticate("facebook",
  successRedirect: "/"
  failureRedirect: "/login"
)

app.post "/login", passport.authenticate("local",
  successRedirect: "/"
  failureRedirect: "/login"
  failureFlash: true
)

###
    Startup and log.
###
server = http.createServer(app).listen app.get("port"), ->
    console.log "Express server listening on port " + app.get("port")


wss = new WebSocketServer(server: server)
wss.on "connection", (ws) ->
  id = setInterval(->
    ws.send JSON.stringify(process.memoryUsage()), -> # ignore errors

  , 100)
  console.log "started client interval"
  ws.on "close", ->
    console.log "stopping client interval"
    clearInterval id
  ws.on "message", (msg) ->
    console.log 'received: %s', msg
