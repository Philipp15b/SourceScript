ParseTreeVisitor = require '../parse-tree-visitor'
{GlobalScope, createScopes} = require './scope'
setDependencies = require './dependencies'

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

module.exports = (ast, files, globalScope = new GlobalScope) ->
  pbpa = new ParentBlockPropertyAssigner
  pbpa.visit ast
  createScopes ast, globalScope
  setDependencies ast, files
