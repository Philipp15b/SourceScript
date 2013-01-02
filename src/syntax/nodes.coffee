createNodes = (superclass, data) ->
  nodes = {}
  for name, properties of data then do (name, properties) ->
    klass = class extends superclass
      constructor: ->
        for property, i in properties
          @[property] = arguments[i]
        @type = name

    nodes[name] = klass

  nodes


# Base class
class Node
  p: (@line, @column) ->
    this

module.exports = createNodes Node,
  Block: ['statements']

  VariableAssignment: ['name', 'expression']

  FunctionDeclaration: ['name', 'body']
  FunctionCall: ['name']

  EnumerationDeclaration: ['name', 'content']

  IfStatement: ['condition', 'if', 'else']
  Condition: ['condition', 'isNegated']

  Command: ['name', 'args', 'compilercommand']

  Comment: ['content']
