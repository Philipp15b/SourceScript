# Walk a tree.
# - @traverse false disables walking the current object's children.
# - @traverse node (where node is the current node) traverses the node's
#   children right now with the current callback.
# - @traverse obj (where obj is some object other than the current node)
#   traverses the given object with the current callback.
TRAVERSE = (cb, node) ->
  traverseChildren = yes
  env =
    traverse: (obj) ->
      traverseChildren = no
      if obj is false
      else if obj is node
        obj.traverse cb
      else
        TRAVERSE cb, obj
  cb.call env, node
  node.traverse cb if traverseChildren

INDENT = "    "

module.exports =
  # Helpers
  CMD: (name, args...) -> new Command name, args, no
  ASSIGN: (varname, local, value) ->
    unless value?
      value = local
      local = no
    new Assignment new Variable(varname, local), value

  # Actual nodes
  Node: class Node
    line: null
    column: null
    p: (@line, @column) -> this
    traverse: (cb) ->
    toString: (idt = '') -> idt + this.constructor.name

  Comment: class Comment extends Node
    constructor: (@content) ->
    toString: (idt = '') -> idt + "Comment \"#{@content}\""

  Block: class Block extends Node
    constructor: (@statements) ->
    map: (cb) ->
      replacement = []
      for statement in @statements
        ret = cb statement
        if Array.isArray ret
          replacement = replacement.concat ret
        else if ret?
          replacement.push ret
      @statements = replacement
    mapRecursive: (cb) ->
      @map mapper = (statement) ->
        ret = cb statement
        statement.traverse (node) ->
          return unless node instanceof Block
          @traverse false
          node.map mapper
        ret
    traverse: (cb) -> TRAVERSE cb, s for s in @statements
    toString: (idt = '') ->
      tree = idt + "Block\n"
      idt += INDENT
      for statement in @statements
        tree += statement.toString(idt) + "\n"
      tree

  Command: class Command extends Node
    constructor: (@name, @args, @compilercommand) ->
    traverse: (cb) ->
      TRAVERSE cb, arg for arg in @args when arg instanceof Node
    toString: (idt = '') ->
      tree = idt + "Command \"#{@name}\""
      idt += INDENT
      for arg in @args
        v = if arg.substr? then idt + arg else arg.toString idt
        tree += "\n" + v
      tree

  Variable: class Variable extends Node
    constructor: (@name, @local) ->
    toString: (idt = '') -> idt + (if @local then "$" else "") + @name

  Assignment: class Assignment extends Node
    constructor: (@variable, @value) ->
    traverse: (cb) ->
      TRAVERSE cb, @variable
      TRAVERSE cb, @value
    toString: (idt = '') ->
      idt + "Assignment " + @variable.toString() + "\n" + @value.toString idt + INDENT

  IfStatement: class IfStatement extends Node
    constructor: (@variable, @if, @else) ->
    traverse: (cb) ->
      TRAVERSE cb, @variable
      TRAVERSE cb, @if if @if?
      TRAVERSE cb, @else if @else?
    toString: (idt = '') ->
      tree = idt + "IfStatement" + "\n"
      idt += INDENT
      tree += @variable.toString idt
      if @if?
        tree += "\n" + idt + "If\n"
        tree += @if.toString(idt + INDENT)
      if @else?
        tree += "\n" + idt + "Else\n"
        tree += @else.toString(idt + INDENT)

  Condition: class Condition extends Node
    constructor: (@variable, @negated) ->
    traverse: (cb) -> TRAVERSE cb, @variable
    toString: (idt = '') -> idt + "Condition " + (@negated ? "!" : "") + @variable.toString()
