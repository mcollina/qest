
module.exports = (app) ->
  Data = app.models.Data

  (client) ->

    listeners = {}
    globalListener = null

    unsubscribe_all = ->
      Data.removeListener('newData', globalListener) if globalListener?
      for topic, listener of listeners
        Data.find topic, (data) ->
          data.removeListener('change', listener)

    client.on 'connect', (packet) ->
      client.id = packet.client
      client.connack(returnCode: 0)

    client.on 'subscribe', (packet) ->
      granted = []
      subscriptions = []

      for subscription in packet.subscriptions
        # '#' is 'match anything to the end of the string' */
        # + is 'match anything but a / until you hit a /' */
        reg = new RegExp(subscription.topic.replace('+', '[^\/]+').replace('#', '.+$'));
        subscriptions.push(reg)
        granted.push 0

      client.suback(messageId: packet.messageId, granted: granted)

      addListener = (data) ->

        listener = (currentData) ->
          try
            client.publish(topic: currentData.getKey(), payload: currentData.getValue())
          catch error
            console.log error
            client.close()

        data.on 'change', listener

        listeners[data.getKey()] = listener

        listener(data) if data.getValue()?

      # push the latest value to the new client,
      # do not wait updates of the topic
      for subscription in subscriptions
        Data.find subscription, addListener

      globalListener = (data) ->
        for subscription in subscriptions
          addListener(data) if subscription.test(data.getKey())

      Data.on 'newData', globalListener

    client.on 'publish', (packet) ->
      Data.findOrCreate packet.topic, packet.payload

    client.on 'pingreq', (packet) ->
	    client.pingresp()

    client.on 'disconnect', ->
      client.stream.end()

    client.on 'error', (error) ->
      console.log error
      client.stream.end()

   	client.on 'close', (err) ->
      unsubscribe_all()
    
    client.on 'unsubscribe', (packet) ->
      # we do a trick to save our bench
      unsubscribe_all()
      client.unsuback(messageId: packet.messageId)
