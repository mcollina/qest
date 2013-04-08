
module.exports = (app) ->
  Data = app.models.Data

  (client) ->

    listeners = {}

    unsubscribeAll = ->
      for topic, listener of listeners
        Data.unsubscribe(topic, listener)

    client.on 'connect', (packet) ->
      client.id = packet.client
      client.connack(returnCode: 0)

    client.on 'subscribe', (packet) ->
      granted = []
      subscriptions = []

      for subscription in packet.subscriptions
        # '#' is 'match anything to the end of the string' */
        # + is 'match anything but a / until you hit a /' */
        subscriptions.push(subscription.topic.replace("#", "*"))
        granted.push 0

      client.suback(messageId: packet.messageId, granted: granted)

      # subscribe for updates
      for subscription in subscriptions
        (->
          listener = (data) ->
            try
              if typeof data.value == "string"
                value = data.value
              else
                value = data.jsonValue
              client.publish(topic: data.key, payload: value)
            catch error
              console.log error
              client.close()
          listeners[subscription] = listener
          Data.subscribe(subscription, listener)

          Data.find new RegExp(subscription), (err, data) ->
            throw err if err? # the persistance layer is not working properly
            listener(data)
        )()

    client.on 'publish', (packet) ->
      payload = packet.payload
      try
        payload = JSON.parse(payload)
      catch error
        # nothing to do
      Data.findOrCreate packet.topic, payload

    client.on 'pingreq', (packet) ->
	    client.pingresp()

    client.on 'disconnect', ->
      client.stream.end()

    client.on 'error', (error) ->
      console.log error
      client.stream.end()

   	client.on 'close', (err) ->
      unsubscribeAll()
    
    client.on 'unsubscribe', (packet) ->
      client.unsuback(messageId: packet.messageId)
