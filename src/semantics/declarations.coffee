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

  variableIndex: 0

  visitVariableAssignment: (assignment) ->
    declaration = getVariableDeclaration(assignment.parent, assignment.name)
    unless declaration?
      declaration = new VariableDeclaration(assignment.name, @variableIndex++)
      assignment.parent.variableDeclarations ?= []
      assignment.parent.variableDeclarations.push declaration

    assignment.id = declaration.id

# Assigns variable declarations to the parent block of the
# declaration.
module.exports.collectVariableDeclarations = (ast) ->
  collector = new VariableCollector
  collector.visit ast
  ast


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
