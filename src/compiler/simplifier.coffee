ParseTreeTransformer = require '../parse-tree-transformer'

module.exports = class Simplifier extends ParseTreeTransformer

  constructor: (@filename, @fileMetadata) ->

  functionDeclarations: {}

  findFunction: (name) ->
    # search in functions in this file
    if (declaration = @fileMetadata[@filename].functionDeclarations[name])?
      return declaration

    # search in depended files
    for filename in @fileMetadata[@filename].dependencies
      file = @fileMetadata[filename]
      if (declaration = file.functionDeclarations[name])?
        return declaration

    # function not found
    undefined

  transformFunctionCall: (call) ->
    func = @findFunction call.name
    unless func?
      throw new Error "Could not find function with name #{call.name} in line #{call.line}, column #{call.column}!"
    func.body

  transformCommand: (assignment) ->
    unless assignment.name is "include"
      assignment
    else
      undefined

  # Simplify negated if statement
  transformIfStatement: (ifStatement) ->
    if ifStatement.condition.isNegated
      [ifStatement.if, ifStatement.else] = [ifStatement.else, ifStatement.if]
      delete ifStatement.condition.isNegated
    ifStatement
