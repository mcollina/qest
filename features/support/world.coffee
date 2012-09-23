env = require("../../qest.coffee")
zombie = require('zombie')

opts = 
  port: 9777
  mqtt: 9778
  redisHost: "127.0.0.1"
  redisPort: 6379
  redisDB: 16

app = env.start opts
browser = new zombie.Browser(site: "http://localhost:#{opts.port}", headers: { "Accept": "text/html" })

{ MqttClient } = require("./clients/mqtt")
{ HttpClient } = require("./clients/http")
{ HttpJsonClient } = require("./clients/http_json")
{ HttpTxtClient } = require("./clients/http_txt")

protocols = 
  HTTP: HttpClient
  HTTP_JSON: HttpJsonClient
  HTTP_TXT: HttpTxtClient
  MQTT: MqttClient

exports.World = (callback) ->
  @browser = browser
  @opts = opts
  @app = app

  @clients = {}
  @getClient = (protocol, name, callback) =>
    if @clients[name]?
      callback(@clients[name])
    else
      protocols[protocol].build @opts, (client) =>
        @clients[name] = client
        callback(client)

  callback()
