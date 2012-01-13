
mqtt = null

mqtt_client_list = {}

io = null # this will be defined in the start method

data = {}

publish_payload = (topic, payload) ->
  # emit the payload over mqtt
  # Iterate over our list of mqtt clients
  for key, client of mqtt_client_list
    # Iterate over the client's subscriptions
    for subscription in client.subscriptions
      # If the client has a subscription matching
      # the packet...
      client.publish(topic, payload) if subscription.test(topic)

  # store the payload for REST consumption
  try
    data[topic] = { json: true, payload: JSON.parse(payload) }
  catch e
    console.log e
    data[topic] = { json: false, payload: payload }

  # emit the payload over websocket
  io.sockets.in("/topics/#{topic}").emit("/topics/#{topic}", data[topic])


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

  app.put '/topics/:topic', (req, res) ->
    publish_payload(req.params.topic, req.body.payload)
    res.send 204

  # setup websockets
  io = require('socket.io').listen(app)

  io.sockets.on 'connection', (socket) ->

    socket.on 'subscribe', (topic) ->
      socket.join("/topics/#{topic}")

      if data[topic]?
        socket.emit("/topics/#{topic}", data[topic])

  mqtt = new app.mqtt.MQTTServer()

  mqtt.on 'new_client', (client) ->
    console.log("New client emitted")

    client.on 'connect', (packet) ->
      @.clientId = packet.clientId
      mqtt_client_list[this.clientId] = @
      @.connack(0)

    client.on 'subscribe', (packet) ->
      for subscription in packet.subscriptions
        # '#' is 'match anything to the end of the string' */
        # + is 'match anything but a / until you hit a /' */
        reg = new RegExp(subscription.topic.replace('+', '[^\/]+').replace('#', '.+$'));
        client.subscriptions.push(reg)

      # push the latest value to the new client,
      # do not wait updates of the topic
      for topic, value of data
        for subscription in client.subscriptions
          client.publish(topic, value.payload) if subscription.test(topic)

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

module.exports.start = (port) ->
  mqtt.server.listen(port)
