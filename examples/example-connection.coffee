AmqpDsl = require 'amqp-dsl'


AmqpDsl
  # First we log in, here the list of the available parameters and their default value
  #
  #     { 
  #       login: 'guest'
  #       password: 'guest'
  #       host: 'localhost'
  #       port: 5672
  #       vhost: '/'
  #     }
  #
  .login(
    login: 'user'
    password: 'password'
    host: 'localhost'
  )
  
  # We could do something else like creating `queues` or connecting to existing `exchange` (take a look at `example-simple.coffee` for that) but for now we just want to start the connection.
  .connect((err, amqp) ->


    if err
      throw err 
      return
    
    # `amqp.connections` == `[node-amqp::Connection]`
    console.log 'We are connected !'
  )