require! {
  ribcage
  leshdash: { mapValues, each, assign }
  bluebird: p
  
  express  
  ejs
  'body-parser'
}

env = {}

settings = do
  module:
    express4:
      port: 3002
      configure: ->
        it.set 'x-powered-by', false
        it.use bodyParser.json()
        it.use express.static __dirname + '/static', do
          etag: true
          dotfiles: 'ignore'
        
        it.set 'view engine', 'ejs'
        it.set 'views', __dirname + '/views'

env.settings = assign settings, require './settings'

initRibcage = -> new p (resolve,reject) ~> 
  ribcage.init env, (err, modules) ->
    if err then return reject err
    else resolve modules

initAPI = -> new p (resolve,reject) ~>    
  env.app.use (err, req, res, next) ~>
    res.status(500).send util.inspect(err)
    throw err
      
  env.app.post '/add', (req,res) -> 
    console.log req.body
    res.end "ok"
    
  resolve!

initRoutes = -> new p (resolve,reject) ~>
  env.app.get '/view', (req,res) ->
    res.end "ok"


initRibcage()
.then initAPI
.then -> new p (resolve,reject) ~>
  env.log 'running', {}, 'init', 'ok'
  resolve!
