request = require('request')

class HttpJsonClient
  
  constructor: (@port, @host) ->

  subscribe: (topic) ->
    throw new Error("Not implemented yet")

  publish: (topic, message, callback) ->
    message = JSON.parse(message)
    request.put(
      uri: @url(topic), 
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ payload: message }),
      callback)

  getLastMessageFromTopic: (topic, callback) ->
    request.get uri: @url(topic), headers: { "Accept": "application/json" } , (err, response, body) ->
      callback(body)

  disconnect: () ->

  url: (topic) ->
    "http://#{@host}:#{@port}/topics/#{topic}"

HttpJsonClient.build = (opts, callback) ->
  callback new HttpJsonClient(opts.port, "127.0.0.1")

module.exports.HttpJsonClient = HttpJsonClient
