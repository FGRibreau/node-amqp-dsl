AmqpDsl = require 'amqp-dsl'


AmqpDsl
# First we log in, here the list of the available parameters and their default value
#
#     { 
#       login: 'guest'
#       password: 'guest'
#       host:'localhost'
#       port: 5672
#       vhost: '/'
#     }
#
  .login(
    login: 'legen'
    password: 'dary'
  )
  
  # Bind listeners to some events (available events are `close`, `error` and `ready`)
  .on('close', () -> console.error "RabbitMQ connection closed")
  .on('error', (err) -> console.error "RabbitMQ error", err)
  .on('ready', () -> console.log "Connected to RabbitMQ")

  # We create a queue (`passive: false` see AMQP doc) with `.queue`
  #
  # * `.queue( name, options )`
  # * `.queue( name, callback(queue) )`
  # * `.queue( name, options, callback(queue) )`
  .queue('testQueue', (queue) -> console.log "Connected to Queue", queue.name)

    # (optional) ... and bind that queue to an exchange with `.bind`
    #
    # * `.bind( name, routingKey )`
    .bind('stream', '#')

    # (optional) ... and subscribe for messages (without `ack` in this example)
    #
    # * `.subscribe( callback(message, header, deliveryInfo) )`
    # * `.subscribe( options, callback(message, header, deliveryInfo) )`
    .subscribe((message, header, deliveryInfo) -> )
  
  # Create another queue `queue2` that will be binded to `search` exchange with the routing key `#.ok`
  .queue('queue2')
    .bind('search', '#.ok')
  
  # Connect to an existing queue `queue3`
  .queue('queue3', passive:true, (queue)-> console.log "Connected to Queue", queue.name)

  # And now it's time to connect !
  # `amqp` contains:
  #
  # * `amqp.connections` == `[node-amqp::Connection]`
  # * `amqp.queues` == `{}`
  # * `amqp.exchanges` == `{}`
  .connect((err, amqp) ->

    if err
      throw err
      return

    console.log 'We are connected !'

    # Do other stuff with `amqp` like subscribing to a queue

    queue3 = amqp.queues.queue3
    
    queue3.subscribe(ack:true, (message) ->
      console.log "Hey ! We got one new message !"
      queue3.shift()
    )

  )