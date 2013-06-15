config           = require "../config"
debug            = require "./debug"

hash             = require("./pass").hash

db               = require "./db"

passport         = require "passport"
FacebookStrategy = require("passport-facebook").Strategy
LocalStrategy    = require("passport-local").Strategy
###
    passport stuff
###

validatePassword = (username, password, done) ->
    db.Users.findOne
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
    db.FbUsers.findOne
        fbId: profile.id
    , (err, oldUser) ->
        if oldUser
            debug.infoSuccess "Passport: fb user exists, return "+oldUser
            done null, oldUser
        else
            newUser = new db.FbUsers(
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
    db.FbUsers.findById id, (err, user) ->
        done err if err
        if user
            debug.infoSuccess "fbUser found"+user
            done null, user
        else
            db.Users.findById id, (err, user) ->
                if err
                    debug.infoFail "no user found!"
                    done err
                debug.infoSuccess "user found"+user
                done null, user

exports = passport