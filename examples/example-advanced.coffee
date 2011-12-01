AmqpDsl = require 'amqp-dsl'


AmqpDsl
  .login(
    login: 'legen'
    password: 'waitforit'
    host: 'dary'
    port: 2290
    vhost: '/legendary'
  )

  # Exchanges, queues and event listener can be declared wherever you want between `login` and `connect`

  .on('close', () -> console.log "Close ", arguments)
  .on('error', () -> console.log "Error ", arguments)
  
  .queue('test', passive:false, (queue) -> console.log "Connected to Queue", queue.name)
    .bind('stream', '#')
    .subscribe((message, header, deliveryInfo) -> )

  .queue('queue2')
    .bind('search', '#')

  .exchange('stream', passive:true, (exchange) -> console.log "Connected to Exchange", exchange.name)

  .exchange('createdExchg')
  
  .queue('queue3', (queue)-> console.log "Connected to Queue", queue.name)
    .bind('createdExchg', '#')
  
  .on('ready', () -> console.log "Connected to RabbitMQ")

  .connect((err, amqp) ->

    console.log "Connected to #{Object.keys(amqp.exchanges).length} exchanges"
    console.log "Connected to #{Object.keys(amqp.queues).length} queues"

    # All queues & exchanges declared with AMQP-DSL can be accessible through amqp.queues & amqp.exchanges
    queue3 = amqp.queues.queue3

    queue3.subcribe(ack:true, (message) ->
      console.log message
      queue3.shift()
    )

    createdExchg = amqp.exchanges.createdExchg

    createdExchg.publish("routingKey", hello:"world")

  )