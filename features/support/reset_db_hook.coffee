
module.exports = () ->
  console.log "imported resed db hook"
  @Before (done) ->
    console.log "resetting the db"
    @app.models.Data.reset?()
    @app.redis.client.flushdb =>
      done()
