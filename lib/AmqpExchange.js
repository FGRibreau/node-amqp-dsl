(function() {
  var AmqpExchange;

  module.exports = AmqpExchange = (function() {

    function AmqpExchange(name, options, openCallback) {
      this.name = name;
      if (!this.name) throw new Error("Exchange must have a name");
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

    return AmqpExchange;

  })();

}).call(this);
