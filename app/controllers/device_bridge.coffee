
mqtt = null

io = null # this will be defined in the start method

module.exports = (app) ->
  Data = app.models.Data

  publish_payload = (topic, payload) ->
    Data.findOrCreate topic, payload

  app.get '/topics/:topic', (req, res) ->
    topic = req.params.topic
    Data.find topic, (data, err) ->
      if req.accepts 'json'
        res.contentType('json')
        if err?
          res.send 404
        else
          res.send data[topic].payload
      else
        res.render 'topic.hbs', topic: req.params.topic

  app.put '/topics/:topic', (req, res) ->
    publish_payload(req.params.topic, req.body.payload)
    res.send 204

  # setup websockets
  io = require('socket.io').listen(app)

  io.sockets.on 'connection', (socket) ->

    subscriptions = {}

    socket.on 'subscribe', (topic) ->

      Data.findOrCreate topic, (data) ->

        subscription = (currentData) ->
          socket.emit("/topics/#{topic}", currentData.getValue())

        subscriptions[topic] = subscription

        data.on('change', subscription)

        subscription(data) if data.getValue()

    socket.on 'disconnect', ->

      for topic, listener of subscriptions
        Data.findOrCreate topic, (data) ->
          data.removeListener('change', listener)

  mqtt = app.mqtt.createServer (client) ->

    listeners = {}
    globalListener = null

    client.on 'connect', (packet) ->
      client.id = packet.client
      client.connack(returnCode: 0)

    client.on 'subscribe', (packet) ->
      granted = []
      subscriptions = []

      for subscription in packet.subscriptions
        # '#' is 'match anything to the end of the string' */
        # + is 'match anything but a / until you hit a /' */
        reg = new RegExp(subscription.topic.replace('+', '[^\/]+').replace('#', '.+$'));
        subscriptions.push(reg)
        granted.push subscription

      client.suback(messageId: packet.messageId, granted: granted)

      addListener = (data) ->

        listener = (currentData) ->
          client.publish(topic: currentData.getKey(), payload: currentData.getValue())

        data.on 'change', listener

        listeners[data.getKey()] = listener

        listener(data) if data.getValue()?

      # push the latest value to the new client,
      # do not wait updates of the topic
      for subscription in subscriptions
        Data.find subscription, addListener

      globalListener = (data) ->
        for subscription in subscriptions
          addListener(data) if subscription.test(data.getKey())

      Data.on 'newData', globalListener

    client.on 'publish', (packet) ->
      publish_payload packet.topic, packet.payload

    client.on 'pingreq', (packet) ->
	    client.pingresp()

    client.on 'disconnect', ->
      client.stream.end()

    client.on 'error', (error) ->
      client.stream.end()
      console.log(e)

   	client.on 'close', (err) ->
      Data.removeListener('newData', globalListener) if globalListener?
      for topic, listener of listeners
        Data.find topic, (data) ->
          data.removeListener('change', listener)

  return { 
    start: (port) ->
      mqtt.listen(port)
  }
