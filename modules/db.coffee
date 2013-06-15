debug    = require "./debug"

config   = require "../config"

mongoose = require "mongoose"
ObjectID = require("mongodb").ObjectID

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

exports.Users = mongoose.model "userauths", LocalUserSchema

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

exports.FbUsers = mongoose.model "fbauths", FacebookUserSchema

CarSchema = new mongoose.Schema
    user:           String
    hash:           String
    salt:           String
    urlHash:        String
    isDriven:       Boolean

exports.Cars = mongoose.model "cars", CarSchema
exports.ObjectID = ObjectID
exports.connection = mongoose.connection.db