Compiler = require './compiler'
Simplifier = require './transformers/simplifier'

module.exports = compile = (ast, debug = off) ->
  compiler = new Compiler debug
  simplifier = new Simplifier

  compiler.visit simplifier.transform ast
  compiler.compiled
