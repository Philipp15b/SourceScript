ParseTreeVisitor = require '../parse-tree-visitor'

# Variables
class VariableDeclaration
  constructor: (@name, @id) ->

class VariableCollector extends ParseTreeVisitor
  getVariableDeclaration = (block, name) ->
    if block.variableDeclarations?
      return declaration for declaration in block.variableDeclarations when declaration.name is name
    if block.parent?
      getVariableDeclaration block.parent, name
    else
      null
      
  constructor: (@variableIndex) ->

  visitVariableAssignment: (assignment) ->
    declaration = getVariableDeclaration(assignment.parent, assignment.name)
    unless declaration?
      declaration = new VariableDeclaration(assignment.name, @variableIndex++)
      assignment.parent.variableDeclarations ?= []
      assignment.parent.variableDeclarations.push declaration

    assignment.id = declaration.id
    
  visitIfStatement: (ifStatement) ->
    conditionDeclaration = getVariableDeclaration ifStatement.parent, ifStatement.condition.condition
    unless conditionDeclaration?
      throw new Error "Variable #{ifStatement.condition.condition} is not declared in line #{ifStatement.line}, column #{ifStatement.column}"
    ifStatement.condition.id = conditionDeclaration.id

# Assigns variable declarations to the parent block of the
# declaration.
# Returns the current variable index.
module.exports.collectVariableDeclarations = (ast, variableIndex = 0) ->
  collector = new VariableCollector variableIndex
  collector.visit ast
  collector.variableIndex


# Functions
class FunctionCollector extends ParseTreeVisitor
  functionDeclarations: {}

  visitFunctionDeclaration: (declaration) ->
    @functionDeclarations[declaration.name] = declaration

# Returns an object of the function declarations in the
# given AST.
module.exports.getFunctionDeclarations = (ast) ->
  collector = new FunctionCollector
  collector.visit ast
  collector.functionDeclarations
