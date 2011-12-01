#!/usr/bin/env node

vows = require("vows")
assert = require("assert")

IndexedList = require("../src/IndexedList")

suite = vows.describe("IndexedList test")
suite.options.error = true

suite.addBatch "Generic test": 
  topic: ->
    new IndexedList()
  
  "runs without issue": (cc) ->
    assert.isObject cc
  
  "and return false if nothing": (cc) ->
    assert.ok !cc.get("test")

  "should be able to add item": (cc) ->
    assert.isNull cc.set("key", "value")
    assert.equal cc.get("key"), "value"
    assert.equal cc.length(), 1

    assert.equal cc.set("key2", "value2")

    assert.equal cc.last(), "value2"

    assert.deepEqual Object.keys(cc.index()), ["key", "key2"] 
    
    assert.deepEqual cc.list(), ["value", "value2"] 
  

if process.argv[1] == __filename
  suite.run()
else
  suite.export module