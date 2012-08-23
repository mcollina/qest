
mqtt = require('mqttjs')

module.exports = ->
  @Before "@mqtt", (done) ->
    mqtt.createClient @opts.mqtt, "127.0.0.1", (err, client) =>
      throw new Error(err) if err?
      client.connect(client: "cucumber!", keepalive: 3000)

      client.on 'connack', (packet) ->
        if packet.returnCode == 0
          done()
        else
          console.log('connack error %d', packet.returnCode)
          throw new Error("connack error #{packet.returnCode}")


      last_packets = {}

      client.on 'publish', (packet) =>
        last_packets[packet.topic] = packet

      @subscribe = (topic) =>
        client.subscribe(topic: topic)

      @publish = (topic, message) =>
        client.publish(topic: topic, payload: message)

      @getLastMessageFromTopic = (topic, callback) =>
        last_packet = last_packets[topic]
        if last_packet?
          callback(last_packet)
          return

        listenToPublish = (packet) ->
          if packet.topic == topic
            callback(packet)
            client.removeListener(topic, listenToPublish)

        client.on('publish', listenToPublish)

