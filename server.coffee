###
    Requires
###
express = require 'express'
assets  = require 'connect-assets'
path    = require 'path'
http    = require 'http'
coffee  = require 'coffee-script'

#i18n    = require 'i18next'

config  = require './config'

###
    Declare & Configure the Server
###
server  = express()

###
i18n.init {
    saveMissing: true,
    debug: true,
    preload: ['de','en'],
    ignoreRoutes: ['images/', 'public/', 'css/', 'js/'],
    detectLngFromPath: 0
    }
##,
    (t) ->
        i18n.addRoute '/',['de','en'], server, 'get', (req, res)-> 
            res.render "index"
        i18n.addRoute '/:lng/route.view1', ['de','en'], server, 'get', (req, res)-> 
            res.render "index"
        i18n.addRoute '/:lng/route.view2', ['de','en'], server, 'get', (req, res)-> 
            res.render "index"
        i18n.addRoute '/:lng/route.partials/:name', ['de','en'], server, 'get', (req, res)-> 
            name = req.params.name
            res.render "partials/" + name
        i18n.addRoute '/:lng/', ['de','en'], server, 'get', (req, res)-> 
            res.render "index"
###

server.configure ->
    server.set "port", process.env.PORT or config.port
    server.set "views", __dirname + "/views"
    server.set "view engine", "jade"
    server.set "view options",
        layout: false
    server.use express.favicon('public/images/favicon.ico')
    server.use express.logger("dev")
    server.use express.bodyParser()
    server.use express.methodOverride()
    server.use assets()
    server.use express.cookieParser(config.cookieSecret)
    server.use express.session()
    #server.use i18n.handle # i18n handler
    server.use server.router
    server.use express.static(path.join(__dirname, "public"))

###
i18n.registerAppHelper server
i18n.serveClientScript server
i18n.serveDynamicResources server
i18n.serveMissingKeyRoute server

i18n.serveWebTranslate(server, {
    i18nextWTOptions: {
      languages: ['de', 'en',  'dev'],
      resGetPath: "locales/resources.json?lng=__lng__&ns=__ns__",
      resChangePath: 'locales/change/__lng__/__ns__',
      resRemovePath: 'locales/remove/__lng__/__ns__',
      fallbackLng: "dev",
      dynamicLoad: true
    }
});
###

###
    Define routes
###
server.get "/", (req, res) ->
    res.render "layout"

# All partials. This is used by Angular.
server.get "/partials/:name", (req, res) ->
  name = req.params.name
  res.render "partials/" + name

# Views that are direct linkable
# server.get ["/view1", "/view2"], (req, res) ->
#  res.render "index"

###
    Startup and log.
###
http.createServer(server).listen server.get("port"), ->
    console.log "Express server listening on port " + server.get("port")