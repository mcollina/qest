
MQTTServer = require("mqtt").MQTTServer

mqtt = new MQTTServer()

mqtt_client_list = []

data = {}

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
        client.subscriptions.push(reg);

    client.on 'publish', (packet) ->
      
      try 
        data[packet.topic] = { json: true, payload: JSON.parse(packet.payload) }
      catch e
        data[packet.topic] = { json: false, payload: packet.payload }

	    # Iterate over our list of clients
	    for client in mqtt_client_list
	      # Iterate over the client's subscriptions
        for subscription in client.subscriptions
          # If the client has a subscription matching
          # the packet...

          c.publish(packet.topic, packet.payload) if subscription.test(packet.topic)


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
    if data[topic]?
      if data[topic].json
        res.contentType('json')
        res.send data[topic].payload
      else 
        # it's not a json, don't emit anything
        res.send data[topic].payload
    else
      res.send "Topic not found!", 404

module.exports.start = (port) ->
  mqtt.server.listen(port)
