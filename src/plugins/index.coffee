ParseTreeTransformer = require '../parse-tree-transformer'
{parse} = require '../syntax'

class CommandParseTreeTransformer extends ParseTreeTransformer
  constructor: (@plugins) ->

  transformCommand: (cmd) ->
    return super cmd unless cmd.compilercommand
    unless @plugins[cmd.name]?
      throw new Error "Could not find compiler command :#{cmd.name} in line #{cmd.line}, column #{cmd.column}"

    repl = @plugins[cmd.name](cmd)
    if repl.substr?
      parse repl
    else if Array.isArray repl
      @transformList repl
    else if !repl.type?
      throw new Error "Command callback for command :#{cmd.name} didn't return a valid node!"

module.exports = (ast, plugins) ->
  cptt = new CommandParseTreeTransformer plugins
  cptt.transform ast
  ast
