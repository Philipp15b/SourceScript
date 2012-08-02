module.exports = class ParseTreeTransformer
  transformAny: (tree) ->
    throw new Error("No tree given!") if !tree? or tree == undefined
    @["transform#{tree.type}"](tree)

  transform: (tree) ->
    @transformAny tree
    tree

  transformList: (list) ->
    @transformAny item for item in list
    list

  transformBlock: (block) ->
    @transformList block.statements
    block

  transformVariableAssignment: (assignment) ->
    assignment

  transformFunctionDeclaration: (declaration) ->
    @transformBlock declaration.body
    declaration

  transformFunctionCall: (call) ->
    call

  transformIfStatement: (ifStatement) ->
    @transformCondition ifStatement.condition
    if ifStatement.if?
      @transformBlock ifStatement.if
    if ifStatement.else?
      @transformBlock ifStatement.else
    ifStatement

  transformCondition: (condition) ->

  transformCommand: (command) ->
    command

  transformComment: (comment) ->

