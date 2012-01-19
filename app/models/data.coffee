
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
      getEventEmitter(@key).on('change', callback)
      @

    save: (callback) ->
      getEventEmitter(@key).emit('change', @)
      globalEventEmitter.emit("newData", @) unless data[@key]?
      data[@key] = @value
      setTimeout((=> callback(@)), 0) if callback?
      @

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

    currentData = new Data(key, data[key] || value)

    unless data[key]?
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

  Data
