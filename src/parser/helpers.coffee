module.exports =
  every: (num, arr) -> e[num] for e in arr

  filterProgram: (program) ->
    result = []
    for cmd in program
      result.push cmd[0]
      if cmd[1] isnt ""
        result.push cmd[1]
    result
