Compiler = require './compiler'
Simplifier = require './simplifier'

module.exports = compile = (ast, filename, fileMetadata, debug = off) ->
  compiler = new Compiler debug
  simplifier = new Simplifier filename, fileMetadata
  compiler.visit simplifier.transform ast
  compiler.compiled
