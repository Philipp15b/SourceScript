ParseTreeVisitor = require '../parse-tree-visitor'

NOTALLOWED = (node) -> throw new Error "Node of type #{node.type} is not allowed in the compiler!"

# The compiler is responsible to compile the simplified AST
# to Source Cfg code.
module.exports = class Compiler extends ParseTreeVisitor
  # The compiled source code.
  compiled: ""

  inlineLevel: 0
  isLast: false

  # Utility methods
  write: (text) ->
    @compiled += text

  visitList: (list) ->
    for item, i in list
      @isLast = i is list.length-1
      @visitAny item
    @isLast = false

  visitCommand: (command) ->
    @write command.name
    for arg in command.args
      @write " \""
      if arg.type is "Block"
        @inlineLevel++
        @visitBlock arg
        @inlineLevel--
      else
        @write arg
      @write "\""

    # write the delimiter
    if @inlineLevel is 0
      @write ';\n'
    else if not @isLast
      @write '; '

  visitComment: (comment) ->
    if @inlineLevel is 0
      @write "\n//#{comment.content}\n"

  visitVariableAssignment: NOTALLOWED
  visitFunctionDeclaration: NOTALLOWED
  visitEnumerationDeclaration: NOTALLOWED
  visitIfStatement: NOTALLOWED
