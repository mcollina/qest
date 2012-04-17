#! /usr/bin/env coffee

Pool = require("./mqtt_client_pool").Pool
listen = require './listen_mqtt'
mqtt_port = 1883

Benchmark = require 'benchmark'

pool = new Pool("127.0.0.1", 1883)

suite = new Benchmark.Suite

payload = 0

setup_listeners = (suite, number) ->
  suite.add("#{number} Client", (d) ->
    payload += 1
    publish_count = 0
    subscribed_count = 0
    topic = "bench/#{number}"
    for num in [0...number]
      pool.get (client) ->

        # when we receive an update
        client.on 'publish', (packet) ->

          if packet.payload = String(payload)
            # we unsubscribe from the topic
            client.unsubscribe(topic: topic)
            client.removeAllListeners('publish')
            client.removeAllListeners('suback')

            # we resolve the benchmark if we have received all the updates
            publish_count += 1
            d.resolve() if publish_count == number

        client.on 'unsuback', ->
          # and we put the client back to the pool
          pool.release(client)
          client.removeAllListeners('unsuback')

        # when we receive a subscription ack
        client.on 'suback', (packet) ->
          subscribed_count += 1
          # console.log "suback #{subscribed_count}"
          
          # if we completed the subscriptions
          if subscribed_count == number
            pool.do (pub_client) -> 
              # we publish a new value on the queue
              # we do it ten times, so if one it's rejected
              # it's not a problem
              pub_client.publish topic: "bench/#{number}", payload: String(payload)

        # subscribe to the topic
        client.subscribe(topic: topic)


  , defer: true)
  suite

# setup_listeners(suite, 1)
# setup_listeners(suite, 10)
# setup_listeners(suite, 100)
setup_listeners(suite, 1000)
# setup_listeners(suite, 10000)

suite.on('cycle', (event) ->
  console.log(event.target.name)
  console.log(event.target.stats.mean)
  console.log("total clients: #{pool.created()}")
).on('complete', ->
  process.exit(0)
)


clients = []
total = 0
preload_connections = 10001
load_cycle = 100

create = ->
  for num in [0...load_cycle]
    pool.get (client) -> 
      total += 1
      clients.push(client)
      if total % load_cycle == 0 
        if total < preload_connections
          setTimeout(create, 100) 
        else 
          console.log "connection pool populated"
          pool.release(client) for client in clients
          suite.run(minSamples: 100, delay: 10, async: false, initCount: 10, maxTime: 60)

console.log "populating connection pool"
create()
