###
Module dependencies.
###
crypto = require "crypto"

###
Bytesize.
###
len = 128

###
Iterations. ~300ms
###
iterations = 12000

###
Set length to `n`.

@param {Number} n
@api public
###
exports.length = (n) ->
    return len  if 0 is arguments.length
    len = n


###
Set iterations to `n`.

@param {Number} n
@api public
###
exports.iterations = (n) ->
    return iterations  if 0 is arguments.length
    iterations = n


###
Hashes a password with optional `salt`, otherwise
generate a salt for `pass` and invoke `fn(err, salt, hash)`.

@param {String} password to hash
@param {String} optional salt
@param {Function} callback
@api public
###
exports.hash = (pwd, salt, fn) ->
    if 3 is arguments.length
        return fn(new Error("password missing"))  unless pwd
        return fn(new Error("salt missing"))  unless salt
        crypto.pbkdf2 pwd, salt, iterations, len, (err, hash) ->
            fn err, (new Buffer(hash, "binary")).toString("base64")
    else
        fn = salt
        return fn(new Error("password missing"))  unless pwd
        crypto.randomBytes len, (err, salt) ->
            return fn(err)  if err
            salt = salt.toString("base64")
            crypto.pbkdf2 pwd, salt, iterations, len, (err, hash) ->
                return fn(err)  if err
                fn null, salt, (new Buffer(hash, "binary")).toString("base64")