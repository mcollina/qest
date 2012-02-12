
env = require("../mqtt-rest.coffee")

module.exports.globalSetup = ->
  return if @app?
  @app = env.app
  env.setupRedis(host: "127.0.0.1", port: 6379, db: 16)
  env.configure()

module.exports.globalTearDown = ->
  @app.redis.client.end()
  @app.redis.pubsub.end()

module.exports.setup = (done) ->
  @app.models.Data.reset?()
  @app.redis.client.flushdb =>
    done()
