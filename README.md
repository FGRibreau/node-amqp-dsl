## Fluent Interface for dealing with AMQP on NodeJS [![Build Status](https://secure.travis-ci.org/FGRibreau/node-amqp-dsl.png)](http://travis-ci.org/FGRibreau/node-amqp-dsl) [![Gittip](http://badgr.co/gittip/fgribreau.png)](https://www.gittip.com/fgribreau/)

AMQP-DSL is a [fluent interface](http://en.wikipedia.org/wiki/Fluent_interface) wrapper for [node-amqp](https://github.com/postwait/node-amqp) and help you write AMQP binding code in a clean and efficient way.

## Installation

    $ npm install amqp-dsl

## Usage overview

### Simple connection (more details: `docs/example-connection`)

```coffeescript

amqp = require 'amqp-dsl'

amqp.login(

  login: 'user'
  password: 'password'
  host: 'localhost'

).connect((err, amqp) ->

  if err
    throw err
    return

  console.log 'We are connected !'

)
```

### Simple example (more details: `docs/example-simple`)

```coffeescript

AmqpDsl = require 'amqp-dsl'

AmqpDsl.login(
  login: 'legen'
  password: 'dary'
)
.on( 'close', () -> console.error "RabbitMQ connection closed" )
.on( 'error', (err) -> console.error "RabbitMQ error", err )
.on( 'ready', () -> console.log "Connected to RabbitMQ" )

.queue( 'testQueue', (queue) -> console.log "Connected to Queue", queue.name )
  .bind( 'stream', '#' )
  .bind( 'stream2', 'routing.key' )
  .subscribe( (message, header, deliveryInfo) -> )

.queue( 'queue2' )
  .bind( 'search', '#.ok' )

.queue( 'queue3', passive:true )

.connect( (err, amqp) ->

  if err
    throw err
    return

  # Do other stuff with `amqp` like subscribing to a queue

  queue3 = amqp.queues.queue3

  queue3.subscribe( ack:true, ( message, header, deliveryInfo ) ->
    console.log "Hey ! We got one new message !"
    queue3.shift()
  )

)
```

See `examples/` and `docs/` for more information.

## API

### .login
 * `login( options = {} )`

### .on
 * `on( event, listener )`

### .exchange
 * `.exchange( name, options )`
 * `.exchange( name, callback(exchange) )`
 * `.exchange( name, options, callback(exchange) )`

### .queue
 * `.queue( name, options )`
 * `.queue( name, callback(queue) )`
 * `.queue( name, options, callback(queue) )`

### .queue(...).subscribe
 * `.subscribe( callback(message, header, deliveryInfo) )`
 * `.subscribe( options, callback(message, header, deliveryInfo) )`

### .queue(...).bind
 * `.bind( name, routingKey )`

### .connect
 * `.connect()`
 * `.connect( callback(err, amqp) )`
 * `.connect( amqp, callback(err, amqp) )`

The `amqp` argument is simply hashtable with the following properties:

 * queues (hashtable of `AMQP::queues`)
 * exchanges (hashtable of `AMQP::Exchange`)
 * connection (`AMQP::Connection`)


## Documentation

### Build documentation
    $ cake doc

... and browse `docs/`

## Test

    $ npm test

## Release History
v1.0.3 - Support for .connect()
v1.0.2 - Critical bug fix
v1.0.1 - .bind & .subscribe can now be called multiple times. This is the behavior that should have been in place since the beginning.

## Donate
[Donate Bitcoins](https://coinbase.com/checkouts/fc3041b9d8116e0b98e7d243c4727a30)

## License
Copyright (c) 2013 Francois-Guillaume Ribreau
Licensed under the MIT license.
