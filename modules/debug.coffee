###
    Debug Stuff
###
config = require "../config"
sty    = require "sty"

isDebugLvl = (lvl) ->
    return config.debug.level <= lvl

exports.error = (msg) ->
    return unless isDebugLvl( config.debug.levels.error )
    console.log "#{sty.bgwhite sty.black config.appName} #{sty.red sty.bold 'ERROR:'} "+msg

exports.warn = (msg) ->
    return unless isDebugLvl( config.debug.levels.warn )
    console.log "#{sty.bgwhite sty.black config.appName} #{sty.yellow 'WARNING:'} "+msg


exports.info = (msg) ->
    return unless isDebugLvl( config.debug.levels.info )
    console.log "#{sty.bgwhite sty.black config.appName} #{sty.cyan 'INFO:'} "+msg

exports.infoSuccess = (msg) ->
    return unless isDebugLvl( config.debug.levels.info )
    exports.info "#{sty.green 'SUCCESS: '}"+msg

exports.infoFail = (msg) ->
    return unless isDebugLvl( config.debug.levels.info )
    exports.info "#{sty.red 'FAIL: '}"+msg
