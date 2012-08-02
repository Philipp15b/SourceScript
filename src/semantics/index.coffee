ParseTreeVisitor = require '../parse-tree-visitor'
VariableCollector = require './variable-collector'

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

# Adds semantics to an AST by running all the visitors
# on the tree.
module.exports = (ast) ->
  for visitor in [new ParentBlockPropertyAssigner, new VariableCollector]
    visitor.visitAny ast
  ast
