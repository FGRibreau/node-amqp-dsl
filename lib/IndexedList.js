(function() {
  var IndexedList;

  module.exports = IndexedList = (function() {

    function IndexedList() {
      this._index = {};
      this._list = [];
    }

    IndexedList.prototype.get = function(key) {
      return this._index[key] || false;
    };

    IndexedList.prototype.set = function(key, value) {
      this._list.push(value);
      this._index[key] = value;
      return null;
    };

    IndexedList.prototype.length = function() {
      return this._list.length;
    };

    IndexedList.prototype.last = function() {
      return this._list[this._list.length - 1] || false;
    };

    IndexedList.prototype.index = function() {
      return this._index;
    };

    IndexedList.prototype.list = function() {
      return this._list;
    };

    return IndexedList;

  })();

}).call(this);
