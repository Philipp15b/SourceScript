{Block, Assignment, Variable} = require './nodes'
CompilerError = require './error'

module.exports =
  # The Scope class is responsible for managing variable declarations on Block level.
  Scope: class Scope
    class @VariableDeclaration
      constructor: (@name, @id) ->

    constructor: (@parent, @block, @global) ->
      unless @global?
        @global = if @parent? then @parent.global else new GlobalScope
      @variables = {}

    declareVariable: (name) ->
      @variables[name] = new Scope.VariableDeclaration(name, @global.nextVariableIndex())

    variable: (name) ->
      if @variables[name]? then @variables[name]
      else @parent?.variable name

  GlobalScope: class GlobalScope
    constructor: ->
      @variableIndex = 0

    nextVariableIndex: ->
      @variableIndex++

  # Assign scope object to each Block and check for
  # correct variable declarations.
  assignScopes: (ast, globalScope) ->
    ast.scope = scope = new Scope null, ast, globalScope
    ast.traverse (node) ->
      if node instanceof Block
        node.scope = scope = new Scope scope, node, globalScope
        @traverse node
        scope = node.scope.parent
      else if node instanceof Assignment
        return unless node.variable.local
        unless scope.variable(node.variable.name)?
          scope.declareVariable node.variable.name
      else if node instanceof Variable
        return unless node.local
        unless scope.variable node.name
          throw new CompilerError "Variable $#{node.name} is not declared", node
