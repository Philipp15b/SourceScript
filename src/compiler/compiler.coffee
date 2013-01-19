ParseTreeVisitor = require '../parse-tree-visitor'

module.exports = class Compiler extends ParseTreeVisitor
  # The compiled source code.
  compiled: ""

  # If the current expression is inline, for example
  # aliases.
  isInline: false

  # Utility methods
  write: (text) ->
    @compiled += text

  writeln: (text) ->
    @write text
    if @inline
      @write ' '
    else
      @write '\n'

  writeAlias: (name, content = "") ->
    if content.type is "Block"
      @write "alias #{name} \""
      @visitBlockInline content
      @writeln '";'
    else
      @writeln "alias #{name} \"#{content}\";"

  visitBlockInline: (tree) ->
    inlineBefore = @inline
    @inline = true

    @visitBlock tree

    unless inlineBefore
      @inline = false

  # Actual node type handlers
  visitVariableAssignment: (assignment) ->
    expression = switch assignment.expression
      when true then "TrueHook;"
      when false then "FalseHook;"

    declaration = unless assignment.name.charAt(0) is '$'
       assignment.parent.scope.variable assignment.name
    else
      {id: "", name: assignment.name.substr(1)}

    @writeAlias "var_#{declaration.id}_#{declaration.name}", expression

  visitFunctionDeclaration: (declaration) ->

  visitEnumerationDeclaration: (declaration) ->
    name = declaration.name
    @writeAlias name, "#{name}_0"

    # Write all statements from first to next-to-last
    for block, i in declaration.content[0..-2]
      @write "alias #{name}_#{i} \""
      @visitBlockInline block
      @write "alias #{name} \"#{name}_#{i + 1}\"" # set enum function to next item
      @writeln "\";"

    # Write last statement
    @write "alias #{name}_#{declaration.content.length - 1} \""
    @visitBlockInline declaration.content.slice(-1)[0]
    @write "alias #{name} \"#{name}_0\""  # set enum function to first item
    @writeln "\";"

  visitIfStatement: (ifStatement) ->
    @writeAlias "TrueHook", ifStatement.if
    @writeAlias "FalseHook", ifStatement.else

    name = ifStatement.condition.condition
    declaration = unless name.charAt(0) is '$'
      ifStatement.parent.scope.variable name
    else
      {id: "", name: name.substr(1)}
    @writeln "var_#{declaration.id}_#{declaration.name};"

  visitCommand: (command) ->
    @write command.name
    for arg in command.args
      if arg.type?
        @write " \""
        @visitBlockInline arg
        @write "\""
      else
        @write " \"#{arg}\""
    @writeln ';'

  visitComment: (comment) ->
    unless @inline
      @write "\n//#{comment.content}\n"
