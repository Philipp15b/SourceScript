ParseTreeTransformer = require '../parse-tree-transformer'

module.exports = class Simplifier extends ParseTreeTransformer

  functionDeclarations: {}
  
  transform: (tree) ->
    tree = super(tree)
    tree.functionDeclarations = @functionDeclarations
    tree

  # Simplify negated if statement
  transformIfStatement: (ifStatement) ->
    if ifStatement.condition.isNegated
      [ifStatement.if, ifStatement.else] = [ifStatement.else, ifStatement.if]
      delete ifStatement.condition.isNegated
    ifStatement

  transformFunctionDeclaration: (declaration) ->
    declaration = super(declaration)
    @functionDeclarations[declaration.name] = declaration
    undefined
