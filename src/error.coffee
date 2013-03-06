module.exports = class CompilerError extends Error
  name: "CompilerError"
  constructor: (@message, node) ->
    @line = node.line
    @column = node.column

  setFile: (@file) ->

  addSource: (source) ->
    @source = source.split("\n")[@line-1]
    @source += "\n"
    @source += "~" for _ in [0...@column-1]
    @source += "^"

  toString: ->
    "#{@file ? ""}:#{@line}:#{@column}: #{@message}#{if @source? then "\n" + @source else ""}"
