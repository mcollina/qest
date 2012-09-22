
module.exports = (app) ->
  Data = app.models.Data

  app.io.sockets.on 'connection', (socket) ->

    subscriptions = {}

    socket.on 'subscribe', (topic) ->

      Data.find topic, (data) ->

        subscription = (currentData) ->
          socket.emit("/topics/#{topic}", currentData.getValue())

        subscriptions[topic] = subscription

        data.on('change', subscription)

        subscription(data) if data.getValue()

    socket.on 'disconnect', ->

      for topic, listener of subscriptions
        Data.find topic, (data) ->
          data.removeListener('change', listener)
