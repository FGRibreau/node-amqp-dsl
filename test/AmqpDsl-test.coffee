#!/usr/bin/env node

vows = require("vows")
assert = require("assert")

AmqpDsl = require("../")

suite = vows.describe("AmqpDsl test")
suite.options.error = true


suite.addBatch
  ".login":
    topic: -> AmqpDsl

    "runs without issue": (cc) ->
      assert.isObject cc.login()
      assert.instanceOf cc.login(), AmqpDsl

    "save options": (cc) ->
      amqpdsl = cc.login(
        login:'l'
        password:'p'
        host:'h'
        port:10
        vhost:'v'
      )

      assert.equal amqpdsl._login, 'l'
      assert.equal amqpdsl._password, 'p'
      assert.equal amqpdsl._host, 'h'
      assert.equal amqpdsl._port, 10
      assert.equal amqpdsl._vhost, 'v'

  ".on":
    topic: -> AmqpDsl.login()

    "No events by default": (cc) ->
      assert.equal Object.keys(cc._events).length, 0

    "can add listener": (cc) ->
      a = () -> "ok"
      cc.on('ready', a)

      assert.equal cc._events['ready'].length, 1

      assert.equal cc._events['ready'][0], a

    "can't add listen to unsupported event":(cc) ->
      assert.throws () ->
        cc.on('unsupported', () ->)

    "allow multiple listener to the same event":(cc) ->

      cc.on('ready', () -> "ok2")

      assert.equal cc._events['ready'].length, 2

  ".exchange":
    topic: -> AmqpDsl.login()

    "No exchange by default": (cc)->
      assert.equal cc._exchanges.length(), 0

    "Accept (name, options)":(cc)->

      cc.exchange("exchg1", a:true)

      assert.equal cc._exchanges.last().name, "exchg1"
      assert.equal cc._exchanges.last().options.a, true

    "Accept (name, callback)":(cc)->
      a = () -> false

      cc.exchange("exchg2", a)

      assert.equal cc._exchanges.length(), 2
      assert.equal cc._exchanges.last().name, "exchg2"
      assert.equal cc._exchanges.last().openCallback, a

    "Accept (name, options, callback)":(cc)->
      a = () -> false

      cc.exchange "exchg3", {b:false}, a

      assert.equal cc._exchanges.length(), 3
      assert.equal cc._exchanges.last().name, "exchg3"
      assert.equal cc._exchanges.last().options.b, false
      assert.equal cc._exchanges.last().openCallback, a


  "queue":
    topic: -> AmqpDsl.login()

    "No queue by default": (cc)->
      assert.equal cc._queues.length(), 0

    "Accept (name, options)":(cc)->

      cc.queue("queue1", a:true)

      assert.equal cc._queues.last().name, "queue1"
      assert.equal cc._queues.last().options.a, true

    "Accept (name, callback)":(cc)->
      a = () -> false

      cc.queue("queue2", a)

      assert.equal cc._queues.length(), 2
      assert.equal cc._queues.last().name, "queue2"
      assert.equal cc._queues.last().openCallback, a

    "Accept (name, options, callback)":(cc)->
      a = () -> false

      cc.queue "queue3", {b:false}, a

      assert.equal cc._queues.length(), 3
      assert.equal cc._queues.last().name, "queue3"
      assert.equal cc._queues.last().options.b, false
      assert.equal cc._queues.last().openCallback, a


  "subscribe":
    topic: -> AmqpDsl.login()

    "Throw an error if no queue were declared":(cc) ->
      assert.equal cc._queues.length(), 0

      assert.throws () ->
        cc.subscribe(() ->)

    "Accept subscribe( callback )":(cc) ->
      fn = () -> throw new Error("ok")
      cc
        .queue("queue")
        .subscribe(fn)

      queue = cc._queues.last()
      assert.deepEqual queue.listenTo[0], [{}, fn]

    "Accept subscribe( option, callback )":(cc) ->
      fn = () -> throw new Error("ok")
      cc
        .queue("queue2")
        .subscribe(ack:true, fn)

      queue = cc._queues.last()
      assert.deepEqual queue.listenTo[0], [{ack:true}, fn]


  "bind":
    topic: -> AmqpDsl.login()

    "Accept (name, routingKey)":(cc)->
      cc
        .queue("queue")
        .bind("exch1", "#")
        .bind("exch2", "#rk2")

      queue = cc._queues.last()
      assert.deepEqual queue.bindTo[0], ["exch1", "#"]
      assert.deepEqual queue.bindTo[1], ["exch2", "#rk2"]


  "connect":
    topic: -> AmqpDsl.login()

    "Accept ( callback )": (cc)->

      cc._connect = (amqp) ->
        assert.equal amqp, require('amqp')

      cc.connect(->)

    "Accept ( amqp,  callback )": (cc)->

      cc._connect = (amqp) -> assert.isTrue amqp

      cc.connect(true, ->)


  "(private) _connect":
    topic: -> AmqpDsl.login()

  "(private) _getListenerFor":
    topic: -> AmqpDsl.login()

    "get listener for a single listener":(cc) ->
      a = () -> throw new Error("ok1")

      cc.on('error', a)

      assert.equal cc._getListenerFor('error'), a

    "get listener for multiple listener":(cc) ->
      b = () -> assert.ok true

      cc.on('error', b)

      assert.equal cc._events['error'].length, 2

      assert.notEqual cc._getListenerFor('error'), b

      assert.throws () ->
        cc._getListenerFor('error')()
      , "ok1"


  "(private) _connectExchanges":
    topic: -> AmqpDsl.login()

    "#todo":(cc) ->

  "(private) _connectExchange":
    topic: -> AmqpDsl.login()

    "#todo":(cc) ->

  "(private) _connectQueues":
    topic: -> AmqpDsl.login()

    "#todo":(cc) ->

  "(private) _connectQueue":
    topic: -> AmqpDsl.login()

    "#todo":(cc) ->

  "(private) _done":
    topic: -> AmqpDsl.login()

    "#todo":(cc) ->


if process.argv[1] == __filename
  suite.run()
else
  suite.export module
