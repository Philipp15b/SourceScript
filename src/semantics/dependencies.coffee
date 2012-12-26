ParseTreeVisitor = require '../parse-tree-visitor'

class DependencyAnalyzer extends ParseTreeVisitor
  constructor: ->
    @includes = []

  visitCommand: (assignment) ->
    if assignment.name is "include"
      unless assignment.args?.length is 1
        throw new Error "include declaration must have exactly one parameter!"
      unless assignment.args[0].substring? # check if it is a string
        throw new Error "include declaration must have a string as parameter!"
      @includes.push assignment.args[0]

module.exports = setDependencies = (ast, files) ->
  analyzer = new DependencyAnalyzer()
  analyzer.visit ast

  filescope = ast.scope
  for include in analyzer.includes
    unless files[include]?
      throw new Error "Could not find dependency #{include}!"
    filescope.dependencies.push files[include].scope
