ParseTreeTransformer = require './parse-tree-transformer'

module.exports = class Simplifier extends ParseTreeTransformer

  # Simplify negated if statement
  transformIfStatement: (ifStatement) ->
    if ifStatement.condition.isNegated
      [ifStatement.if, ifStatement.else] = [ifStatement.else, ifStatement.if]
      delete ifStatement.condition.isNegated
    ifStatement
