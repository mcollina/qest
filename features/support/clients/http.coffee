request = require('request')

class HttpClient
  
  constructor: (@port, @host) ->

  subscribe: (topic) ->
    throw new Error("Not implemented yet")

  publish: (topic, message, callback) ->
    request.put(uri: @url(topic), form: { payload: message }, callback)

  getLastMessageFromTopic: (topic, callback) ->
    request.get uri: @url(topic), headers: @headers , (err, response, body) ->
      callback(body)

  headers: () ->
    {}

  disconnect: () ->

  url: (topic) ->
    "http://#{@host}:#{@port}/topics/#{topic}"

HttpClient.build = (opts, callback) ->
  callback new HttpClient(opts.port, "127.0.0.1")

module.exports.HttpClient = HttpClient
