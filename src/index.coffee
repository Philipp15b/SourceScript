parse = require './parser'
plugins = require './plugins'
{GlobalScope, assignScopes} = require './scope'
compile = require './compiler'
CompilerError = require './error'

module.exports =
  nodes: require './nodes'
  parse: parse
  compileAST: compile
  CompilerError: CompilerError

  compile: (files, options = {}) ->
    options.plugins ?= {}
    options.plugins[name] ?= handler for name, handler of plugins.builtin

    asts = {}
    for name, code of files
      try
        asts[name] = parse code
      catch e
        if e instanceof CompilerError
          e.setFile name
          e.addSource files[name]
        throw e

    gs = new GlobalScope
    compiled = {}
    for name, ast of asts
      try
        plugins.run ast, options.plugins
        assignScopes ast, gs
        compiled[name] = compile ast
      catch e
        if e instanceof CompilerError
          e.setFile name
          e.addSource files[name]
        throw e
    compiled
