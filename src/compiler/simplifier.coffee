ParseTreeTransformer = require '../parse-tree-transformer'
nodes = require '../syntax/nodes'

module.exports = class Simplifier extends ParseTreeTransformer

  # Creates a new Simplifier
  #
  # @param file The file to be simplified.
  # @param otherFiles (optional) This is an object of files to fetch
  #     imported functions from. (This may also include the currently
  #     simplified file, because it's not imported.)
  constructor: (@file, @otherFiles = {}) ->

  findFunction: (name) ->
    # search in functions in this file
    if (declaration = @file.functionDeclarations[name])?
      return declaration

    # search in depended files
    for dependencyName in @file.dependencies
      dependency = @otherFiles[dependencyName]
      unless dependency?
        throw new Error "Could not find dependency #{dependencyName}!"

      if (declaration = dependency.functionDeclarations[name])?
        return declaration

    # function not found
    undefined

  transformFunctionCall: (call) ->
    unless call.name.charAt(0) is '+'
      func = @findFunction call.name
      unless func?
        throw new Error "Could not find function with name #{call.name} in line #{call.line}, column #{call.column}!"
      func.body
    
    # Function calls beginning with a plus need helper aliases so that
    # the associated minus function is correctly called within binds.
    else
      name = call.name.slice 1
      normalized = name.replace /:/g, '_' # replace colons with underscores because they're not allowed.

      # Alias for the + function
      plusFunction = @findFunction "+#{name}"
      unless plusFunction?
        throw new Error "Could not find function with name +#{name} in line #{call.line}, column #{call.column}!"
      plusAlias = new nodes.Command "alias", [
        "+#{normalized}",
        plusFunction.body
      ]

      # Alias for the - function
      minusFunction = @findFunction "-#{name}"
      unless plusFunction?
        throw new Error "Could not find function with name -#{name} in line #{call.line}, column #{call.column}!"
      minusAlias = new nodes.Command "alias", [
        "-#{normalized}",
        minusFunction.body
      ]

      # Command to call the + function.
      callCommand = new nodes.Command("+" + normalized, [])

      # If we are in a bind, then assign the block to
      # the @before property. This is necessary to prepend
      # aliases to the bind. See @transformCommand for more info.
      unless @isInBind
        new nodes.Block [plusAlias, minusAlias, callCommand]
      else
        @before = [plusAlias, minusAlias]
        callCommand

  # Utility properties for special handling of
  # functions that contain + and -. See additional
  # info in @transformCommand.
  before: false
  isInBind: false

  transformCommand: (cmd) ->
    # Remove all include commands, because they are only
    # used by the compiler.
    if cmd.name is "include"
      undefined

    # If the command is a bind, mark it and
    # prepend the value of @before to this command.
    # This is necessary for function calls that contain
    # + and -, because they need aliases which are not allowed
    # within a bind.
    else if cmd.name is "bind"
      wasInBind = @isInBind
      @isInBind = true
      cmd = super cmd
      @isInBind = false unless wasInBind

      @before ?= []
      new nodes.Block @before.concat cmd

    else
      super cmd

  # Simplify negated if statement
  transformIfStatement: (ifStatement) ->
    if ifStatement.condition.isNegated
      [ifStatement.if, ifStatement.else] = [ifStatement.else, ifStatement.if]
      delete ifStatement.condition.isNegated
    ifStatement
