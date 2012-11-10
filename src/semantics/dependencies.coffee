{normalize} = require 'path'
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
      @includes.push normalize assignment.args[0]

# Returns an array of all files the given ASTs includes,
# the paths are relative to the file.
module.exports = getDependencies = (ast) ->
  analyzer = new DependencyAnalyzer()
  analyzer.visit ast
  analyzer.includes
