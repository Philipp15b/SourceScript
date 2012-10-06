_ = require 'underscore'

module.exports =
  every: (num, array) ->
    return _.map array, (nested) ->
      nested[num]

  filterProgram: (program) ->
    result = []
    for cmd in program
      result.push cmd[0]
      if cmd[1] isnt ""
        result.push cmd[1]
    result