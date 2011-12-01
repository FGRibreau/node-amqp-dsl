(function() {
  var AmqpQueue;

  module.exports = AmqpQueue = (function() {

    function AmqpQueue(name, options, openCallback) {
      this.name = name;
      if (!this.name) throw new Error("Queue must have a name");
      this.options = {};
      this.openCallback = function() {};
      if (typeof options === "function") {
        this.openCallback = options;
      } else if (typeof options === "object") {
        this.options = options;
      }
      if (typeof openCallback === "function") this.openCallback = openCallback;
      this.ref = null;
    }

    AmqpQueue.prototype.bind = function(exchangeName, routingKey) {
      this.exchangeName = exchangeName;
      this.routingKey = routingKey;
    };

    AmqpQueue.prototype.subscribe = function(sOptions, messageListener) {
      this.sOptions = sOptions;
      this.messageListener = messageListener;
      if (typeof this.sOptions === 'function') {
        this.messageListener = this.sOptions;
        return this.sOptions = {};
      }
    };

    return AmqpQueue;

  })();

}).call(this);
