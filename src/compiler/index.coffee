Compiler = require './compiler'
Simplifier = require './simplifier'

module.exports = (ast) ->
  simplifier = new Simplifier
  compiler = new Compiler
  compiler.visit simplifier.transform ast
  compiler.compiled
