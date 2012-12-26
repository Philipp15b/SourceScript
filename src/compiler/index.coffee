Compiler = require './compiler'
Simplifier = require './simplifier'

module.exports = (ast) ->
  simplifier = new Simplifier
  compiler = new Compiler no # debug mode isnt really helpful yet
  compiler.visit simplifier.transform ast
  compiler.compiled
