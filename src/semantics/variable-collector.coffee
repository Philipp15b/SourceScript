ParseTreeVisitor = require '../parse-tree-visitor'

class VariableDeclaration
  constructor: (@name, @id) ->

module.exports = class VariableCollector extends ParseTreeVisitor
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
