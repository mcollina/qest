
env = require("../app.coffee")
env.configure()

beforeEach ->
  env.setupRedis(host: "127.0.0.1", port: 6379, db: 16)
  @app = env.app
  @models = env.app.models

  @app.redis.client.flushdb()

afterEach ->
  @app.redis.client.end()
  @app.redis.pubsub.unsubscribe()
  @app.redis.pubsub.end()
