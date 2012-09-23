{ MqttClient } = require("./clients/mqtt")
{ HttpClient } = require("./clients/http")
{ HttpJsonClient } = require("./clients/http_json")
{ HttpTxtClient } = require("./clients/http_txt")

protocols = 
  HTTP: HttpClient
  HTTP_JSON: HttpJsonClient
  HTTP_TXT: HttpTxtClient
  MQTT: MqttClient

module.exports = ->
  console.log "imported clients helper"

  @Before (done) ->
    console.log "running before clients"

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
    console.log "running after clients"
    for name, client of @clients
      client.disconnect()

    @clients = {}

    done()

