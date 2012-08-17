_ = require 'underscore'

module.exports =
   every: (num, array) ->
    return _.map array, (nested) ->
      nested[num]
