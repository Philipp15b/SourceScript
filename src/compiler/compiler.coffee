ParseTreeVisitor = require '../parse-tree-visitor'

NOTALLOWED = (node) -> throw new Error "Node of type #{node.type} is not allowed in the compiler!"

# The compiler is responsible to compile the simplified AST
# to Source Cfg code.
module.exports = class Compiler extends ParseTreeVisitor
  constructor: ->
    @isLastStack = []

  # The compiled source code.
  compiled: ""

  # Utility methods
  write: (text) ->
    @compiled += text

  visitList: (list) ->
    @isLastStack.push false
    for item, i in list
      @isLastStack[@isLastStack.length-1] = i is list.length-1
      @visitAny item
    @isLastStack.pop()

  visitCommand: (command) ->
    @write command.name
    for arg in command.args
      @write " "
      if arg.type is "Block"
        quote = arg.statements.length isnt 1 or arg.statements[0].args.length > 0
        @write '"' if quote
        @visitBlock arg
        @write '"' if quote
      else
        quote = arg.length is 0 or arg.indexOf(" ") >= 0
        @write '"' if quote
        @write arg
        @write '"' if quote

    # write the delimiter
    if @isLastStack.length is 1 # top level
      @write '\n'
    else if not @isLastStack[@isLastStack.length-1]
      @write '; '

  visitComment: (comment) ->
    @write "\n//#{comment.content}\n"

  visitVariableAssignment: NOTALLOWED
  visitFunctionDeclaration: NOTALLOWED
  visitEnumerationDeclaration: NOTALLOWED
  visitIfStatement: NOTALLOWED
