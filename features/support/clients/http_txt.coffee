
{ HttpClient } = require './http'

class HttpTxtClient extends HttpClient
  headers: ->
    { "Accept": "text/plain" }

HttpTxtClient.build = (opts, callback) ->
  callback new HttpTxtClient(opts.port, "127.0.0.1")

module.exports.HttpTxtClient = HttpTxtClient
