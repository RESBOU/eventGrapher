require! {
  ribcage
  leshdash: { mapValues, each, assign }
  bluebird: p
}

env = {}

settings = do
  module:
    express4:
      port: 3001
      configure: ->
        it.set 'x-powered-by', false

env.settings = assign settings, require './settings'


initRibcage = -> new p (resolve,reject) ~> 
  ribcage.init env, (err, modules) ->
    console.log err, env.settings
    if err then return reject err
    else resolve modules

initRibcage()
.then -> new p (resolve,reject) ~>
  console.log "DONE"
  resolve!
