
EventEmitter = require('events').EventEmitter

globalEventEmitter = new EventEmitter()
globalEventEmitter.setMaxListeners(0)
events = {}

KEYS_SET_NAME = 'topics'

module.exports = (app) ->
  buildKey = (key) ->
    "topic:#{key}"

  class Data

    constructor: (@key, @value) ->
      @value ||= null
    
    Object.defineProperty @prototype, 'key',
      enumerable: true
      configurable: false
      get: -> @_key
      set: (key) ->
        @redisKey = buildKey(key)
        @_key = key

    Object.defineProperty @prototype, 'jsonValue',
      configurable: false
      enumerable: true
      get: -> 
        JSON.stringify(@value)

      set: (val) ->
        @value = JSON.parse(val)

    save: (callback) ->
      app.redis.client.set @redisKey, @jsonValue, (err) =>
        app.ascoltatore.publish @key, @value, =>
          callback(err, @) if callback?

      app.redis.client.sadd KEYS_SET_NAME, @key

  Data.find = (pattern, callback) ->

    foundRecord = (key) ->
      app.redis.client.get buildKey(key), (err, value) ->
        if err
          callback(err) if callback?
          return

        unless value?
          callback("Record not found") if callback?
          return

        callback(null, Data.fromRedis(key, value)) if callback?

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

    # FIXME this is not atomic
    app.redis.client.get buildKey(key), (err, oldValue) ->
      data = Data.fromRedis(key, oldValue)
      data.value = value if value?
      data.save(callback)

    Data

  Data.fromRedis = (topic, value) ->
    data = new Data(topic)
    data.jsonValue = value
    data

  Data.subscribe = (topic, callback) ->
    callback._subscriber = (actualTopic, value) ->
      callback(new Data(actualTopic, value))
    app.ascoltatore.subscribe topic, callback._subscriber
    @

  Data.unsubscribe = (topic, callback) ->
    app.ascoltatore.unsubscribe topic, callback._subscriber
    @

  Data
