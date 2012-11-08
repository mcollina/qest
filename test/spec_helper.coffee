
env = require("../qest.coffee")
async = require("async")

config =
  host: "127.0.0.1"
  port: 6379
  db: 16

module.exports.globalSetup = ->
  return if @app?
  @app = env.app
  env.setup(config)
  env.configure()

module.exports.globalTearDown = ->
  @app.redis.client.end()

module.exports.setup = (done) ->
  env.setupAscoltatore(config)
  async.parallel([
    (cb) => @app.ascoltatore.once("ready", cb),
    (cb) => @app.redis.client.flushdb(cb)
  ], done)

module.exports.tearDown = (done) ->
  @app.ascoltatore.close(done)

