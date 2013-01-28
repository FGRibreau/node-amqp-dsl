# Amqp-DSL - Fluent interface for node-amqp

async          = require 'async'

IndexedList    = require './IndexedList'
AmqpQueue      = require './AmqpQueue'
AmqpExchange   = require './AmqpExchange'

module.exports = class AmqpDsl

  LISTENNERS   =['error','close','ready']

  ## Public API
  #### require('amqp-dsl').login
  # * `login( options = {} )`
  #
  AmqpDsl.login = (opt = {}) ->
    new AmqpDsl(opt)

  constructor:(opt = {}) ->

    # Defaults
    @_login = ''
    @_password = ''
    @_host = ''
    @_port = 5672
    @_vhost = '/'

    @_conn = null
    @_callback = ->

    # Constructor arguments
    opt.login and (@_login = opt.login)
    opt.password and (@_password = opt.password)
    opt.host and (@_host = opt.host)
    opt.port and (@_port = opt.port)
    opt.vhost and (@_vhost = opt.vhost)
    opt.login and (@_login = opt.login)

    # Events
    @_events = {}

    # Exchanges
    @_exchanges = new IndexedList()

    # Queues
    @_queues = new IndexedList()

  #### .on
  # * `on( event, listener )`
  on:( event, listener ) ->
    if !~LISTENNERS.indexOf(event)
      throw new Error("Event '#{event}' is invalid")

    @_events[event] = [] if(!@_events[event])

    @_events[event].push(listener)

    this

  #### .exchange
  # * `.exchange( name, options )`
  # * `.exchange( name, callback(exchange) )`
  # * `.exchange( name, options, callback(exchange) )`
  exchange:( name, options, openCallback ) ->
    @_exchanges.set(name, new AmqpExchange(name, options, openCallback))
    this

  #### .queue
  # * `.queue( name, options )`
  # * `.queue( name, callback(queue) )`
  # * `.queue( name, options, callback(queue) )`
  queue:( name, options, openCallback ) ->
    @_queues.set(name, new AmqpQueue(name, options, openCallback))
    this

  #### .queue(...).subscribe
  # * `.subscribe( callback(message, header, deliveryInfo) )`
  # * `.subscribe( options, callback(message, header, deliveryInfo) )`
  subscribe:( options, messageListener ) ->
    queue = @_queues.last()

    throw new Error("At least one queue must be declared") if !queue

    queue.subscribe(options, messageListener)
    this

  #### .queue(...).bind
  # * `.bind( name, routingKey )`
  bind:( name, routingKey ) ->
    queue = @_queues.last()
    throw new Error("At least one queue must be declared") if !queue
    queue.bind(name, routingKey)
    this

  #### .connect
  # * `.connect( amqp, callback(err, amqp) )`
  # * `.connect( callback(err, amqp) )`
  #
  # `amqp` parameter is an hashtable which contain
  #
  #       queues:
  #          sampleQueue:[Amqp::Queue]
  #
  #       exchanges:
  #          sampleExchange:[Amqp::Exchange]
  #
  #       connection: [Amqp::Connection]
  #
  connect:(amqp, @_callback)->

    if typeof amqp is "function"
      @_callback = amqp
      amqp = require 'amqp'

    @_connect(amqp)

    null

  ## Private API

  # Create the connection to amqp and bind events
  _connect:(amqp) ->
    # Create connection
    @conn = amqp.createConnection({
      host: @_host,
      port: @_port,
      login: @_login,
      password: @_password,
      vhost: @_vhost
    })

    # When the connection will be ready, connect the exchanges
    @on 'ready', () => @_connectExchanges(@_connectQueues.bind(this))

    # Set event listeners
    @conn.on(event, @_getListenerFor(event)) for event of @_events

  # Return a listener fonction for the event `event`.
  _getListenerFor: (event) ->

    if @_events[event].length == 1
      return @_events[event][0]
    else
      return (args...) =>
        listener.apply(null, args) for listener in @_events[event]
        true

  # Connect to exchanges
  _connectExchanges:(next) ->

    async.forEach @_exchanges.list(), @_connectExchange.bind(@), (err) =>
      if err
        throw new Error("Couldn't connect to the exchanges: #{err.message}")
        return

      next()

  # Exchange connection iterator
  _connectExchange:(exchange, callback) ->

    @conn.exchange exchange.name, exchange.options, (exchangeRef) ->
      exchange.ref = exchangeRef
      exchange.openCallback(exchangeRef)

      callback(null, true)

  # Connect to queues
  _connectQueues:() ->

    async.forEach @_queues.list(), @_connectQueue.bind(@), (err) =>
      if err
        throw new Error("Couldn't connect to the queues: #{err.message}")
        return

      @_done()

  # Queue connection iterator
  _connectQueue:(queue, callback) ->

    @conn.queue queue.name, queue.options, (queueRef) ->
      queue.ref = queueRef

      queue.openCallback(queueRef)

      queue.bindTo.forEach((bind) ->
        {exchange, routingKey} = bind
        queueRef.bind exchange, routingKey
      )

      queue.listenTo.forEach((listen) ->
        {option, listener} = listen
        queueRef.subscribe option, listener
      )


      callback(null, true)

  # When everything's connected, trigger the final callback
  _done:() ->

    msg =
      queues      : {}
      exchanges   : {}
      connection  : @conn

    for k,v of @_queues.index()
      msg.queues[k] = v.ref

    for k,v of @_exchanges.index()
      msg.exchanges[k] = v.ref

    @_callback(null, msg)
