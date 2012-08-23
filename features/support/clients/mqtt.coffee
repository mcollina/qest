mqtt = require('mqttjs')

class MqttClient

  constructor: (@client) ->
    @last_packets = {}

    @client.on 'publish', (packet) =>
      @last_packets[packet.topic] = packet.payload

  subscribe: (topic) ->
    @client.subscribe(topic: topic)

  publish: (topic, message, callback) ->
    @client.publish(topic: topic, payload: message)
    callback()

  disconnect: ->
    @client.disconnect()

  getLastMessageFromTopic: (topic, callback) ->
    last_packet = @last_packets[topic]
    if last_packet?
      callback(last_packet)
      return

    listenToPublish = (packet) =>
      if packet.topic == topic
        callback(packet.payload)
        @client.removeListener(topic, listenToPublish)

    @client.on('publish', listenToPublish)

counter = 0

MqttClient.build = (opts, callback) ->
  mqtt.createClient opts.mqtt, "127.0.0.1", (err, client) =>
    throw new Error(err) if err?
    client.connect(client: "cucumber #{counter++}!", keepalive: 3000)

    client.on 'connack', (packet) ->
      if packet.returnCode == 0
        callback(new MqttClient(client))
      else
        console.log('connack error %d', packet.returnCode)
        throw new Error("connack error #{packet.returnCode}")

module.exports.MqttClient = MqttClient
