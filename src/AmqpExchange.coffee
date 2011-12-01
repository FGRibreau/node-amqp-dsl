# AMQP Exchange class for AMQP DSL
module.exports = class AmqpExchange

  # * `exchange( name, options )`
  # * `exchange( name, callback(exchange) )`
  # * `exchange( name, options, callback(exchange) )`
  constructor:( @name, options, openCallback) ->
    if !@name
      throw new Error("Exchange must have a name")

    @options = {}
    @openCallback = ->

    if typeof options == "function"
      @openCallback = options
    else if typeof options == "object"
      @options = options

    if typeof openCallback == "function"
      @openCallback = openCallback
    
    # Real reference to an AQMP::Exchange object
    @ref = null
