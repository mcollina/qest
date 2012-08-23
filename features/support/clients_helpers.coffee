{ MqttClient } = require("./clients/mqtt")
{ HttpClient } = require("./clients/http")

protocols = 
  HTTP: HttpClient
  MQTT: MqttClient

module.exports = ->
  @Before (done) ->

    @clients = {}
    @getClient = (protocol, name, callback) =>
      if @clients[name]?
        callback(@clients[name])
      else
        protocols[protocol].build @opts, (client) =>
          @clients[name] = client
          callback(client)
    
    done()

  @After (done) ->
    for name, client of @clients
      client.disconnect()

    @clients = {}

    done()

