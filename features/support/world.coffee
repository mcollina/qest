env = require("../../qest.coffee")
zombie = require('zombie')

opts = 
  port: 9777
  mqtt: 9778
  redisHost: "127.0.0.1"
  redisPort: 6379
  redisDB: 16

app = env.start opts
browser = new zombie.Browser(site: "http://localhost:#{opts.port}")

exports.World = (callback) ->
  @browser = browser
  @opts = opts
  @app = app

  callback()

  @
