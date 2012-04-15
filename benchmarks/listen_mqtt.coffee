
mqtt = require('mqttjs')

clients = 0
module.exports = (host, port, topic, callback) ->
  mqtt.createClient port, host, (client) ->
    clients += 1

    client.stream.on 'error', ->
      console.log("error listener")
      callback()

    client.connect keepalive: 3000, client: "mqtt_bench_sub_" + clients

    client.on 'connack', (packet) ->
      if packet.returnCode == 0
        client.subscribe(topic: topic)
      else
        console.log('connack error %d', packet.returnCode)
    
    client.on 'publish', (packet) ->
      callback()
      client.disconnect()

    client.on 'close', ->
      client.stream.removeAllListeners()
      client.stream.destroy()

