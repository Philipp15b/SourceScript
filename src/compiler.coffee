{Block, Command, Assignment, IfStatement, Variable, Comment, ASSIGN} = require './nodes'

# Replaces IfStatements with assignments and a command.
replaceIfs = (ast) ->
  ast.mapRecursive (statement) ->
    return statement unless statement instanceof IfStatement
    [
      ASSIGN "TrueHook", statement.if
      ASSIGN "FalseHook", statement.else
      new Command statement.variable.name, [], false
    ]

# Moves all nested assignments with more than one
# statement in the value to an auxlilary assignment on the
# top level.
moveNestedAssignments = (ast) ->
  topLevel = []
  id = 0

  ast.map (statement) ->
    topLevel = []

    statement.traverse (node) ->
      return unless node instanceof Block
      @traverse false

      node.mapRecursive (statement) ->
        return statement unless statement instanceof Assignment and statement.value.statements.length > 1
        tempName = "_assign_#{id.toString(16)}"
        id++
        topLevel.push ASSIGN tempName, statement.value
        new Assignment statement.variable, new Block [
          new Command tempName, [], false
        ]

    topLevel.push statement
    topLevel

resolveVariable = (block, variable) ->
  if variable.local
    declaration = block.scope.variable variable.name
    name = declaration.name
    prefix = ""
    if name.charAt(0) is '+' or name.charAt(0) is '-'
      prefix = name.charAt 0
      name = name.substr 1
    "#{prefix}var_#{name}_#{declaration.id.toString(16)}"
  else
    variable.name

# Compile the given AST. Only a reduced set of nodes is
# allowed: Blocks, Assignments, Commands, Variables and
# Comments.
compile = (ast) ->
  output = ""
  write = (text) -> output += text

  parent = ast # current block
  inline = no

  ast.traverse (node) ->
    writeDelim = ->
      if not inline # top level
        write '\n'
      else if parent.statements[parent.statements.length-1] isnt node
        write '; '

    if node instanceof Block
      before = parent
      parent = node
      @traverse node
      parent = before

    else if node instanceof Assignment
      before = inline
      inline = yes

      write "alias " + resolveVariable(parent, node.variable) + " "
      quote = node.value.statements.length isnt 1 or node.value.statements[0]?.args.length > 0
      write '"' if quote
      @traverse node.value
      write '"' if quote

      inline = before
      writeDelim()

    else if node instanceof Command
      write node.name
      for arg in node.args
        write " "
        quote = arg.length is 0 or arg.indexOf(" ") >= 0
        write '"' if quote
        write arg
        write '"' if quote
      writeDelim()

    else if node instanceof Variable
      write resolveVariable parent, node
      writeDelim()

    else if node instanceof Comment
      write "//#{node.content}\n" unless inline

    else
      throw new Error "Invalid node!"

  output

# Compiles the given AST. This changes the AST!
module.exports = (ast) ->
  replaceIfs ast
  moveNestedAssignments ast
  compile ast
