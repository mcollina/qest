
module.exports = ->
  @After (done) ->
    for name, client of @clients
      client.disconnect()
    done()

