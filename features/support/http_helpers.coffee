request = require('request')

class HttpClient
  
  constructor: (@port, @host) ->

  subscribe: (topic) ->
    throw new Error("Not implemented yet")

  publish: (topic, message, callback) ->
    request.put(uri: @url(topic), form: { payload: message }, callback)

  getLastMessageFromTopic: (topic, callback) ->
    request.get uri: @url(topic), headers: {"Accept": "text/plain"}, (err, response, body) ->
      callback(body)

  disconnect: () ->

  url: (topic) ->
    "http://#{@host}:#{@port}/topics/#{topic}"


module.exports = ->
  @Before (done) ->

    @buildHTTPClient = (callback) =>
      callback new HttpClient(@opts.port, "127.0.0.1")

    @httpClients = {}
    @getHTTPClient = (name, callback) =>
      if @httpClients[name]?
        callback(@httpClients[name])
      else
        @buildHTTPClient (client) =>
          @httpClients[name] = client
          callback(client)
    
    done()

  @After (done) ->
    for name, client of @httpClients
      client.disconnect()

    @httpClients = {}

    done()

