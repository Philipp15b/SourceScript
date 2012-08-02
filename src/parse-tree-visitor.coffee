# A base class for traversing a parse tree in top-down (pre-Order) traversal.
#
# A node is visited before its children. Derived classes may
# override the specific visitNode methods to add custom processing for specific
# nodes. 
# **It's required to call the super method AFTER YOUR METHOD when doing this.**

module.exports = class ParseTreeVisitor
  visitAny: (tree) ->
    throw new Error("No tree given!") if !tree? or tree == undefined
    @["visit#{tree.type}"](tree)
  
  visit: (tree) ->
    @visitAny tree
    
  visitList: (list) ->
    @visitAny item for item in list
  
  visitBlock: (block) ->
    @visitList block.statements
    
  visitVariableAssignment: (assignment) ->
    
  visitFunctionDeclaration: (declaration) ->
    @visitBlock declaration.body
    
  visitFunctionCall: (call) ->
  
  visitIfStatement: (ifStatement) ->
    @visitCondition ifStatement.condition
    if ifStatement.if?
      @visitBlock ifStatement.if
    if ifStatement.else?
      @visitBlock ifStatement.else
      
  visitCondition: (condition) ->
    
  visitCommand: (command) ->

  visitComment: (comment) ->
