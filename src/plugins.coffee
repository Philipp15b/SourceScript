{Node, Block, Command, Variable, CMD, ASSIGN} = require './nodes'
CompilerError = require './error'

module.exports.run = (ast, plugins) ->
  mapStatement = (statement, mapper) ->
    statement.traverse (statement) ->
      return unless statement instanceof Block
      @traverse false
      statement.mapRecursive mapper

  ast.mapRecursive mapper = (statement) ->
    return statement unless statement instanceof Command and statement.compilercommand
    handler = plugins[statement.name]
    unless handler?
      throw new CompilerError "Could not find compiler command \":#{statement.name}\"", statement

    ret = handler(statement)

    if Array.isArray ret
      for stmt in ret
        mapStatement stmt, mapper
      ret
    else if statement instanceof Node
      mapStatement statement, mapper
      ret
    else if !statement? then undefined
    else throw new Error "Plugin for compiler command \":#{statement.name}\" returned an invalid node!"


module.exports.builtin =
  bind: do ->
    id = 0
    (cmd) ->
      unless cmd.args[0].substr?
        throw new CompilerError "First argument of :bind must be a key", cmd
      unless cmd.args[1] instanceof Block and (cmd.args[2] is undefined or cmd.args[2] instanceof Block)
        throw new CompilerError "Second (and optional third) argument of :bind must be Blocks!", cmd
      cmd.args[2] ?= new Block []
      id++
      [
        ASSIGN "+_bind_#{id}", cmd.args[1]
        ASSIGN "-_bind_#{id}", cmd.args[2]
        CMD "bind", cmd.args[0], "+_bind_#{id}"
      ]

  "enum": (cmd) ->
    name = cmd.args[0]
    unless name.substr?
      throw new CompilerError "First :enum argument must be a name", cmd

    repl = [ASSIGN name, new Block [
      CMD "#{name}_0"
    ]]
    for arg, i in cmd.args[1..]
      unless arg instanceof Block
        throw new CompilerError ":enum arguments must be Blocks", cmd

      # set enum to next item
      nextIndex = (i + 1) % (cmd.args.length-1)
      arg.statements.push ASSIGN name, new Block [
        CMD "#{name}_#{nextIndex}"
      ]

      repl.push ASSIGN "#{name}_#{i}", arg

    repl
