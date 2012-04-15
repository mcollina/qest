
mqtt = require('mqttjs')

clients = 0
module.exports = (host, port, topic, payload) ->
  mqtt.createClient port, host, (client) ->
    clients += 1

    client.stream.on 'error', ->
      console.log("error publisher")

    client.connect keepalive: 3000, client: "mqtt_bench_pub_" + clients

    client.on 'connack', (packet) ->
      if packet.returnCode == 0
        client.publish topic: topic, payload: payload
        client.disconnect()
      else
        console.log('connack error %d', packet.returnCode)

    client.on 'close', ->
      client.stream.removeAllListeners()
      client.stream.destroy()

