
module.exports = (app) ->
  Data = app.models.Data

  app.io.sockets.on 'connection', (socket) ->

    subscriptions = {}

    socket.on 'subscribe', (topic) ->

      subscription = (currentData) ->
        socket.emit("/topics/#{topic}", currentData.value)

      subscriptions[topic] = subscription

      Data.subscribe topic, subscription

      Data.find topic, (err, data) ->
        subscription(data) if data?.value?

    socket.on 'disconnect', ->
      for topic, listener of subscriptions
        Data.unsubscribe(topic, listener)
