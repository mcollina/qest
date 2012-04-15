#! /usr/bin/env coffee

publish = require './publish_mqtt'
listen = require './listen_mqtt'
mqtt_port = 1883

Benchmark = require 'benchmark'

# process.addListener("uncaughtException", (er) -> console.log er )

suite = new Benchmark.Suite

setup_listeners = (suite, number) ->
  suite.add("#{number} Client", (d) ->
    publish_count = 0
    subscribed_count = 0
    for num in [0..number]
      client = listen "localhost", mqtt_port, "bench/#{number}", =>
        publish_count += 1
        d.resolve() if publish_count == number

      client.on 'connack', ->
        subscribed_count += 1
        if subscribed_count == number
          publish "localhost", mqtt_port, "bench/#{number}", "42"
  , defer: true)
  suite

setup_listeners(suite, 2)
setup_listeners(suite, 10)
setup_listeners(suite, 100)
#setup_listeners(suite, 1000)
#setup_listeners(suite, 10000)

suite.on('cycle', (event) ->
  console.log(event.target.name)
  console.log(event.target.stats.mean)
).on('complete', ->
  console.log('Fastest is ' + this.filter('fastest').pluck('name'))
).run(minSamples: 10, delay: 10)

