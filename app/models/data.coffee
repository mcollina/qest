
EventEmitter = require('events').EventEmitter

globalEventEmitter = new EventEmitter()
events = {}

KEYS_SET_NAME = 'topics'

module.exports = (app) ->

  getEventEmitter = (key) ->
    unless events[key]?
      events[key] = new EventEmitter()
      app.redis.pubsub.subscribe(key)

    events[key]

  buildKey = (key) ->
    "topic:" + key

  app.redis.pubsub.subscribe('newData')

  app.redis.pubsub.on 'message', (topic, value) ->
    if topic != 'newData'
      topic = topic.split(":")[1..-1].join("")
      data = new Data(topic, value)
      getEventEmitter(topic).emit('change', data)
    else
      Data.find value, (data) -> globalEventEmitter.emit("newData", data)

  class Data

    constructor: (@key, @value) ->
      @value ||= null
    
    getKey: () -> @key

    getValue: () -> @value

    setValue: (val) -> @value = val

    on: (event, callback) ->
      app.redis.pubsub.subscribe(buildKey(@key))
      getEventEmitter(@key).on(event, callback)
      @

    removeListener: (event, callback) ->
      getEventEmitter(@key).removeListener(event, callback)
      @

    save: (callback) ->

      app.redis.client.sismember KEYS_SET_NAME, @key, (err, result) =>
        if result == 0
          app.redis.client.publish("newData", @key)
          app.redis.client.sadd(KEYS_SET_NAME, @key)
        else
          app.redis.client.publish(buildKey(@key), @value)

        app.redis.client.set buildKey(@key), @value, (=> callback(@) if callback?)

      @

  Data.find = (pattern, callback) ->

    foundRecord = (key) ->
      app.redis.client.get buildKey(key), (err, value) ->
        error = "Record not found" unless value?
        callback(new Data(key, value), error) if callback?

    if pattern.constructor != RegExp
      foundRecord(pattern)
    else
      app.redis.client.smembers KEYS_SET_NAME, (err, topics) ->
        for topic in topics
          foundRecord(topic) if pattern.test(topic)

    Data

  Data.findOrCreate = ->
    args = Array.prototype.slice.call arguments

    key = args.shift() # first arg shifted out

    arg = args.shift() # second arg popped out
    if typeof arg == 'function'
      # if the second arg is a function,
      # then there is no third arg
      callback = arg 
    else
      # if the second arg is not a function
      # then it's the value, and the third is
      # the callback
      value = arg 
      callback = args.shift()

    # FIXME this is not atomic, is it a problem?
    app.redis.client.get buildKey(key), (err, oldValue) ->
      data = new Data(key, oldValue)
      data.setValue(value) if value?
      data.save(callback)

    Data

  Data.reset = ->
    for key, event of events
      app.redis.pubsub.unsubscribe(buildKey(key))
      delete events[key]
    globalEventEmitter.removeAllListeners()

  Data.reset()

  Data.on = (event, callback) ->
    globalEventEmitter.on(event, callback)
    @

  Data.removeListener = (event, callback) ->
    globalEventEmitter.removeListener(event, callback)
    @

  Data
