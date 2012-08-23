
mqtt = require('mqttjs')

class MqttClient

  constructor: (@client) ->
    @last_packets = {}

    @client.on 'publish', (packet) =>
      @last_packets[packet.topic] = packet

  subscribe: (topic) ->
    @client.subscribe(topic: topic)

  publish: (topic, message) ->
    @client.publish(topic: topic, payload: message)

  disconnect: ->
    @client.disconnect()

  getLastMessageFromTopic: (topic, callback) ->
    last_packet = @last_packets[topic]
    if last_packet?
      callback(last_packet)
      return

    listenToPublish = (packet) =>
      if packet.topic == topic
        callback(packet)
        @client.removeListener(topic, listenToPublish)

    @client.on('publish', listenToPublish)

counter = 0

module.exports = ->
  @Before (done) ->

    @buildMQTTClient = (callback) =>
      mqtt.createClient @opts.mqtt, "127.0.0.1", (err, client) =>
        throw new Error(err) if err?
        client.connect(client: "cucumber #{counter++}!", keepalive: 3000)

        client.on 'connack', (packet) ->
          if packet.returnCode == 0
            callback(new MqttClient(client))
          else
            console.log('connack error %d', packet.returnCode)
            throw new Error("connack error #{packet.returnCode}")

    @mqttClients = {}
    @getMQTTClient = (name, callback) =>
      if @mqttClients[name]?
        callback(@mqttClients[name])
      else
        @buildMQTTClient (client) =>
          @mqttClients[name] = client
          callback(client)
    
    done()

  @After (done) ->
    for name, client of @mqttClients
      client.disconnect()

    @mqttClients = {}

    done()

