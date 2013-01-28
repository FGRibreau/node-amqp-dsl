# AMQP Queue class for AMQP DSL
module.exports = class AmqpQueue

  # * `queue( name, options )`
  # * `queue( name, callback(queue) )`
  # * `queue( name, options, callback(queue) )`
  constructor:( @name, options, openCallback) ->
    if !@name
      throw new Error("Queue must have a name")

    @options      = {}
    @openCallback = ->
    @bindTo       = []
    @listenTo     = []

    if typeof options == "function"
      @openCallback = options
    else if typeof options == "object"
      @options = options

    if typeof openCallback == "function"
      @openCallback = openCallback

    # Real reference to an AMQP::Queue object
    @ref = null

  # * `.bind( name, routingKey )`
  bind:( exchangeName, routingKey ) ->
    @bindTo.push([exchangeName, routingKey])

  # * `subscribe( callback(message, header, deliveryInfo) )`
  # * `subscribe( options, callback(message, header, deliveryInfo) )`
  subscribe:( options, listener ) ->
    if typeof options == 'function'
      listener = options
      options = {}

    @listenTo.push([options, listener])
