ParseTreeTransformer = require '../parse-tree-transformer'
nodes = require '../syntax/nodes'
{Scope} = require '../semantics/scope'

ALIAS = (name, content) -> new nodes.Command "alias", [name, content], false
VARNAME = (scope, name) ->
  declaration = unless name.charAt(0) is '$'
    v = scope.variable name
    unless v?
      throw new Error "Could not find variable #{name}!"
    "var_#{v.id}_#{v.name}"
  else
    "var_#{name.substr(1)}"
FUNC = (filescope, name, call) ->
  func = filescope.function name
  unless func?
    throw new Error "Could not find function with name #{name} in line #{call.line}, column #{call.column}!"
  func

module.exports = class Simplifier extends ParseTreeTransformer
  constructor: ->
    # A stack of statements that go into the minus alias of a bind.
    @bindMinusAliasStack = []

  # Replaces a function call with the associated function body.
  # If the bindMinusAliasStack is not empty (which means we are in a bind)
  # and there exist plus and minus functions, the minus alias will be added to the top of
  # the bindMinusAliasStack so that it will be called correctly.
  transformFunctionCall: (call) ->
    filescope = call.parent.scope.file()
    unless call.name.charAt(0) is '+'
      @transformBlock FUNC(filescope, call.name, call).body
    else
      base = call.name.slice 1
      normalized = base.replace /:/g, '_' # replace colons with underscores because they're not allowed.

      plus = @transformBlock FUNC(filescope, "+#{normalized}", call).body
      minus = @transformBlock FUNC(filescope, "-#{normalized}", call).body

      statements = []

      if @bindMinusAliasStack.length > 0
        statements = statements.concat plus.statements
        @bindMinusAliasStack[@bindMinusAliasStack.length-1] = @bindMinusAliasStack[@bindMinusAliasStack.length-1].concat minus.statements
      else
        # if we are not directly in a bind, we just generate auxiliary aliases
        statements.push ALIAS "+#{normalized}", plus
        statements.push ALIAS "-#{normalized}", minus
        statements.push new nodes.Command "+#{normalized}", []

      new nodes.Block statements

  transformCommand: (cmd) ->
    if cmd.name is "include"
      undefined
    else if cmd.name is "bind" and cmd.args[1]?.type is "Block"
      aliasBase = "_bind_#{Scope.global.nextVariableIndex()}"

      @bindMinusAliasStack.push []
      cmd = super cmd
      minusAliasStatements = @bindMinusAliasStack.pop()

      repl = [ALIAS "+#{aliasBase}", cmd.args[1]]
      if minusAliasStatements.length > 0 # only create minus alias when necessary.
        repl.push ALIAS "-#{aliasBase}", new nodes.Block minusAliasStatements
      cmd.args[1] = "+#{aliasBase}"
      repl.push cmd

      new nodes.Block repl
    else
      super cmd

  transformVariableAssignment: (assignment) ->
    expression = switch assignment.expression
      when true then "TrueHook"
      when false then "FalseHook"
    ALIAS VARNAME(assignment.parent.scope, assignment.name), expression

  transformIfStatement: (ifStatement) ->
    ifStatement = super ifStatement

    if ifStatement.condition.isNegated
      [ifStatement.if, ifStatement.else] = [ifStatement.else, ifStatement.if]
      ifStatement.condition.isNegated = false

    new nodes.Block [
      ALIAS "TrueHook", ifStatement.if
      ALIAS "FalseHook", ifStatement.else
      new nodes.Command VARNAME(ifStatement.parent.scope, ifStatement.condition.condition), [], false
    ]

  transformEnumerationDeclaration: (declaration) ->
    declaration = super declaration

    name = declaration.name
    repl = [ALIAS(name, "#{name}_0")]

    for block, i in declaration.content
      nextIndex = (i + 1) % declaration.content.length
      block.statements.push ALIAS(name, "#{name}_#{nextIndex}") # set enum function to next item
      repl.push ALIAS("#{name}_#{i}", block)

    new nodes.Block repl

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
