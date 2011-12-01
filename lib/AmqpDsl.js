(function() {
  var AmqpDsl, AmqpExchange, AmqpQueue, IndexedList, async;
  var __slice = Array.prototype.slice;

  async = require('async');

  IndexedList = require('./IndexedList');

  AmqpQueue = require('./AmqpQueue');

  AmqpExchange = require('./AmqpExchange');

  module.exports = AmqpDsl = (function() {
    var LISTENNERS;

    LISTENNERS = ['error', 'close', 'ready'];

    AmqpDsl.login = function(opt) {
      if (opt == null) opt = {};
      return new AmqpDsl(opt);
    };

    function AmqpDsl(opt) {
      if (opt == null) opt = {};
      this._login = '';
      this._password = '';
      this._host = '';
      this._port = 5672;
      this._vhost = '/';
      this._conn = null;
      this._callback = function() {};
      opt.login && (this._login = opt.login);
      opt.password && (this._password = opt.password);
      opt.host && (this._host = opt.host);
      opt.port && (this._port = opt.port);
      opt.vhost && (this._vhost = opt.vhost);
      opt.login && (this._login = opt.login);
      this._events = {};
      this._exchanges = new IndexedList();
      this._queues = new IndexedList();
    }

    AmqpDsl.prototype.on = function(event, listener) {
      if (!~LISTENNERS.indexOf(event)) {
        throw new Error("Event '" + event + "' is invalid");
      }
      if (!this._events[event]) this._events[event] = [];
      this._events[event].push(listener);
      return this;
    };

    AmqpDsl.prototype.exchange = function(name, options, openCallback) {
      this._exchanges.set(name, new AmqpExchange(name, options, openCallback));
      return this;
    };

    AmqpDsl.prototype.queue = function(name, options, openCallback) {
      this._queues.set(name, new AmqpQueue(name, options, openCallback));
      return this;
    };

    AmqpDsl.prototype.subscribe = function(options, messageListener) {
      var queue;
      queue = this._queues.last();
      if (!queue) throw new Error("At least one queue must be declared");
      queue.subscribe(options, messageListener);
      return this;
    };

    AmqpDsl.prototype.bind = function(name, routingKey) {
      var queue;
      queue = this._queues.last();
      if (!queue) throw new Error("At least one queue must be declared");
      queue.bind(name, routingKey);
      return this;
    };

    AmqpDsl.prototype.connect = function(amqp, _callback) {
      this._callback = _callback;
      if (typeof amqp === "function") {
        this._callback = amqp;
        amqp = require('amqp');
      }
      this._connect(amqp);
      return null;
    };

    AmqpDsl.prototype._connect = function(amqp) {
      var event, _results;
      var _this = this;
      this.conn = amqp.createConnection({
        host: this._host,
        port: this._port,
        login: this._login,
        password: this._password,
        vhost: this._vhost
      });
      this.on('ready', function() {
        return _this._connectExchanges(_this._connectQueues.bind(_this));
      });
      _results = [];
      for (event in this._events) {
        _results.push(this.conn.on(event, this._getListenerFor(event)));
      }
      return _results;
    };

    AmqpDsl.prototype._getListenerFor = function(event) {
      var _this = this;
      if (this._events[event].length === 1) {
        return this._events[event][0];
      } else {
        return function() {
          var args, listener, _i, _len, _ref;
          args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
          _ref = _this._events[event];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            listener = _ref[_i];
            listener.apply(null, args);
          }
          return true;
        };
      }
    };

    AmqpDsl.prototype._connectExchanges = function(next) {
      var _this = this;
      return async.forEach(this._exchanges.list(), this._connectExchange.bind(this), function(err) {
        if (err) {
          throw new Error("Couldn't connect to the exchanges: " + err.message);
          return;
        }
        return next();
      });
    };

    AmqpDsl.prototype._connectExchange = function(exchange, callback) {
      return this.conn.exchange(exchange.name, exchange.options, function(exchangeRef) {
        exchange.ref = exchangeRef;
        exchange.openCallback(exchangeRef);
        return callback(null, true);
      });
    };

    AmqpDsl.prototype._connectQueues = function() {
      var _this = this;
      return async.forEach(this._queues.list(), this._connectQueue.bind(this), function(err) {
        if (err) {
          throw new Error("Couldn't connect to the queues: " + err.message);
          return;
        }
        return _this._done();
      });
    };

    AmqpDsl.prototype._connectQueue = function(queue, callback) {
      return this.conn.queue(queue.name, queue.options, function(queueRef) {
        queue.ref = queueRef;
        queue.openCallback(queueRef);
        if (queue.exchangeName) {
          queueRef.bind(queue.exchangeName, queue.routingKey);
        }
        if (queue.messageListener) {
          queueRef.subscribe(queue.sOptions, queue.messageListener);
        }
        return callback(null, true);
      });
    };

    AmqpDsl.prototype._done = function() {
      var k, msg, v, _ref, _ref2;
      msg = {
        queues: {},
        exchanges: {},
        connection: this.conn
      };
      _ref = this._queues.index();
      for (k in _ref) {
        v = _ref[k];
        msg.queues[k] = v.ref;
      }
      _ref2 = this._exchanges.index();
      for (k in _ref2) {
        v = _ref2[k];
        msg.exchanges[k] = v.ref;
      }
      return this._callback(null, msg);
    };

    return AmqpDsl;

  })();

}).call(this);
