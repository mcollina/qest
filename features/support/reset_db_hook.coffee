
module.exports = () ->
  @Before (done) ->
    @app.models.Data.reset?()
    @app.redis.client.flushdb =>
      done()
