
MQTTServer = require("mqtt").MQTTServer

mqtt = new MQTTServer()

mqtt_client_list = []

io = null # this will be defined in the start method

data = {}

publish_payload = (topic, payload) ->
  # emit the payload over mqtt
  # Iterate over our list of mqtt clients
  for client in mqtt_client_list
    # Iterate over the client's subscriptions
    for subscription in client.subscriptions
      # If the client has a subscription matching
      # the packet...

      c.publish(topic, payload) if subscription.test(topic)

  # store the payload for REST consumption
  try
    data[topic] = { json: true, payload: JSON.parse(payload) }
  catch e
    data[topic] = { json: false, payload: payload }

  # emit the payload over websocket
  io.sockets.emit "/topics/#{topic}", data[topic].payload

mqtt.on 'new_client', (client) ->
    console.log("New client emitted")

    client.on 'connect', (packet) ->
      @.clientId = packet.clientId
      mqtt_client_list[this.clientId] = @
      @.connack(0)

    client.on 'subscribe', (packet) ->
      for subscription in packet.subscriptions.length
        # '#' is 'match anything to the end of the string' */
        # + is 'match anything but a / until you hit a /' */
        reg = new RegExp(subscription.topic.replace('+', '[^\/]+').replace('#', '.+$'));
        client.subscriptions.push(reg)

    client.on 'publish', (packet) ->
      publish_payload packet.topic, packet.payload

    client.on 'pingreq', (packet) ->
	    client.pingresp()

    client.on 'disconnect', ->
      this.socket.end()
      delete mqtt_client_list[this]

    client.on 'error', (error) ->
      this.socket.end()
      delete mqtt_client_list[this]

module.exports = (app) ->
  app.get '/topics/:topic', (req, res) ->
    topic = req.params.topic
    if req.accepts 'json'
      if data[topic]?
        if data[topic].json
          res.contentType('json')
          res.send data[topic].payload
        else
          # it's not a json, don't emit a contentType
          res.send data[topic].payload
      else
        res.send "Topic not found!", 404
    else
      value = data[topic] || { json: false, payload: "" }
      res.render 'topic.hbs', topic: req.params.topic, value: value

  # setup websockets
  io = require('socket.io').listen(app)

module.exports.start = (port) ->
  mqtt.server.listen(port)
