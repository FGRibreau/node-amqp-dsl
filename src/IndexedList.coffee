# Helper class for rapid access (create/append/read only)
module.exports = class IndexedList

  constructor:() ->
    @_index = {}
    @_list = []

  get: ( key ) ->
    @_index[key] or false
  
  set: ( key, value ) ->
    @_list.push(value)
    @_index[key] = value
    null
  
  length: ->
    @_list.length
  
  last:() ->
    @_list[@_list.length-1] or false
  
  index:() ->
    @_index
  
  list:() ->
    @_list