###
    Requires
###
coffee    = require "coffee-script"
express   = require "express"
assets    = require "connect-assets"
path      = require "path"
http      = require "http"
everyauth = require "everyauth"
config    = require "./config"
WebSocketServer = require("ws").Server


usersById = {}
nextUserId = 0

addUser = (source, sourceUser) ->
    user = undefined
    if arguments_.length is 1 # password-based
        user = sourceUser = source
        user.id = ++nextUserId
        return usersById[nextUserId] = user
    else # non-password-based
        user = usersById[++nextUserId] = id: nextUserId
        user[source] = sourceUser
        user

usersByFbId = {}

everyauth.facebook
  .appId(config.fb.appId)
  .appSecret(config.fb.appSecret)
  .findOrCreateUser((session, accessToken, accessTokenExtra, fbUserMetadata) ->
    usersByFbId[fbUserMetadata.id] or (usersByFbId[fbUserMetadata.id] = addUser("facebook", fbUserMetadata))
  ).redirectPath "/"

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
    app.use express.cookieParser(config.cookieSecret)
    app.use express.session(config.secret)
    app.use everyauth.middleware(app)
    app.use app.router
    app.use express.static(path.join(__dirname, "public"))

###
    Define routes
###
app.get "/", (req, res) ->
    console.log req.user
    res.render "home"

app.get "/login", (req, res) ->
    res.render "login"

# All partials. This is used by Angular.
app.get "/partials/:name", (req, res) ->
    name = req.params.name
    res.render "partials/" + name

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
