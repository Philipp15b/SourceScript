ParseTreeTransformer = require '../parse-tree-transformer'

module.exports = class Simplifier extends ParseTreeTransformer

  # Creates a new Simplifier
  #
  # @param file The file to be simplified.
  # @param otherFiles (optional) This is an object of files to fetch
  #     imported functions from. (This may also include the currently 
  #     simplified file, because it's not imported.)
  constructor: (@file, @otherFiles = {}) ->

  # ----------------
  # FUNCTIONS
  # ----------------
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
    func = @findFunction call.name
    unless func?
      throw new Error "Could not find function with name #{call.name} in line #{call.line}, column #{call.column}!"
    func.body

  # ----------------
  # OTHERS
  # ----------------
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
