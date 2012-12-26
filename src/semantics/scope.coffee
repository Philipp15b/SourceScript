ParseTreeVisitor = require '../parse-tree-visitor'

# The Scope class is responsible for managing variable declarations on Block level.
module.exports.Scope = class Scope
  class @VariableDeclaration
    constructor: (@name, @id) ->

  @global: null

  constructor: (@parent, @block) ->
    @variables = []

  file: ->
    @parent?.file()

  declareVariable: (name) ->
    @variables.push new Scope.VariableDeclaration(name, Scope.global.nextVariableIndex())

  variable: (name) ->
    for variable in @variables
      if variable.name is name
        return variable
    @parent?.variable name

# The FileScope is responsible for managing variable declarations
# and function declarations on the root Block level (aka file level).
# It also resolves functions via dependency scopes from other files.
module.exports.FileScope = class FileScope extends Scope
  constructor: (block) ->
    super undefined, block
    @functions = {}
    @dependencies = []

  file: ->
    this

  declareFunction: (name, node) ->
    @functions[name] = node

  function: (name) ->
    if @functions[name]?
      @functions[name]
    else
      for dependency in @dependencies
        if dependency.function(name)?
          return dependency.function name
      undefined

# The GlobalScope is only responsible for the variable index.
module.exports.GlobalScope = class GlobalScope
  constructor: ->
    @variableIndex = 0

  nextVariableIndex: ->
    @variableIndex++

class ScopeManager extends ParseTreeVisitor
  root: yes

  visitBlock: (block) ->
    block.scope = if @root
      @root = no
      new FileScope block
    else
      new Scope block.parent.scope, block
    super block

  visitVariableAssignment: (assignment) ->
    return if assignment.name.charAt(0) is '$' # global variables don't need to be declared
    scope = assignment.parent.scope
    unless scope.variable(assignment.name)?
      scope.declareVariable assignment.name

  visitIfStatement: (ifStatement) ->
    # This only checks if the variable is already declared
    condition = ifStatement.condition
    return if condition.condition.charAt(0) is '$'
    unless ifStatement.parent.scope.variable(condition.condition)?
      throw new Error "Variable #{condition.condition} is not declared in line #{ifStatement.line}, column #{ifStatement.column}"
    super ifStatement

  visitFunctionDeclaration: (declaration) ->
    filescope = declaration.parent.scope.file()
    unless filescope.function(declaration.name)?
      filescope.declareFunction declaration.name, declaration
    else
      throw new Error "Function #{declaration.name} cannot be redeclared in line #{declaration.line}, column #{declaration.column}"
    super declaration

module.exports.createScopes = (ast, globalScope) ->
  Scope.global = globalScope
  manager = new ScopeManager
  manager.visit ast
