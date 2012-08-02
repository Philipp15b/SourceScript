ParseTreeVisitor = require '../parse-tree-visitor'

module.exports = class Compiler extends ParseTreeVisitor
  constructor: (@DEBUG = off) ->

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
    unless @inline
       @write '\n'
  
  writeAlias: (name, content = "") ->
    if content.type?
      @write "alias #{name} \""
      @visitBlockInline content
      @writeln '";'
    else
      @writeln "alias #{name} \"#{content}\";"
      
  writeNodeInfo: (node) ->
    if @DEBUG and not @inline
      @write "\n# #{node.type} in line #{node.line}, column #{node.column}\n"
    
  visitBlockInline: (tree) ->
    inlineBefore = @inline
    @inline = true
    
    @visitBlock tree
     
    unless inlineBefore
      @inline = false
  
  
  
  # Actual node type handlers  
  visitVariableAssignment: (assignment) ->
    @writeNodeInfo assignment
    expression = switch assignment.expression
      when true then "TrueHook;"
      when false then "FalseHook;"
    
    @writeAlias "var_#{assignment.id}_#{assignment.name}", expression
    
  visitFunctionDeclaration: (declaration) ->
    @writeNodeInfo declaration
    @writeAlias "function_#{declaration.name}", declaration.body
    
  visitFunctionCall: (call) ->
    @writeNodeInfo call
    @writeln call.name + ";"
    
  visitIfStatement: (ifStatement) ->
    @writeNodeInfo ifStatement
    @writeAlias "TrueHook", ifStatement.if
    @writeAlias "FalseHook", ifStatement.else

    @writeln ifStatement.condition.condition + ";"
    
  visitCommand: (command) ->
    @writeNodeInfo command
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
      @write "\n# #{comment.content}\n"
      