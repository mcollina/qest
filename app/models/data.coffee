
EventEmitter = require('events').EventEmitter

globalEventEmitter = new EventEmitter()
data = null
events = null

getEventEmitter = (key) ->
  events[key] ||= new EventEmitter()

module.exports = (app) ->
  
  class Data

    constructor: (@key, @value) ->
    
    getKey: () -> @key

    getValue: () -> @value

    setValue: (val) -> @value = val

    on: (event, callback) ->
      getEventEmitter(@key).on(event, callback)
      @

    removeListener: (event, callback) ->
      getEventEmitter(@key).removeListener(event, callback)
      @

    save: (callback) ->
      getEventEmitter(@key).emit('change', @)
      globalEventEmitter.emit("newData", @) unless data[@key]?
      data[@key] = @value
      setTimeout((=> callback(@)), 0) if callback?
      @

  doCallback = (key, value, callback) ->
    error = "Record not found" unless value?
    setTimeout((-> callback(new Data(key, value), error)), 0) if callback?

  Data.find = (key, callback) ->
    
    if key.constructor != RegExp
      doCallback(key, data[key], callback)
    else
      for topic, value of data
        if key.test(topic)
          doCallback(topic, value, callback)

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

    currentData = new Data(key, data[key])

    if value?
      currentData.setValue(value)
      currentData.save(callback)
    else
      setTimeout((-> callback(currentData)), 0) if callback?

    Data

  Data.reset = ->
    data = {}
    events = {}
    globalEventEmitter.removeAllListeners()

  Data.reset()

  Data.on = (event, callback) ->
    globalEventEmitter.on(event, callback)
    @

  Data.removeListener = (event, callback) ->
    globalEventEmitter.removeListener(event, callback)
    @

  Data
