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
    # Only mark global variables
    if assignment.name.charAt(0) is '$'
      assignment.name = assignment.name.substr 1
      assignment.id = ""
      return

    declaration = getVariableDeclaration(assignment.parent, assignment.name)
    unless declaration?
      declaration = new VariableDeclaration(assignment.name, @variableIndex++)
      assignment.parent.variableDeclarations ?= []
      assignment.parent.variableDeclarations.push declaration

    assignment.id = declaration.id
    
  visitIfStatement: (ifStatement) ->
    super ifStatement
    condition = ifStatement.condition
    if condition.condition.charAt(0) is '$'
      condition.condition = condition.condition.substr 1
      condition.id = ""
    else
      conditionDeclaration = getVariableDeclaration ifStatement.parent, condition.condition
      unless conditionDeclaration?
        throw new Error "Variable #{condition.condition} is not declared in line #{ifStatement.line}, column #{ifStatement.column}"
      condition.id = conditionDeclaration.id

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
