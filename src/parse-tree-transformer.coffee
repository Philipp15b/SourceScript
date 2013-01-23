module.exports = class ParseTreeTransformer
  transformAny: (tree) ->
    throw new Error("No tree given!") if !tree? or tree == undefined
    @["transform#{tree.type}"](tree)

  transform: (tree) ->
    @transformAny tree

  transformList: (list) ->
    newlist = []
    for item in list
      if (newitem = @transformAny item)?
        if Array.isArray newitem
          newlist = newlist.concat newitem
        else
          newlist.push newitem
    newlist

  transformBlock: (block) ->
    block.statements = @transformList block.statements
    block

  transformVariableAssignment: (assignment) ->
    assignment

  transformFunctionDeclaration: (declaration) ->
    declaration.body = @transformBlock declaration.body
    declaration

  transformEnumerationDeclaration: (declaration) ->
    declaration.content = @transformList declaration.content
    declaration

  transformFunctionCall: (call) ->
    call

  transformIfStatement: (ifStatement) ->
    ifStatement.condition = @transformCondition ifStatement.condition
    if ifStatement.if?
      ifStatement.if = @transformBlock ifStatement.if
    if ifStatement.else?
      ifStatement.else = @transformBlock ifStatement.else
    ifStatement

  transformCondition: (condition) ->
    condition

  transformCommand: (command) ->
    for arg, i in command.args
      if arg.type?
        command.args[i] = @transformBlock arg
    command

  transformComment: (comment) ->
    comment
