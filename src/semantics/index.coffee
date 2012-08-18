ParseTreeVisitor = require '../parse-tree-visitor'
{getFunctionDeclarations, collectVariableDeclarations} = require './declarations'
getDependencies = require './dependencies'

# Sets the parent property of every node to the parent block.
class ParentBlockPropertyAssigner extends ParseTreeVisitor
  # The block currently processed
  block: null

  visitAny: (node) ->
    if @block?
      node.parent = @block
    super(node)

  visitBlock: (block) ->
    if @block?
      block.parent = @block
    @block = block
    super(block)

# Analyzes the given AST, sets variable declarations in their parent blocks
# and returns an object of metadata of Function Declarations and 
# dependencies for the given AST
module.exports = (ast, variableIndex = 0) ->
  pbpa = new ParentBlockPropertyAssigner
  pbpa.visit ast
  
  variableIndex = collectVariableDeclarations ast, variableIndex
  
  {
    functionDeclarations: getFunctionDeclarations ast
    dependencies: getDependencies ast
    variableIndex: variableIndex
  }
