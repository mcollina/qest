mqtt = require('mqttjs')

class Pool
 
  constructor: (@host, @port) ->
    @clients_counter = 0
    @clients = []
    @total_errors = 0

    print_total_errors = =>
      console.log "Current errors: #{@total_errors}"
      setTimeout(print_total_errors, 2000)
      #    print_total_errors()
  
  created: () -> @clients_counter

  do: (callback) ->
    @get (client) =>
      callback(client)
      @release(client)
  
  release: (client) -> @clients.push(client)

  get: (setupCallback = ->) ->
    client = @clients.pop()
    
    if client?
      setupCallback(client)
      return @

    errors = 0

    @clients_counter += 1
    client_id = @clients_counter

    create = =>
      created = false
      mqtt.createClient @port, @host, (err, client) =>

        if err?
          @total_errors += 1 if errors == 0
          setTimeout(=>
            errors += 1
            if errors == 10
              console.log "Impossible to connect to the server"
              process.exit(1)
            console.log "Connecting error n #{errors}"
            console.log "Reconnecting"
            create()
          , 500)
          return
        console.log err if err?

        # console.log "created #{@clients_counter} with errors #{errors}" if errors > 0

        # console.log "total clients: #{@clients_counter}"

        client.connect client: "mqtt_bench_#{client_id}_#{errors}"

        client.on 'connack', (packet) =>
          if packet.returnCode == 0
            @total_errors -= 1 if errors > 0
            setupCallback(client)
          else
            console.log('connack error %d', packet.returnCode)

        client.on 'pingreq', (packet) ->
          client.pingresp()

        client.on 'close', ->
          client.stream.removeAllListeners()
          client.stream.destroy()

    create()
    @

  destroyAll: ->
    for client in @clients
      client.disconnect()

    @clients = []

module.exports.Pool = Pool
