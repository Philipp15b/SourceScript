ParseTreeTransformer = require '../parse-tree-transformer'
nodes = require '../syntax/nodes'
{Scope} = require '../semantics/scope'

CMD = (name, args...) -> new nodes.Command name, args, false
ALIAS = (name, content) -> new nodes.Command "alias", [name, content], false
VARNAME = (node, scope, name) ->
  declaration = unless name.charAt(0) is '$'
    v = scope.variable name
    unless v?
      throw new Error "Could not find variable #{name} in line #{node.line}, column #{node.column}!"
    "var_#{v.id}_#{v.name}"
  else
    "var_#{name.substr(1)}"
FUNC = (node, filescope, name) ->
  func = filescope.function name
  unless func?
    throw new Error "Could not find function #{name} in line #{node.line}, column #{node.column}!"
  func

module.exports = class Simplifier extends ParseTreeTransformer
  constructor: ->
    # A list of statements that will be inserted before the current block.
    # Null if top-level.
    @preBlock = null
    # A stack of statements that are inserted so that they will be called when
    # the key that the alias is bound to is released, the associated statements are called.
    @bindMinusStatementStack = []

  # This extracts a block from the second argument of a command and
  # moves the block's contents into an a auxiliary alias in @preBlock.
  extractBlock: (cmd, name) ->
    statements = cmd.args[1].statements
    if (statements.length is 1 and statements[0].type is "Command") or statements.length is 0
      # Source Cfg allows single statement blocks in nested commands.
      return Simplifier.__super__.transformCommand.call(this, cmd)
    @preBlock.push ALIAS(name, @transformBlock(cmd.args[1]))
    cmd.args[1] = new nodes.Block [CMD name]
    cmd

  # This works as above, but it also adds the statements of the top of
  # the bindMinusStatementStack to @preBlock.
  extractBind: (bind) ->
    tempBase = "_bind_#{Scope.global.nextVariableIndex()}"
    @bindMinusStatementStack.push []
    caller = @extractBlock bind, "+#{tempBase}"
    minusStatements = @bindMinusStatementStack.pop()
    if minusStatements.length isnt 0
       @preBlock.push ALIAS("-#{tempBase}", new nodes.Block @transformList(minusStatements))
    caller

  transformCommand: (cmd) ->
    if cmd.name is "include"
      undefined
    else if cmd.args[1]?.type is "Block"
      if @preBlock is null  # if we're on the top level
        @preBlock = []

        @preBlock.push if cmd.name is "bind"
          @extractBind cmd
        else
          super cmd
        statements = @preBlock
        @preBlock = null
        statements

      else if cmd.name is "alias" # we've got a nested alias
        @extractBlock cmd, "_alias_#{Scope.global.nextVariableIndex()}"
      else if cmd.name is "bind" # we've got a nested bind
        @extractBind cmd
      else
        super cmd
    else
      super cmd

  transformFunctionCall: (call) ->
    filescope = call.parent.scope.file()
    unless call.name.charAt(0) is '+'
      @transformList FUNC(call, filescope, call.name).body.statements
    else
      base = call.name.slice 1
      normalized = "func_#{base.replace /:/g, '_'}" # replace colons with underscores because they're not allowed.

      plus = @transformBlock FUNC(call, filescope, "+#{base}").body
      minus = @transformBlock FUNC(call, filescope, "-#{base}").body

      if @preBlock?
        @preBlock.push ALIAS("+#{normalized}", plus)
        @preBlock.push ALIAS("-#{normalized}", minus)
        CMD "+#{normalized}"
      else
        @transformList [
          ALIAS "+#{normalized}", plus
          ALIAS "-#{normalized}", minus
          CMD "+#{normalized}"
        ]

  transformVariableAssignment: (assignment) ->
    expression = switch assignment.expression
      when true then "TrueHook"
      when false then "FalseHook"
    @transformCommand ALIAS VARNAME(assignment, assignment.parent.scope, assignment.name), expression

  transformIfStatement: (ifStatement) ->
    ifStatement = super ifStatement

    if ifStatement.condition.isNegated
      [ifStatement.if, ifStatement.else] = [ifStatement.else, ifStatement.if]
      ifStatement.condition.isNegated = false

    @transformList [
      ALIAS "TrueHook", ifStatement.if ? ""
      ALIAS "FalseHook", ifStatement.else ? ""
      CMD VARNAME(ifStatement, ifStatement.parent.scope, ifStatement.condition.condition)
    ]

  transformEnumerationDeclaration: (declaration) ->
    declaration = super declaration

    name = declaration.name
    repl = [ALIAS name, "#{name}_0"]

    for block, i in declaration.content
      nextIndex = (i + 1) % declaration.content.length
      block.statements.push ALIAS(name, "#{name}_#{nextIndex}") # set enum function to next item
      repl.push ALIAS("#{name}_#{i}", block)

    @transformList repl

  blockDepth: -1

  transformBlock: (block) ->
    @blockDepth++
    block = super block
    @blockDepth--
    block

  transformComment: (comment) ->
    return undefined if @blockDepth > 0
    super comment

  transformFunctionDeclaration: ->
    undefined
